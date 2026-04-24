import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

enum AppColors {
    static let background = Color(hex: 0xF6FAFE)
    static let surface = Color.white
    static let headerBg = Color(hex: 0xF0F4F8)
    static let navy = Color(hex: 0x00193C)
    static let navyDeep = Color(hex: 0x002D62)
    static let textPrimary = Color(hex: 0x171C1F)
    static let textHeading = Color(hex: 0x1A1A1A)
    static let textSecondary = Color(hex: 0x43474F)
    static let textTertiary = Color(hex: 0x94A3B8)
    static let divider = Color(hex: 0xC4C6D1).opacity(0.15)
    static let cardBorder = Color(hex: 0xC4C6D1).opacity(0.3)
    static let accentGreen = Color(hex: 0x2DA97A)
    static let accentGreenDark = Color(hex: 0x003623)
    static let badgeBlueBg = Color(hex: 0xD5E0F7)
    static let badgeBlueText = Color(hex: 0x586377)
    static let upcomingText = Color(hex: 0x3B77A0)
    static let avatarRing = Color(hex: 0xD7E2FF)
    static let avatarBg = Color(hex: 0xE4E9ED)

    static let navyGradient = LinearGradient(
        colors: [navy, navyDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
