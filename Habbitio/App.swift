//
//  Created by Антон Лобанов on 18.11.2022.
//

import SwiftUI

@main
struct HabbitioApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HabitListView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
