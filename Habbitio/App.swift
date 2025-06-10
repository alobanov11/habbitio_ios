import SwiftData
import SwiftUI

@main
struct HabbitioApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HabitListView()
            }
        }
        .modelContainer(DataManager.shared.modelContainer)
    }
}
