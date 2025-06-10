import Foundation
import SwiftData

@Model
class Habit {
    @Attribute(.unique) var title: String
    var category: String?
    var createdDate: Date
    var days: [String]?
    var isArchived: Bool
    var isRemainderOn: Bool
    var notifications: [String]?
    var reminderDate: Date?
    var reminderText: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Record.habit)
    var records: [Record] = []
    
    init(
        title: String, category: String? = nil, days: [String]? = nil, reminderDate: Date? = nil,
        reminderText: String? = nil
    ) {
        self.title = title
        self.category = category
        self.createdDate = Date()
        self.days = days
        self.isArchived = false
        self.isRemainderOn = false
        self.notifications = nil
        self.reminderDate = reminderDate
        self.reminderText = reminderText
    }
}

extension Habit {
    func rate(for number: Int) -> Double {
        let records = self.records.suffix(number).filter { $0.isEnabled || $0.done }
        let count = records.filter { $0.done }.count
        let total = records.count
        return total == 0 ? 0 : Double(count) / Double(total)
    }
}
