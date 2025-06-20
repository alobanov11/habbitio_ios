import SwiftUI
import WidgetKit
import Store

@main
struct HabbitioApp: App {

	let context = Context()

    var body: some Scene {
        WindowGroup {
            NavigationView {
				HabitListRoute()
					.navigationStackRootPage()
            }
			.onBackground {
				WidgetCenter.shared.reloadAllTimelines()
			}
			.environment(\.context, context)
        }
    }
}
