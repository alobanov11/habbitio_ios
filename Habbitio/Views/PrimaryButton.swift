import SwiftUI

struct PrimaryButton: View {

	let title: String
	let onTap: () async -> Void

	var body: some View {
		Button {
			Task {
				await onTap()
			}
		} label: {
			HStack(alignment: .center, spacing: 10) {
				Text(title)
					.lineLimit(1)
					.multilineTextAlignment(.center)
					.fixedSize(horizontal: false, vertical: true)
					.callout(Color.textPrimaryInvariably)
					.maxWidth(.center)
			}
			.padding(16)
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.backgroundAccent)
			)
		}
		.buttonStyle(ScaleButtonStyle())
	}
}

#Preview {
	VStack(spacing: 2) {
		PrimaryButton(
			title: "Create",
			onTap: {}
		)
	}
	.padding(.horizontal)
}
