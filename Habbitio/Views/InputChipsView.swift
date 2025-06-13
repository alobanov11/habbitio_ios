import SwiftUI

struct InputChipsView: View {

	let items: [String]
	let selected: Binding<[String]>

	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 4) {
				ForEach(items, id: \.self) { item in
					Button {
						withAnimation {
							if selected.wrappedValue.contains(item) {
								selected.wrappedValue.removeAll { $0 == item }
							} else {
								selected.wrappedValue.append(item)
							}
						}
					} label: {
						Text(String(item.uppercased()))
							.footnote(
								selected.wrappedValue.contains(item)
									? Color.textPrimaryInvariably
									: Color.textPrimary
							)
							.padding(16)
							.frame(minWidth: 56)
							.background(
								RoundedRectangle(cornerRadius: 48)
									.fill(
										selected.wrappedValue.contains(item)
											? Color.backgroundAccent
											: Color.backgroundTertiary
									)
							)
					}
					.buttonStyle(ScaleButtonStyle())
				}
			}
			.padding(.horizontal, 16)
		}
	}
}

#Preview {
	@Previewable @State
	var selectedItem = ["Item 1"]

	ZStack {
		InputListView(title: "Days") {
			InputChipsView(items: ["Item 1", "Item 2", "Item 3"], selected: $selectedItem)
		}
	}
}
