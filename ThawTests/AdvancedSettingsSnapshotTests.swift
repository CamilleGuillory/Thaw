//
//  AdvancedSettingsSnapshotTests.swift
//  Project: Thaw
//
//  Copyright (Ice) © 2023–2025 Jordan Baird
//  Copyright (Thaw) © 2026 Toni Förster
//  Licensed under the GNU GPLv3

@testable import Thaw
import XCTest

final class AdvancedSettingsSnapshotTests: XCTestCase {
    private var encoder: JSONEncoder!
    private var decoder: JSONDecoder!

    override func setUp() {
        super.setUp()
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    override func tearDown() {
        encoder = nil
        decoder = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func makeDefaultSnapshot() -> AdvancedSettingsSnapshot {
        AdvancedSettingsSnapshot(
            enableAlwaysHiddenSection: true,
            showAllSectionsOnUserDrag: true,
            sectionDividerStyle: 0,
            hideApplicationMenus: false,
            enableSecondaryContextMenu: true,
            showOnHoverDelay: 0.2,
            tooltipDelay: 1.0,
            showMenuBarTooltips: true,
            iconRefreshInterval: 3.0,
            enableDiagnosticLogging: false,
            useDoubleClickToShowAlwaysHiddenSection: false
        )
    }

    private func makeCustomSnapshot() -> AdvancedSettingsSnapshot {
        AdvancedSettingsSnapshot(
            enableAlwaysHiddenSection: false,
            showAllSectionsOnUserDrag: false,
            sectionDividerStyle: 1,
            hideApplicationMenus: true,
            enableSecondaryContextMenu: false,
            showOnHoverDelay: 0.5,
            tooltipDelay: 2.0,
            showMenuBarTooltips: false,
            iconRefreshInterval: 5.0,
            enableDiagnosticLogging: true,
            useDoubleClickToShowAlwaysHiddenSection: true
        )
    }

    // MARK: - Initialization Tests

    func testDefaultSnapshotValues() {
        let snapshot = makeDefaultSnapshot()

        XCTAssertTrue(snapshot.enableAlwaysHiddenSection)
        XCTAssertTrue(snapshot.showAllSectionsOnUserDrag)
        XCTAssertEqual(snapshot.sectionDividerStyle, 0)
        XCTAssertFalse(snapshot.hideApplicationMenus)
        XCTAssertTrue(snapshot.enableSecondaryContextMenu)
        XCTAssertEqual(snapshot.showOnHoverDelay, 0.2)
        XCTAssertEqual(snapshot.tooltipDelay, 1.0)
        XCTAssertTrue(snapshot.showMenuBarTooltips)
        XCTAssertEqual(snapshot.iconRefreshInterval, 3.0)
        XCTAssertFalse(snapshot.enableDiagnosticLogging)
        XCTAssertFalse(snapshot.useDoubleClickToShowAlwaysHiddenSection)
    }

    func testCustomSnapshotValues() {
        let snapshot = makeCustomSnapshot()

        XCTAssertFalse(snapshot.enableAlwaysHiddenSection)
        XCTAssertFalse(snapshot.showAllSectionsOnUserDrag)
        XCTAssertEqual(snapshot.sectionDividerStyle, 1)
        XCTAssertTrue(snapshot.hideApplicationMenus)
        XCTAssertFalse(snapshot.enableSecondaryContextMenu)
        XCTAssertEqual(snapshot.showOnHoverDelay, 0.5)
        XCTAssertEqual(snapshot.tooltipDelay, 2.0)
        XCTAssertFalse(snapshot.showMenuBarTooltips)
        XCTAssertEqual(snapshot.iconRefreshInterval, 5.0)
        XCTAssertTrue(snapshot.enableDiagnosticLogging)
        XCTAssertTrue(snapshot.useDoubleClickToShowAlwaysHiddenSection)
    }

    // MARK: - Encode/Decode Tests

    func testEncodeDecodeDefaultSnapshot() throws {
        let original = makeDefaultSnapshot()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

        XCTAssertEqual(decoded.enableAlwaysHiddenSection, original.enableAlwaysHiddenSection)
        XCTAssertEqual(decoded.showAllSectionsOnUserDrag, original.showAllSectionsOnUserDrag)
        XCTAssertEqual(decoded.sectionDividerStyle, original.sectionDividerStyle)
        XCTAssertEqual(decoded.hideApplicationMenus, original.hideApplicationMenus)
        XCTAssertEqual(decoded.enableSecondaryContextMenu, original.enableSecondaryContextMenu)
        XCTAssertEqual(decoded.showOnHoverDelay, original.showOnHoverDelay)
        XCTAssertEqual(decoded.tooltipDelay, original.tooltipDelay)
        XCTAssertEqual(decoded.showMenuBarTooltips, original.showMenuBarTooltips)
        XCTAssertEqual(decoded.iconRefreshInterval, original.iconRefreshInterval)
        XCTAssertEqual(decoded.enableDiagnosticLogging, original.enableDiagnosticLogging)
        XCTAssertEqual(decoded.useDoubleClickToShowAlwaysHiddenSection, original.useDoubleClickToShowAlwaysHiddenSection)
    }

    func testEncodeDecodeCustomSnapshot() throws {
        let original = makeCustomSnapshot()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

        XCTAssertEqual(decoded.enableAlwaysHiddenSection, false)
        XCTAssertEqual(decoded.showAllSectionsOnUserDrag, false)
        XCTAssertEqual(decoded.sectionDividerStyle, 1)
        XCTAssertEqual(decoded.hideApplicationMenus, true)
        XCTAssertEqual(decoded.enableSecondaryContextMenu, false)
        XCTAssertEqual(decoded.showOnHoverDelay, 0.5)
        XCTAssertEqual(decoded.tooltipDelay, 2.0)
        XCTAssertEqual(decoded.showMenuBarTooltips, false)
        XCTAssertEqual(decoded.iconRefreshInterval, 5.0)
        XCTAssertEqual(decoded.enableDiagnosticLogging, true)
        XCTAssertEqual(decoded.useDoubleClickToShowAlwaysHiddenSection, true)
    }

    // MARK: - SectionDividerStyle Tests

    func testAllSectionDividerStyles() throws {
        for style in SectionDividerStyle.allCases {
            var snapshot = makeDefaultSnapshot()
            snapshot.sectionDividerStyle = style.rawValue

            let data = try encoder.encode(snapshot)
            let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

            XCTAssertEqual(decoded.sectionDividerStyle, style.rawValue)
        }
    }

    // MARK: - TimeInterval Edge Cases

    func testZeroShowOnHoverDelay() throws {
        var snapshot = makeDefaultSnapshot()
        snapshot.showOnHoverDelay = 0

        let data = try encoder.encode(snapshot)
        let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

        XCTAssertEqual(decoded.showOnHoverDelay, 0)
    }

    func testLargeShowOnHoverDelay() throws {
        var snapshot = makeDefaultSnapshot()
        snapshot.showOnHoverDelay = 10.0

        let data = try encoder.encode(snapshot)
        let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

        XCTAssertEqual(decoded.showOnHoverDelay, 10.0)
    }

    func testZeroTooltipDelay() throws {
        var snapshot = makeDefaultSnapshot()
        snapshot.tooltipDelay = 0

        let data = try encoder.encode(snapshot)
        let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

        XCTAssertEqual(decoded.tooltipDelay, 0)
    }

    func testLargeTooltipDelay() throws {
        var snapshot = makeDefaultSnapshot()
        snapshot.tooltipDelay = 60.0

        let data = try encoder.encode(snapshot)
        let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

        XCTAssertEqual(decoded.tooltipDelay, 60.0)
    }

    func testZeroIconRefreshInterval() throws {
        var snapshot = makeDefaultSnapshot()
        snapshot.iconRefreshInterval = 0

        let data = try encoder.encode(snapshot)
        let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

        XCTAssertEqual(decoded.iconRefreshInterval, 0)
    }

    func testLargeIconRefreshInterval() throws {
        var snapshot = makeDefaultSnapshot()
        snapshot.iconRefreshInterval = 60.0

        let data = try encoder.encode(snapshot)
        let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

        XCTAssertEqual(decoded.iconRefreshInterval, 60.0)
    }

    func testFractionalDelays() throws {
        var snapshot = makeDefaultSnapshot()
        snapshot.showOnHoverDelay = 0.15
        snapshot.tooltipDelay = 0.75
        snapshot.iconRefreshInterval = 2.5

        let data = try encoder.encode(snapshot)
        let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

        XCTAssertEqual(decoded.showOnHoverDelay, 0.15, accuracy: 0.001)
        XCTAssertEqual(decoded.tooltipDelay, 0.75, accuracy: 0.001)
        XCTAssertEqual(decoded.iconRefreshInterval, 2.5, accuracy: 0.001)
    }

    // MARK: - Boolean Combinations

    func testAllBooleansFalse() throws {
        let snapshot = AdvancedSettingsSnapshot(
            enableAlwaysHiddenSection: false,
            showAllSectionsOnUserDrag: false,
            sectionDividerStyle: 0,
            hideApplicationMenus: false,
            enableSecondaryContextMenu: false,
            showOnHoverDelay: 0,
            tooltipDelay: 0,
            showMenuBarTooltips: false,
            iconRefreshInterval: 0,
            enableDiagnosticLogging: false,
            useDoubleClickToShowAlwaysHiddenSection: false
        )

        let data = try encoder.encode(snapshot)
        let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

        XCTAssertFalse(decoded.enableAlwaysHiddenSection)
        XCTAssertFalse(decoded.showAllSectionsOnUserDrag)
        XCTAssertFalse(decoded.hideApplicationMenus)
        XCTAssertFalse(decoded.enableSecondaryContextMenu)
        XCTAssertFalse(decoded.showMenuBarTooltips)
        XCTAssertFalse(decoded.enableDiagnosticLogging)
        XCTAssertFalse(decoded.useDoubleClickToShowAlwaysHiddenSection)
    }

    func testAllBooleansTrue() throws {
        let snapshot = AdvancedSettingsSnapshot(
            enableAlwaysHiddenSection: true,
            showAllSectionsOnUserDrag: true,
            sectionDividerStyle: 0,
            hideApplicationMenus: true,
            enableSecondaryContextMenu: true,
            showOnHoverDelay: 0,
            tooltipDelay: 0,
            showMenuBarTooltips: true,
            iconRefreshInterval: 0,
            enableDiagnosticLogging: true,
            useDoubleClickToShowAlwaysHiddenSection: true
        )

        let data = try encoder.encode(snapshot)
        let decoded = try decoder.decode(AdvancedSettingsSnapshot.self, from: data)

        XCTAssertTrue(decoded.enableAlwaysHiddenSection)
        XCTAssertTrue(decoded.showAllSectionsOnUserDrag)
        XCTAssertTrue(decoded.hideApplicationMenus)
        XCTAssertTrue(decoded.enableSecondaryContextMenu)
        XCTAssertTrue(decoded.showMenuBarTooltips)
        XCTAssertTrue(decoded.enableDiagnosticLogging)
        XCTAssertTrue(decoded.useDoubleClickToShowAlwaysHiddenSection)
    }
}
