import XCTest
@testable import Catnap

final class AppConfigTests: XCTestCase {

    let config = AppConfig(
        scanPath: "~/repos",
        githubOwner: "testuser",
        refreshIntervalMinutes: 5,
        activeDays: 14,
        staleDays: 60,
        categories: [
            "Tools": ["hammer", "wrench"],
            "Apps": ["calculator"]
        ],
        collapsedSections: ["Apps"]
    )

    func testCategoryLookup() {
        XCTAssertEqual(config.category(for: "hammer"), "Tools")
        XCTAssertEqual(config.category(for: "calculator"), "Apps")
    }

    func testCategoryLookupIsCaseInsensitive() {
        XCTAssertEqual(config.category(for: "Hammer"), "Tools")
        XCTAssertEqual(config.category(for: "WRENCH"), "Tools")
    }

    func testUnknownRepoIsUncategorized() {
        XCTAssertEqual(config.category(for: "unknown-repo"), "Uncategorized")
    }

    func testOrderedCategoriesEndsWithUncategorized() {
        let ordered = config.orderedCategories
        XCTAssertEqual(ordered.last, "Uncategorized")
        XCTAssertTrue(ordered.contains("Tools"))
        XCTAssertTrue(ordered.contains("Apps"))
    }

    func testToggleSectionAddsToCollapsed() {
        let toggled = config.toggleSection("Tools")
        XCTAssertTrue(toggled.collapsedSections.contains("Tools"))
        XCTAssertTrue(toggled.collapsedSections.contains("Apps"))
    }

    func testToggleSectionRemovesFromCollapsed() {
        let toggled = config.toggleSection("Apps")
        XCTAssertFalse(toggled.collapsedSections.contains("Apps"))
    }

    func testJSONRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(config)
        let decoded = try decoder.decode(AppConfig.self, from: data)
        XCTAssertEqual(decoded.scanPath, config.scanPath)
        XCTAssertEqual(decoded.githubOwner, config.githubOwner)
        XCTAssertEqual(decoded.refreshIntervalMinutes, config.refreshIntervalMinutes)
        XCTAssertEqual(decoded.activeDays, config.activeDays)
        XCTAssertEqual(decoded.staleDays, config.staleDays)
        XCTAssertEqual(decoded.categories, config.categories)
        XCTAssertEqual(decoded.collapsedSections, config.collapsedSections)
    }
}
