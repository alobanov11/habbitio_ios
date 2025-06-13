import SwiftUI

struct InputTextView: View {

	@FocusState
	var focused: String?

	let text: Binding<String>
	let placeholder: String
	var error: String?
	var keyboardType: UIKeyboardType = .default
	var lineLimit = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 0) {
                Text(placeholder)
                    .caption(.textSecondary)
                    .opacity(
                        focused == placeholder || !text.wrappedValue.isEmpty ? 1 : 0
                    )

                TextField("", text: text, axis: .vertical)
                    .focused($focused, equals: placeholder)
                    .body(.textPrimary)
                    .lineLimit(lineLimit, reservesSpace: true)
                    .keyboardType(keyboardType)
                    .if(keyboardType == .emailAddress) { view in
                        view
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
            }
			.padding(.leading, 16)
            .padding(.vertical, lineLimit == 1 ? 0 : 8)
            .frame(minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.backgroundTertiary)
                    .stroke(
                        focused == placeholder ? Color.backgroundAccent : .clear,
                        lineWidth: 1
                    )
            )
            .overlay(alignment: lineLimit == 1 ? .leading : .topLeading) {
                Text(placeholder)
                    .body(.textSecondary)
                    .opacity(
                        focused != placeholder && text.wrappedValue.isEmpty ? 1 : 0
                    )
                    .padding(.horizontal)
                    .padding(.top, lineLimit == 1 ? 0 : 16)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focused = placeholder
            }

            if let error {
                Text(error)
					.footnote(Color.backgroundNegative)
            }
        }
    }
}

#Preview {
    ZStack {
        InputTextView(
			text: .constant(""),
			placeholder: "Name",
			error: "Type correct name",
			keyboardType: .default,
			lineLimit: 1
		)
		.padding(.horizontal)
    }
}
