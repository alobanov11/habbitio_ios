import Foundation
import SwiftData

@MainActor
class DataManager {
    static let shared = DataManager()
    
    var modelContainer: ModelContainer
    var modelContext: ModelContext
    
    private init() {
        let schema = Schema([
            Habit.self,
            Record.self,
            Report.self,
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            url: Self.containerURL.appendingPathComponent("Habbitio.sqlite"),
            cloudKitDatabase: .none
        )
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }
    
    private static var containerURL: URL {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.ru.alobanov11.habbitio")!
    }
    
    static let preview: DataManager = {
        let result = DataManager()
        let context = result.modelContext
        
        for a in 0..<2 {
            for i in 0..<8 {
                let newHabit = Habit(title: "Habit #\(i)-\(a)", category: "Category #\(a)")
                newHabit.isArchived = (i % 2 == 0)
                context.insert(newHabit)
                
                let report = Report(
                    date: Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date())
                context.insert(report)
                
                let newRecord = Record(date: Date(), done: Bool.random())
                newRecord.habit = newHabit
                newRecord.report = report
                context.insert(newRecord)
            }
        }
        
        do {
            try context.save()
        } catch {
            fatalError("Unresolved error \(error)")
        }
        
        return result
    }()
}
