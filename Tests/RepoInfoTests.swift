import XCTest
@testable import Catnap

final class RepoInfoTests: XCTestCase {

    func testGitHubURLUsesConfiguredOwner() {
        let repo = makeRepo(name: "test-repo", owner: "myuser")
        XCTAssertEqual(repo.githubURL?.absoluteString, "https://github.com/myuser/test-repo")
    }

    func testGitHubURLWithDifferentOwner() {
        let repo = makeRepo(name: "lib", owner: "other-org")
        XCTAssertEqual(repo.githubURL?.absoluteString, "https://github.com/other-org/lib")
    }

    func testRelativeTimeIsNonEmpty() {
        let repo = makeRepo(
            name: "test",
            owner: "test",
            lastCommit: Date().addingTimeInterval(-3600)
        )
        XCTAssertFalse(repo.relativeTime.isEmpty)
    }

    private func makeRepo(
        name: String,
        owner: String,
        lastCommit: Date = Date()
    ) -> RepoInfo {
        RepoInfo(
            id: name,
            name: name,
            path: "/tmp/\(name)",
            lastCommitDate: lastCommit,
            branch: "main",
            isDirty: false,
            status: .active,
            description: nil,
            category: "Test",
            githubOwner: owner
        )
    }
}
