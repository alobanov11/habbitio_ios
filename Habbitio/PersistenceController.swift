//
//  Created by Антон Лобанов on 18.11.2022.
//

import CoreData

final class PersistenceController: ObservableObject {
    static let shared = PersistenceController()

    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<9 {
            let newHabit = Habit(context: viewContext)
            newHabit.title = "Habit #\(i)"
            newHabit.createdDate = Date()
            newHabit.frequency = Int16.random(in: 1 ... 5)
            newHabit.isArchived = (i % 2 == 0)

            let newRecord = Record(context: viewContext)
            newRecord.habit = newHabit
            newRecord.count = Int16.random(in: 1 ... 5)
            newRecord.date = Date()
        }
        do {
            try viewContext.save()
        }
        catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    var containerURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ru.alobanov11.habbitio")!
    }

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        self.container = NSPersistentContainer(name: "Habbitio")
        if inMemory {
            self.container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        else {
            let storeURL = self.containerURL.appendingPathComponent("Habbitio.sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            self.container.persistentStoreDescriptions = [description]
            print(storeURL)
        }
        self.container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
