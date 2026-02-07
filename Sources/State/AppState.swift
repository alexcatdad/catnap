import Foundation
import SwiftUI

@Observable
@MainActor
final class AppState {
    var repos: [RepoInfo] = []
    var config: AppConfig
    var isLoading = false
    var isExpanded = false  // Option+Click mode
    var descriptions: [String: String] = [:]  // repo name → GitHub description

    private var pollTask: Task<Void, Never>?

    /// Repos grouped by category in config-defined order.
    var groupedRepos: [(category: String, repos: [RepoInfo])] {
        let grouped = Dictionary(grouping: repos, by: \.category)
        return config.orderedCategories.compactMap { cat in
            guard let items = grouped[cat], !items.isEmpty else { return nil }
            return (cat, items.sorted { $0.lastCommitDate > $1.lastCommitDate })
        }
    }

    var statusCounts: (active: Int, inProgress: Int, stale: Int) {
        let a = repos.filter { $0.status == .active }.count
        let p = repos.filter { $0.status == .inProgress }.count
        let s = repos.filter { $0.status == .stale }.count
        return (a, p, s)
    }

    init() {
        self.config = AppConfig.load()
        loadCachedDescriptions()
        startPolling()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let scanPath = NSString(string: config.scanPath).expandingTildeInPath
            let repoPaths = try await GitScanner.discoverRepos(in: scanPath)

            // Capture @MainActor state before entering task group
            let activeDays = config.activeDays
            let staleDays = config.staleDays
            let descriptions = self.descriptions
            let currentConfig = self.config
            let owner = config.githubOwner

            var scanned: [RepoInfo] = []
            await withTaskGroup(of: RepoInfo?.self) { group in
                for path in repoPaths {
                    group.addTask {
                        let name = URL(fileURLWithPath: path).lastPathComponent
                        guard let git = await GitScanner.scan(repoPath: path) else { return nil }
                        return RepoInfo(
                            id: name,
                            name: name,
                            path: path,
                            lastCommitDate: git.lastCommitDate,
                            branch: git.branch,
                            isDirty: git.isDirty,
                            status: RepoStatus.from(
                                lastCommit: git.lastCommitDate,
                                activeDays: activeDays,
                                staleDays: staleDays
                            ),
                            description: descriptions[name],
                            category: currentConfig.category(for: name),
                            githubOwner: owner
                        )
                    }
                }
                for await repo in group {
                    if let repo { scanned.append(repo) }
                }
            }
            self.repos = scanned
        } catch {
            print("Scan error: \(error)")
        }
    }

    func startPolling() {
        pollTask?.cancel()
        pollTask = Task {
            await Task.yield()  // let previous task finish cancellation
            while !Task.isCancelled {
                await refresh()
                if isExpanded {
                    await enrichDescriptions()
                }
                try? await Task.sleep(for: .seconds(config.refreshIntervalMinutes * 60))
            }
        }
    }

    func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
    }

    func toggleSection(_ section: String) {
        config = config.toggleSection(section)
        config.save()
    }

    func isSectionCollapsed(_ section: String) -> Bool {
        config.collapsedSections.contains(section)
    }

    func enrichDescriptions() async {
        let enriched = await GitHubEnricher.fetchDescriptions(
            for: repos.map(\.name),
            owner: config.githubOwner,
            cached: descriptions
        )
        self.descriptions = enriched
        // Update existing repos with descriptions
        self.repos = repos.map { repo in
            var updated = repo
            updated.description = enriched[repo.name]
            return updated
        }
        GitHubEnricher.saveCache(enriched)
    }

    private func loadCachedDescriptions() {
        descriptions = GitHubEnricher.loadCache()
    }
}
