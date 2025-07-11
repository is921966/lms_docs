import SwiftUI

struct LMSTypography {
    // MARK: - Title Styles
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.medium)
    
    // MARK: - Body Styles
    static let body = Font.body
    static let bodyBold = Font.body.weight(.semibold)
    static let callout = Font.callout
    static let calloutBold = Font.callout.weight(.semibold)
    
    // MARK: - Supporting Styles
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2
    
    // MARK: - Button Styles
    static let buttonLarge = Font.body.weight(.semibold)
    static let buttonMedium = Font.callout.weight(.semibold)
    static let buttonSmall = Font.footnote.weight(.semibold)
}

// MARK: - Text Modifiers
struct LMSTextStyle: ViewModifier {
    enum Style {
        case largeTitle
        case title
        case title2
        case title3
        case body
        case bodyBold
        case callout
        case calloutBold
        case subheadline
        case footnote
        case caption
        case caption2
        case buttonLarge
        case buttonMedium
        case buttonSmall
    }
    
    let style: Style
    let color: Color?
    
    init(style: Style, color: Color? = nil) {
        self.style = style
        self.color = color
    }
    
    func body(content: Content) -> some View {
        content
            .font(font(for: style))
            .foregroundColor(color ?? .primary)
    }
    
    private func font(for style: Style) -> Font {
        switch style {
        case .largeTitle: return LMSTypography.largeTitle
        case .title: return LMSTypography.title
        case .title2: return LMSTypography.title2
        case .title3: return LMSTypography.title3
        case .body: return LMSTypography.body
        case .bodyBold: return LMSTypography.bodyBold
        case .callout: return LMSTypography.callout
        case .calloutBold: return LMSTypography.calloutBold
        case .subheadline: return LMSTypography.subheadline
        case .footnote: return LMSTypography.footnote
        case .caption: return LMSTypography.caption
        case .caption2: return LMSTypography.caption2
        case .buttonLarge: return LMSTypography.buttonLarge
        case .buttonMedium: return LMSTypography.buttonMedium
        case .buttonSmall: return LMSTypography.buttonSmall
        }
    }
}

// MARK: - View Extensions
extension View {
    func lmsTextStyle(_ style: LMSTextStyle.Style, color: Color? = nil) -> some View {
        modifier(LMSTextStyle(style: style, color: color))
    }
}
