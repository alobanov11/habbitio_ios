import SwiftUI

extension View {

    @ViewBuilder
    func hidden(_ hidden: Bool) -> some View {
        if hidden == false {
            self
        }
    }

    func maxWidth(_ alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, alignment: alignment)
    }

    func maxHeight(_ alignment: Alignment = .center) -> some View {
        frame(maxHeight: .infinity, alignment: alignment)
    }

	func apply<T, Content: View>(
		_ value: T,
		@ViewBuilder content: (Self, T) -> Content
	) -> some View {
		content(self, value)
	}

	@ViewBuilder
	func `if`<Content: View>(
		_ condition: Bool,
		@ViewBuilder content: (Self) -> Content
	) -> some View {
		if condition {
			content(self)
		} else {
			self
		}
	}

	@ViewBuilder
	func `if`<IfContent: View, ElseContent: View>(
		_ condition: Bool,
		@ViewBuilder if ifContent: (Self) -> IfContent,
		@ViewBuilder else elseContent: (Self) -> ElseContent
	) -> some View {
		if condition {
			ifContent(self)
		} else {
			elseContent(self)
		}
	}

	@ViewBuilder
	func unwrap<Content: View, T>(
		_ value: T?,
		@ViewBuilder content: (Self, T) -> Content
	) -> some View {
		if let value {
			content(self, value)
		} else {
			self
		}
	}

    func onBackground(_ f: @escaping () -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
            perform: { _ in f() }
        )
    }

    func onForeground(_ f: @escaping () -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification),
            perform: { _ in f() }
        )
    }
}
