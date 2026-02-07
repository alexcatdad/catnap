import SwiftUI

enum Theme {
    // Surface layers
    static let panel = Color(hex: 0x1a1a1e)
    static let section = Color(hex: 0x222226)
    static let rowHover = Color(hex: 0x2a2a2f)

    // Text hierarchy
    static let textPrimary = Color(hex: 0xe8e6e3)
    static let textSecondary = Color(hex: 0x8e8c88)
    static let textTertiary = Color(hex: 0x5a5854)
    static let textAccent = Color(hex: 0xc4a882)

    // Status — muted, not traffic-light
    static let statusActive = Color(hex: 0x6bc46d)
    static let statusProgress = Color(hex: 0xd4a843)
    static let statusStale = Color(hex: 0x7a7470)

    // Dirty indicator
    static let dirty = Color(hex: 0xd4a843).opacity(0.7)

    // Borders
    static let borderSubtle = Color.white.opacity(0.06)
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
