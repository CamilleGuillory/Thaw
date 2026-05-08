//
//  Profile.swift
//  Project: Thaw
//
//  Copyright (Ice) © 2023–2025 Jordan Baird
//  Copyright (Thaw) © 2026 Toni Förster
//  Licensed under the GNU GPLv3

import Foundation

// MARK: - ProfileMetadata

/// Lightweight struct for listing profiles without loading full data.
struct ProfileMetadata: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var createdAt: Date
    var modifiedAt: Date
    /// The display UUID this profile auto-activates for, or `nil` for manual-only.
    var associatedDisplayUUID: String?
    /// The cached display name, used when the display is disconnected.
    var associatedDisplayName: String?
}

// MARK: - GeneralSettingsSnapshot

/// A codable snapshot of all General settings properties.
struct GeneralSettingsSnapshot: Codable {
    var showIceIcon: Bool
    var iceIcon: ControlItemImageSet
    var lastCustomIceIcon: ControlItemImageSet?
    var customIceIconIsTemplate: Bool
    var useIceBar: Bool
    var useIceBarOnlyOnNotchedDisplay: Bool
    var iceBarLocation: IceBarLocation
    var iceBarLocationOnHotkey: Bool
    var showOnClick: Bool
    var showOnDoubleClick: Bool
    var showOnHover: Bool
    var showOnScroll: Bool
    var itemSpacingOffset: Double
    var autoRehide: Bool
    var rehideStrategyRawValue: Int
    var rehideInterval: TimeInterval

    init(
        showIceIcon: Bool,
        iceIcon: ControlItemImageSet,
        lastCustomIceIcon: ControlItemImageSet?,
        customIceIconIsTemplate: Bool,
        useIceBar: Bool,
        useIceBarOnlyOnNotchedDisplay: Bool,
        iceBarLocation: IceBarLocation,
        iceBarLocationOnHotkey: Bool,
        showOnClick: Bool,
        showOnDoubleClick: Bool,
        showOnHover: Bool,
        showOnScroll: Bool,
        itemSpacingOffset: Double = Defaults.DefaultValue.itemSpacingOffset,
        autoRehide: Bool,
        rehideStrategyRawValue: Int,
        rehideInterval: TimeInterval
    ) {
        self.showIceIcon = showIceIcon
        self.iceIcon = iceIcon
        self.lastCustomIceIcon = lastCustomIceIcon
        self.customIceIconIsTemplate = customIceIconIsTemplate
        self.useIceBar = useIceBar
        self.useIceBarOnlyOnNotchedDisplay = useIceBarOnlyOnNotchedDisplay
        self.iceBarLocation = iceBarLocation
        self.iceBarLocationOnHotkey = iceBarLocationOnHotkey
        self.showOnClick = showOnClick
        self.showOnDoubleClick = showOnDoubleClick
        self.showOnHover = showOnHover
        self.showOnScroll = showOnScroll
        self.itemSpacingOffset = Self.clampItemSpacingOffset(itemSpacingOffset)
        self.autoRehide = autoRehide
        self.rehideStrategyRawValue = rehideStrategyRawValue
        self.rehideInterval = rehideInterval
    }

    @MainActor
    static func capture(from settings: GeneralSettings) -> GeneralSettingsSnapshot {
        GeneralSettingsSnapshot(
            showIceIcon: settings.showIceIcon,
            iceIcon: settings.iceIcon,
            lastCustomIceIcon: settings.lastCustomIceIcon,
            customIceIconIsTemplate: settings.customIceIconIsTemplate,
            useIceBar: settings.useIceBar,
            useIceBarOnlyOnNotchedDisplay: settings.useIceBarOnlyOnNotchedDisplay,
            iceBarLocation: settings.iceBarLocation,
            iceBarLocationOnHotkey: settings.iceBarLocationOnHotkey,
            showOnClick: settings.showOnClick,
            showOnDoubleClick: settings.showOnDoubleClick,
            showOnHover: settings.showOnHover,
            showOnScroll: settings.showOnScroll,
            itemSpacingOffset: settings.itemSpacingOffset,
            autoRehide: settings.autoRehide,
            rehideStrategyRawValue: settings.rehideStrategy.rawValue,
            rehideInterval: settings.rehideInterval
        )
    }

    @MainActor
    func apply(to settings: GeneralSettings) {
        settings.showIceIcon = showIceIcon
        settings.lastCustomIceIcon = lastCustomIceIcon
        settings.customIceIconIsTemplate = customIceIconIsTemplate
        settings.iceIcon = iceIcon
        settings.useIceBar = useIceBar
        settings.useIceBarOnlyOnNotchedDisplay = useIceBarOnlyOnNotchedDisplay
        settings.iceBarLocation = iceBarLocation
        settings.iceBarLocationOnHotkey = iceBarLocationOnHotkey
        settings.showOnClick = showOnClick
        settings.showOnDoubleClick = showOnDoubleClick
        settings.showOnHover = showOnHover
        settings.showOnScroll = showOnScroll
        settings.itemSpacingOffset = itemSpacingOffset
        settings.autoRehide = autoRehide
        if let strategy = RehideStrategy(rawValue: rehideStrategyRawValue) {
            settings.rehideStrategy = strategy
        }
        settings.rehideInterval = rehideInterval
    }

    private static func clampItemSpacingOffset(_ value: Double) -> Double {
        Swift.max(-16, Swift.min(value, 16))
    }

    enum CodingKeys: String, CodingKey {
        case showIceIcon
        case iceIcon
        case lastCustomIceIcon
        case customIceIconIsTemplate
        case useIceBar
        case useIceBarOnlyOnNotchedDisplay
        case iceBarLocation
        case iceBarLocationOnHotkey
        case showOnClick
        case showOnDoubleClick
        case showOnHover
        case showOnScroll
        case itemSpacingOffset
        case autoRehide
        case rehideStrategyRawValue
        case rehideInterval
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            showIceIcon: try container.decode(Bool.self, forKey: .showIceIcon),
            iceIcon: try container.decode(ControlItemImageSet.self, forKey: .iceIcon),
            lastCustomIceIcon: try container.decodeIfPresent(ControlItemImageSet.self, forKey: .lastCustomIceIcon),
            customIceIconIsTemplate: try container.decode(Bool.self, forKey: .customIceIconIsTemplate),
            useIceBar: try container.decode(Bool.self, forKey: .useIceBar),
            useIceBarOnlyOnNotchedDisplay: try container.decode(Bool.self, forKey: .useIceBarOnlyOnNotchedDisplay),
            iceBarLocation: try container.decode(IceBarLocation.self, forKey: .iceBarLocation),
            iceBarLocationOnHotkey: try container.decode(Bool.self, forKey: .iceBarLocationOnHotkey),
            showOnClick: try container.decode(Bool.self, forKey: .showOnClick),
            showOnDoubleClick: try container.decode(Bool.self, forKey: .showOnDoubleClick),
            showOnHover: try container.decode(Bool.self, forKey: .showOnHover),
            showOnScroll: try container.decode(Bool.self, forKey: .showOnScroll),
            itemSpacingOffset: try container.decodeIfPresent(Double.self, forKey: .itemSpacingOffset)
                ?? Defaults.DefaultValue.itemSpacingOffset,
            autoRehide: try container.decode(Bool.self, forKey: .autoRehide),
            rehideStrategyRawValue: try container.decode(Int.self, forKey: .rehideStrategyRawValue),
            rehideInterval: try container.decode(TimeInterval.self, forKey: .rehideInterval)
        )
    }
}

// MARK: - AdvancedSettingsSnapshot

/// A codable snapshot of all Advanced settings properties.
struct AdvancedSettingsSnapshot: Codable {
    var enableAlwaysHiddenSection: Bool
    var showAllSectionsOnUserDrag: Bool
    var sectionDividerStyle: Int
    var hideApplicationMenus: Bool
    var enableSecondaryContextMenu: Bool
    var showOnHoverDelay: TimeInterval
    var tooltipDelay: TimeInterval
    var showMenuBarTooltips: Bool
    var iconRefreshInterval: TimeInterval
    var enableDiagnosticLogging: Bool
    var useDoubleClickToShowAlwaysHiddenSection: Bool

    @MainActor
    static func capture(from settings: AdvancedSettings) -> AdvancedSettingsSnapshot {
        AdvancedSettingsSnapshot(
            enableAlwaysHiddenSection: settings.enableAlwaysHiddenSection,
            showAllSectionsOnUserDrag: settings.showAllSectionsOnUserDrag,
            sectionDividerStyle: settings.sectionDividerStyle.rawValue,
            hideApplicationMenus: settings.hideApplicationMenus,
            enableSecondaryContextMenu: settings.enableSecondaryContextMenu,
            showOnHoverDelay: settings.showOnHoverDelay,
            tooltipDelay: settings.tooltipDelay,
            showMenuBarTooltips: settings.showMenuBarTooltips,
            iconRefreshInterval: settings.iconRefreshInterval,
            enableDiagnosticLogging: settings.enableDiagnosticLogging,
            useDoubleClickToShowAlwaysHiddenSection: settings.useDoubleClickToShowAlwaysHiddenSection
        )
    }

    @MainActor
    func apply(to settings: AdvancedSettings) {
        settings.enableAlwaysHiddenSection = enableAlwaysHiddenSection
        settings.showAllSectionsOnUserDrag = showAllSectionsOnUserDrag
        if let style = SectionDividerStyle(rawValue: sectionDividerStyle) {
            settings.sectionDividerStyle = style
        }
        settings.hideApplicationMenus = hideApplicationMenus
        settings.enableSecondaryContextMenu = enableSecondaryContextMenu
        settings.showOnHoverDelay = showOnHoverDelay
        settings.tooltipDelay = tooltipDelay
        settings.showMenuBarTooltips = showMenuBarTooltips
        settings.iconRefreshInterval = iconRefreshInterval
        settings.enableDiagnosticLogging = enableDiagnosticLogging
        settings.useDoubleClickToShowAlwaysHiddenSection = useDoubleClickToShowAlwaysHiddenSection
    }
}

// MARK: - MenuBarLayoutSnapshot

/// A codable snapshot of the menu bar item layout.
struct MenuBarLayoutSnapshot: Codable {
    var savedSectionOrder: [String: [String]]
    var pinnedHiddenBundleIDs: [String]
    var pinnedAlwaysHiddenBundleIDs: [String]
    var customNames: [String: String]

    /// Per-item section assignments keyed by uniqueIdentifier (namespace:title).
    /// Maps to section key strings: "visible", "hidden", "alwaysHidden".
    /// This is the primary source of truth for profile restore, as it handles
    /// apps like Control Center that share a single bundle ID across many items.
    var itemSectionMap: [String: String]?

    /// Ordered list of uniqueIdentifiers per section, capturing the visual
    /// order of items at save time. Used to restore within-section ordering.
    var itemOrder: [String: [String]]?

    /// Placement preference for the New Items badge (section and anchor).
    /// Absent in profiles saved before this field was introduced.
    var newItemsPlacement: MenuBarItemManager.NewItemsPlacement?
}

// MARK: - ProfileContent

/// Groups all settings data for a profile, used to reduce init parameter count.
struct ProfileContent {
    var generalSettings: GeneralSettingsSnapshot
    var advancedSettings: AdvancedSettingsSnapshot
    var hotkeys: [String: Data]
    var displayConfigurations: [String: DisplayIceBarConfiguration]
    var appearanceConfiguration: MenuBarAppearanceConfigurationV2
    var menuBarLayout: MenuBarLayoutSnapshot
}

// MARK: - Profile

/// A complete settings profile that can be saved to and restored from disk.
struct Profile: Codable, Identifiable {
    let id: UUID
    var name: String
    var createdAt: Date
    var modifiedAt: Date
    var generalSettings: GeneralSettingsSnapshot
    var advancedSettings: AdvancedSettingsSnapshot
    var hotkeys: [String: Data]
    var displayConfigurations: [String: DisplayIceBarConfiguration]
    var appearanceConfiguration: MenuBarAppearanceConfigurationV2
    var menuBarLayout: MenuBarLayoutSnapshot

    /// Returns lightweight metadata for this profile.
    var metadata: ProfileMetadata {
        ProfileMetadata(
            id: id,
            name: name,
            createdAt: createdAt,
            modifiedAt: modifiedAt
        )
    }

    /// Returns the settings content of this profile.
    var content: ProfileContent {
        ProfileContent(
            generalSettings: generalSettings,
            advancedSettings: advancedSettings,
            hotkeys: hotkeys,
            displayConfigurations: displayConfigurations,
            appearanceConfiguration: appearanceConfiguration,
            menuBarLayout: menuBarLayout
        )
    }

    // MARK: - Forward-Compatible Decoding

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt
        case modifiedAt
        case generalSettings
        case advancedSettings
        case hotkeys
        case displayConfigurations
        case appearanceConfiguration
        case menuBarLayout
    }

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        content: ProfileContent
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.generalSettings = content.generalSettings
        self.advancedSettings = content.advancedSettings
        self.hotkeys = content.hotkeys
        self.displayConfigurations = content.displayConfigurations
        self.appearanceConfiguration = content.appearanceConfiguration
        self.menuBarLayout = content.menuBarLayout
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? String(localized: "Untitled")
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        modifiedAt = try container.decodeIfPresent(Date.self, forKey: .modifiedAt) ?? Date()

        generalSettings = try container.decodeIfPresent(
            GeneralSettingsSnapshot.self,
            forKey: .generalSettings
        ) ?? GeneralSettingsSnapshot(
            showIceIcon: Defaults.DefaultValue.showIceIcon,
            iceIcon: Defaults.DefaultValue.iceIcon,
            lastCustomIceIcon: nil,
            customIceIconIsTemplate: Defaults.DefaultValue.customIceIconIsTemplate,
            useIceBar: Defaults.DefaultValue.useIceBar,
            useIceBarOnlyOnNotchedDisplay: Defaults.DefaultValue.useIceBarOnlyOnNotchedDisplay,
            iceBarLocation: Defaults.DefaultValue.iceBarLocation,
            iceBarLocationOnHotkey: Defaults.DefaultValue.iceBarLocationOnHotkey,
            showOnClick: Defaults.DefaultValue.showOnClick,
            showOnDoubleClick: Defaults.DefaultValue.showOnDoubleClick,
            showOnHover: Defaults.DefaultValue.showOnHover,
            showOnScroll: Defaults.DefaultValue.showOnScroll,
            itemSpacingOffset: Defaults.DefaultValue.itemSpacingOffset,
            autoRehide: Defaults.DefaultValue.autoRehide,
            rehideStrategyRawValue: Defaults.DefaultValue.rehideStrategy.rawValue,
            rehideInterval: Defaults.DefaultValue.rehideInterval
        )

        advancedSettings = try container.decodeIfPresent(
            AdvancedSettingsSnapshot.self,
            forKey: .advancedSettings
        ) ?? AdvancedSettingsSnapshot(
            enableAlwaysHiddenSection: Defaults.DefaultValue.enableAlwaysHiddenSection,
            showAllSectionsOnUserDrag: Defaults.DefaultValue.showAllSectionsOnUserDrag,
            sectionDividerStyle: Defaults.DefaultValue.sectionDividerStyle.rawValue,
            hideApplicationMenus: Defaults.DefaultValue.hideApplicationMenus,
            enableSecondaryContextMenu: Defaults.DefaultValue.enableSecondaryContextMenu,
            showOnHoverDelay: Defaults.DefaultValue.showOnHoverDelay,
            tooltipDelay: Defaults.DefaultValue.tooltipDelay,
            showMenuBarTooltips: Defaults.DefaultValue.showMenuBarTooltips,
            iconRefreshInterval: Defaults.DefaultValue.iconRefreshInterval,
            enableDiagnosticLogging: Defaults.DefaultValue.enableDiagnosticLogging,
            useDoubleClickToShowAlwaysHiddenSection: Defaults.DefaultValue.useDoubleClickToShowAlwaysHiddenSection
        )

        hotkeys = try container.decodeIfPresent(
            [String: Data].self,
            forKey: .hotkeys
        ) ?? [:]

        displayConfigurations = try container.decodeIfPresent(
            [String: DisplayIceBarConfiguration].self,
            forKey: .displayConfigurations
        ) ?? Defaults.DefaultValue.displayIceBarConfigurations

        appearanceConfiguration = try container.decodeIfPresent(
            MenuBarAppearanceConfigurationV2.self,
            forKey: .appearanceConfiguration
        ) ?? Defaults.DefaultValue.menuBarAppearanceConfigurationV2

        menuBarLayout = try container.decodeIfPresent(
            MenuBarLayoutSnapshot.self,
            forKey: .menuBarLayout
        ) ?? MenuBarLayoutSnapshot(
            savedSectionOrder: [:],
            pinnedHiddenBundleIDs: [],
            pinnedAlwaysHiddenBundleIDs: [],
            customNames: [:]
        )
    }
}

// MARK: - ProfileExportEntry

/// A single profile bundled with its metadata for export/import.
/// Preserves display associations that live on the manifest.
struct ProfileExportEntry: Codable {
    var profile: Profile
    var associatedDisplayUUID: String?
    var associatedDisplayName: String?
}

/// Wrapper for exporting multiple profiles as a single file.
struct ProfileExportBundle: Codable {
    var version: Int = 1
    var entries: [ProfileExportEntry]
}
