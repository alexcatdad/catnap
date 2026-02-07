import SwiftUI

/// Repo health derived from last commit timestamp.
enum RepoStatus: String, Codable, Sendable {
    case active
    case inProgress
    case stale

    var color: Color {
        switch self {
        case .active: Theme.statusActive
        case .inProgress: Theme.statusProgress
        case .stale: Theme.statusStale
        }
    }

    var label: String {
        switch self {
        case .active: "Active"
        case .inProgress: "In Progress"
        case .stale: "Stale"
        }
    }

    /// Derives status from how recently the repo was modified.
    static func from(lastCommit: Date, activeDays: Int = 14, staleDays: Int = 60) -> RepoStatus {
        let age = Date().timeIntervalSince(lastCommit)
        let activeThreshold = TimeInterval(activeDays * 86400)
        let staleThreshold = TimeInterval(staleDays * 86400)
        if age <= activeThreshold { return .active }
        if age >= staleThreshold { return .stale }
        return .inProgress
    }
}
