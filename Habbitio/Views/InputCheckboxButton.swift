import SwiftUI

struct InputCheckboxButton: View {

	let title: String
	let selected: Binding<Bool>

	var body: some View {
		Button {
			withAnimation {
				selected.wrappedValue.toggle()
			}
		} label: {
			content
		}
		.buttonStyle(ScaleButtonStyle())
	}

	var content: some View {
		HStack(spacing: 12) {
			Text(title)
				.body(.textPrimary)

			Spacer()

			Image(
				systemName: selected.wrappedValue ? "checkmark.circle.fill" : "circle"
			)
			.foregroundColor(selected.wrappedValue ? .textAccent : .textSecondary)
			.font(.system(size: 24, design: .rounded))
		}
		.padding(.horizontal)
		.padding(.vertical, 8)
		.frame(minHeight: 56)
		.background(
			RoundedRectangle(cornerRadius: 16)
				.fill(Color.backgroundTertiary)
		)
	}
}

#Preview {
	@Previewable @State
	var selected = false

	InputCheckboxButton(title: "Reminder", selected: $selected)
		.padding(.horizontal, 16)
}
