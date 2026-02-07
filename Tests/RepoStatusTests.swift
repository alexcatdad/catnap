import XCTest
@testable import Catnap

final class RepoStatusTests: XCTestCase {

    func testRecentCommitIsActive() {
        let status = RepoStatus.from(lastCommit: Date(), activeDays: 14, staleDays: 60)
        XCTAssertEqual(status, .active)
    }

    func testWithinActiveThreshold() {
        let date = Date().addingTimeInterval(-7 * 86400)
        let status = RepoStatus.from(lastCommit: date, activeDays: 14, staleDays: 60)
        XCTAssertEqual(status, .active)
    }

    func testExactActiveThresholdIsActive() {
        let date = Date().addingTimeInterval(-14 * 86400)
        let status = RepoStatus.from(lastCommit: date, activeDays: 14, staleDays: 60)
        XCTAssertEqual(status, .active)
    }

    func testBetweenThresholdsIsInProgress() {
        let date = Date().addingTimeInterval(-30 * 86400)
        let status = RepoStatus.from(lastCommit: date, activeDays: 14, staleDays: 60)
        XCTAssertEqual(status, .inProgress)
    }

    func testExactStaleThresholdIsStale() {
        let date = Date().addingTimeInterval(-60 * 86400)
        let status = RepoStatus.from(lastCommit: date, activeDays: 14, staleDays: 60)
        XCTAssertEqual(status, .stale)
    }

    func testOldCommitIsStale() {
        let date = Date().addingTimeInterval(-180 * 86400)
        let status = RepoStatus.from(lastCommit: date, activeDays: 14, staleDays: 60)
        XCTAssertEqual(status, .stale)
    }

    func testCustomThresholds() {
        let date = Date().addingTimeInterval(-5 * 86400)
        let status = RepoStatus.from(lastCommit: date, activeDays: 3, staleDays: 30)
        XCTAssertEqual(status, .inProgress)
    }
}
