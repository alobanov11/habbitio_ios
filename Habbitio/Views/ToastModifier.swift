import SwiftUI

struct ToastModifier: ViewModifier {

	@Binding
	var errorMessage: Error?

	@Binding
	var successMessage: String?

	var paddingBottom: CGFloat?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let error = errorMessage {
                    ToastView(
                        message: error.localizedDescription,
                        isError: true,
						paddingBottom: paddingBottom
                    ) {
                        errorMessage = nil
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if let success = successMessage {
                    ToastView(
                        message: success,
                        isError: false,
						paddingBottom: paddingBottom
                    ) {
                        successMessage = nil
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: errorMessage != nil)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: successMessage != nil)
    }
}

struct ToastView: View {

	let message: String
    let isError: Bool
	let paddingBottom: CGFloat?
    let onDismiss: () -> Void

    @State
	private var isVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
				.foregroundColor(isError ? .textContrast : .textPrimaryInvariably)
				.font(.system(size: 16, weight: .medium, design: .rounded))

            Text(message)
				.callout(isError ? .textContrast : .textPrimaryInvariably)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
				.fill(
					isError ? Color.backgroundNegative : Color.backgroundAccentAlternative
				)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, paddingBottom ?? 32)
		.safeAreaPadding(.bottom)
        .onAppear {
            isVisible = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onDismiss()
            }
        }
        .onTapGesture {
            onDismiss()
        }
    }
}

extension View {

	func toast(error: Binding<Error?>, success: Binding<String?>, paddingBottom: CGFloat? = nil) -> some View {
        modifier(
			ToastModifier(
				errorMessage: error,
				successMessage: success,
				paddingBottom: paddingBottom
			)
		)
    }
}
