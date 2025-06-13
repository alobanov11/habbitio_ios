import SwiftUI

struct InputRadioButton: View {

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

            Circle()
				.fill(selected.wrappedValue ? Color.backgroundAccent : Color.clear)
				.stroke(
					selected.wrappedValue ? Color.backgroundAccent : Color.textSecondary,
					lineWidth: selected.wrappedValue ? 0 : 2
				)
                .frame(width: 20, height: 20)
                .overlay(alignment: .center) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .opacity(selected.wrappedValue ? 1 : 0)
                }
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

	InputListView(title: "Reminder") {
		InputRadioButton(title: "Enabled", selected: $selected)
	}
    .padding(.horizontal)
}
