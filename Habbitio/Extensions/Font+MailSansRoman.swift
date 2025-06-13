import SwiftUI

extension View {

    func largeTitle(_ color: Color? = nil) -> some View {
        font(.mailSansRoman(.largeTitle))
            .unwrap(color) { $0.foregroundColor($1) }
    }

    func title(_ color: Color? = nil) -> some View {
        font(.mailSansRoman(.title))
            .unwrap(color) { $0.foregroundColor($1) }
    }

    func title2(_ color: Color? = nil) -> some View {
        font(.mailSansRoman(.title2))
            .unwrap(color) { $0.foregroundColor($1) }
    }

    func title3(_ color: Color? = nil) -> some View {
        font(.mailSansRoman(.title3))
            .unwrap(color) { $0.foregroundColor($1) }
    }

    func headline(_ color: Color? = nil) -> some View {
        font(.mailSansRoman(.headline))
            .unwrap(color) { $0.foregroundColor($1) }
    }

    func subheadline(_ color: Color? = nil) -> some View {
        font(.mailSansRoman(.subheadline))
            .unwrap(color) { $0.foregroundColor($1) }
    }

    func body(_ color: Color? = nil) -> some View {
        font(.mailSansRoman(.body))
            .unwrap(color) { $0.foregroundColor($1) }
    }

    func callout(_ color: Color? = nil) -> some View {
        font(.mailSansRoman(.callout))
            .unwrap(color) { $0.foregroundColor($1) }
    }

    func footnote(_ color: Color? = nil) -> some View {
        font(.mailSansRoman(.footnote))
            .unwrap(color) { $0.foregroundColor($1) }
    }

    func caption(_ color: Color? = nil) -> some View {
        font(.mailSansRoman(.caption))
            .unwrap(color) { $0.foregroundColor($1) }
    }

    func caption2(_ color: Color? = nil) -> some View {
        font(.mailSansRoman(.caption2))
            .unwrap(color) { $0.foregroundColor($1) }
    }
}

extension Font {

    static func mailSansRoman(_ style: TextStyle) -> Font {
        return .custom(style.name, size: style.size, relativeTo: style)
    }

	static func mailSansRoman(_ size: CGFloat) -> Font {
        return .custom(
			"MailSansRoman-Regular",
			size: size,
			relativeTo: .body
		)
    }
}

private extension Font.TextStyle {

    var name: String {
        switch self {
		case .largeTitle, .title, .title2, .title3, .headline, .callout, .footnote:
            "MailSansRoman-Medium"
        case .subheadline, .body, .caption, .caption2:
            "MailSansRoman-Regular"
        @unknown default:
            "MailSansRoman-Regular"
        }
    }

    var size: CGFloat {
        switch self {
        case .largeTitle:
            36
        case .title:
            24
        case .title2:
            20
        case .title3:
            17
        case .headline:
            16
        case .subheadline:
            14
        case .body:
            16
        case .callout:
            15
        case .footnote:
            13
        case .caption:
            12
        case .caption2:
            11
        @unknown default:
            16
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .largeTitle:
            44
        case .title:
            28
        case .title2:
            26
        case .title3:
            22
        case .headline:
            30
        case .subheadline:
            18
        case .body:
            20
        case .callout:
            20
        case .footnote:
            18
        case .caption:
            16
        case .caption2:
            14
        @unknown default:
            20
        }
    }
}
