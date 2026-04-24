import SwiftUI

enum AppFonts {
    static func dmSans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(dmSansName(weight), size: size)
    }

    static func dmSans(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .custom(dmSansName(weight), size: style.defaultSize, relativeTo: style)
    }

    static func bricolage(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(bricolageName(weight), size: size)
    }

    static func bricolage(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .custom(bricolageName(weight), size: style.defaultSize, relativeTo: style)
    }
}

private func dmSansName(_ weight: Font.Weight) -> String {
    switch weight {
    case .thin:        return "DMSans-Thin"
    case .ultraLight:  return "DMSans-ExtraLight"
    case .light:       return "DMSans-Light"
    case .medium:      return "DMSans-Medium"
    case .semibold:    return "DMSans-SemiBold"
    case .bold:        return "DMSans-Bold"
    case .heavy:       return "DMSans-ExtraBold"
    case .black:       return "DMSans-Black"
    default:           return "DMSans-Regular"
    }
}

private func bricolageName(_ weight: Font.Weight) -> String {
    switch weight {
    case .ultraLight:  return "BricolageGrotesque-ExtraLight"
    case .thin, .light: return "BricolageGrotesque-Light"
    case .medium:      return "BricolageGrotesque-Medium"
    case .semibold:    return "BricolageGrotesque-SemiBold"
    case .bold:        return "BricolageGrotesque-Bold"
    case .heavy, .black: return "BricolageGrotesque-ExtraBold"
    default:           return "BricolageGrotesque-Regular"
    }
}

private extension Font.TextStyle {
    var defaultSize: CGFloat {
        switch self {
        case .largeTitle:  return 34
        case .title:       return 28
        case .title2:      return 22
        case .title3:      return 20
        case .headline:    return 17
        case .body:        return 17
        case .callout:     return 16
        case .subheadline: return 15
        case .footnote:    return 13
        case .caption:     return 12
        case .caption2:    return 11
        @unknown default:  return 17
        }
    }
}
