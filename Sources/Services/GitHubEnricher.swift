import Foundation

private let gh: String = {
    let candidates = ["/opt/homebrew/bin/gh", "/usr/local/bin/gh"]
    return candidates.first { FileManager.default.isExecutableFile(atPath: $0) } ?? "/opt/homebrew/bin/gh"
}()

/// Fetches repo descriptions from GitHub via `gh` CLI.
/// Caches results to disk, refreshes entries older than 24 hours.
enum GitHubEnricher {
    private struct CacheEntry: Codable {
        let description: String
        let fetchedAt: Date
    }

    static func fetchDescriptions(
        for repoNames: [String],
        owner: String,
        cached: [String: String]
    ) async -> [String: String] {
        var cache = loadRawCache()
        let cutoff = Date().addingTimeInterval(-86400)  // 24h

        let staleNames = repoNames.filter { name in
            guard let entry = cache[name] else { return true }
            return entry.fetchedAt <= cutoff
        }
        let maxConcurrent = 8
        await withTaskGroup(of: (String, String?).self) { group in
            for (i, name) in staleNames.enumerated() {
                if i >= maxConcurrent {
                    if let (n, d) = await group.next(), let d {
                        cache[n] = CacheEntry(description: d, fetchedAt: Date())
                    }
                }
                group.addTask {
                    let desc = await fetchDescription(owner: owner, repo: name)
                    return (name, desc)
                }
            }
            for await (name, desc) in group {
                if let desc {
                    cache[name] = CacheEntry(description: desc, fetchedAt: Date())
                }
            }
        }

        saveRawCache(cache)
        return cache.mapValues(\.description)
    }

    private static func fetchDescription(owner: String, repo: String) async -> String? {
        guard let output = try? await ShellRunner.run(
            gh,
            arguments: ["repo", "view", "\(owner)/\(repo)", "--json", "description", "-q", ".description"]
        ), !output.isEmpty else {
            return nil
        }
        return output
    }

    // MARK: - Disk Cache

    static func loadCache() -> [String: String] {
        loadRawCache().mapValues(\.description)
    }

    static func saveCache(_ descriptions: [String: String]) {
        var raw = loadRawCache()
        for (name, desc) in descriptions {
            raw[name] = CacheEntry(description: desc, fetchedAt: Date())
        }
        saveRawCache(raw)
    }

    private static func loadRawCache() -> [String: CacheEntry] {
        let path = AppConfig.cachePath
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let cache = try? JSONDecoder().decode([String: CacheEntry].self, from: data)
        else { return [:] }
        return cache
    }

    private static func saveRawCache(_ cache: [String: CacheEntry]) {
        let fm = FileManager.default
        try? fm.createDirectory(atPath: AppConfig.configDir, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(cache) else { return }
        try? data.write(to: URL(fileURLWithPath: AppConfig.cachePath))
    }
}
