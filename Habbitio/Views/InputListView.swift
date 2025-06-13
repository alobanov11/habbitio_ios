import SwiftUI

struct InputListView<Content: View>: View {

    let title: String

	@ViewBuilder
	var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .footnote(.textSecondary)
				.padding(.horizontal, 24)

            content()
                .maxWidth(.leading)
        }
    }
}

#Preview {
    ZStack {
        InputListView(title: "Reminder") {
			InputSelectView(text: "23:59", placeholder: "Time", onTap: {})
        }
    }
}
