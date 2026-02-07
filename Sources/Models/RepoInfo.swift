import Foundation

struct RepoInfo: Identifiable, Sendable {
    let id: String  // repo name
    let name: String
    let path: String
    let lastCommitDate: Date
    let branch: String
    let isDirty: Bool
    let status: RepoStatus
    var description: String?
    var category: String
    var githubOwner: String

    var githubURL: URL? {
        URL(string: "https://github.com/\(githubOwner)/\(name)")
    }

    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastCommitDate, relativeTo: Date())
    }
}
