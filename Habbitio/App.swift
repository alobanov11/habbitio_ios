//
//  Created by Антон Лобанов on 18.11.2022.
//

import SwiftUI

@main
struct HabbitioApp: App {
    let persistence = Persistence.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HabbitListView()
            }
            .environmentObject(persistence)
        }
    }
}
