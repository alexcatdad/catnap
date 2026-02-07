import Foundation

struct AppConfig: Codable, Sendable {
    var scanPath: String
    var githubOwner: String
    var refreshIntervalMinutes: Int
    var activeDays: Int
    var staleDays: Int
    var categories: [String: [String]]  // category name → repo names
    var collapsedSections: [String]

    static let configDir = NSString(string: "~/.config/catnap").expandingTildeInPath
    static let configPath = (configDir as NSString).appendingPathComponent("config.json")
    static let cachePath = (configDir as NSString).appendingPathComponent("gh-cache.json")

    /// Looks up which category a repo belongs to, or "Uncategorized".
    func category(for repoName: String) -> String {
        let lower = repoName.lowercased()
        for (cat, repos) in categories {
            if repos.contains(where: { $0.lowercased() == lower }) {
                return cat
            }
        }
        return "Uncategorized"
    }

    /// Ordered category names — defined categories first, "Uncategorized" last.
    var orderedCategories: [String] {
        let defined = categories.keys.sorted()
        return defined + ["Uncategorized"]
    }

    static func load() -> AppConfig {
        let path = configPath
        guard FileManager.default.fileExists(atPath: path),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let config = try? JSONDecoder().decode(AppConfig.self, from: data)
        else {
            return .default
        }
        return config
    }

    func save() {
        let fm = FileManager.default
        try? fm.createDirectory(atPath: AppConfig.configDir, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(self) else { return }
        try? data.write(to: URL(fileURLWithPath: AppConfig.configPath))
    }

    func toggleSection(_ section: String) -> AppConfig {
        var copy = self
        if copy.collapsedSections.contains(section) {
            copy.collapsedSections.removeAll { $0 == section }
        } else {
            copy.collapsedSections.append(section)
        }
        return copy
    }

    static let `default` = AppConfig(
        scanPath: "~/REPOS/alexcatdad",
        githubOwner: "alexcatdad",
        refreshIntervalMinutes: 5,
        activeDays: 14,
        staleDays: 60,
        categories: [
            "Profile & Config": ["alexcatdad", "alexcatdad.github.io", "profile", "dotfiles", "paw"],
            "Developer Tools": ["paw-proxy", "meowtern", "mission-control"],
            "Infrastructure": ["shoyu-flux", "soy-sauce", "server-config", "sonarr-tools"],
            "Applications": [
                "scrouge", "idkarr", "anikarr", "homelab-inventory",
                "one-ace", "quorum", "fantastic-memory", "test-browser-llm", "the-gap"
            ],
            "Games & Creative": [
                "the-whisker-shogunate", "whisker-lore-api",
                "whisker-shogunate-website", "project-clockwork"
            ]
        ],
        collapsedSections: []
    )
}
