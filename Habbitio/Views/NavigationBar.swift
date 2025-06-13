import SwiftUI

struct NavigationBar: View {

    @Environment(\.isNavigationStackRootPage)
    var isNavigationStackRootPage

    @Environment(\.isPresentedPage)
    var isPresentedPage

    @Environment(\.dismiss)
    var dismiss

    @ViewBuilder
    var content: () -> any View

    var body: some View {
        HStack(spacing: 0) {
            if !isNavigationStackRootPage || isPresentedPage {
                Button(action: dismiss.callAsFunction) {
                    Image(systemName: isPresentedPage ? "xmark" : "chevron.left")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 48, height: 48)
                        .background(
                            Circle().fill(Color.backgroundTertiary)
                        )
                }

                Spacer()
            }

            AnyView(erasing: content())
        }
        .frame(minHeight: 56)
		.padding(.top, 24)
		.padding(.horizontal, 24)
    }
}

extension NavigationBar {

    init() {
        self.content = { EmptyView() }
    }
}

extension EnvironmentValues {

    private enum NavigationStackRootKey: EnvironmentKey {

        static let defaultValue = false
    }

    private enum PresentedPageKey: EnvironmentKey {

        static let defaultValue = false
    }

    var isNavigationStackRootPage: Bool {
        get { self[NavigationStackRootKey.self] }
        set { self[NavigationStackRootKey.self] = newValue }
    }

    var isPresentedPage: Bool {
        get { self[PresentedPageKey.self] }
        set { self[PresentedPageKey.self] = newValue }
    }
}

extension View {

    func navigationStackRootPage() -> some View {
        environment(\.isNavigationStackRootPage, true)
    }

    func presentedPage() -> some View {
        environment(\.isPresentedPage, true)
    }
}
