import SwiftUI

struct InputSelectView: View {

    let text: String
    var error: String?
    let placeholder: String
	let onTap: () -> Void

    var body: some View {
		Button {
			onTap()
		} label: {
			content
		}
		.buttonStyle(ScaleButtonStyle())
    }

	var content: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack {
				VStack {
					Text(placeholder)
						.if(text.isEmpty) {
							$0.body(.textSecondary)
						} else: {
							$0.caption(.textSecondary)
						}
						.maxWidth(.leading)

					if !text.isEmpty {
						Text(text)
							.body(.textPrimary)
							.maxWidth(.leading)
					}
				}

				Image(systemName: "chevron.right")
					.font(.system(size: 16))
					.foregroundStyle(.textSecondary)
			}
			.padding(.horizontal)
			.padding(.vertical, 8)
			.frame(minHeight: 56)
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.backgroundTertiary)
			)

			if let error {
				Text(error)
					.footnote(Color.backgroundNegative)
			}
		}
	}
}

#Preview {
    ZStack {
        InputSelectView(
            text: "",
            placeholder: "Дата рождения",
			onTap: {}
        )
        .padding(.horizontal)
    }
}
