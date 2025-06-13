import Foundation
import SwiftData
import Contracts

@Model
public final class Habit {

    @Attribute(.unique)
    public var title: String

    public var category: String?
    public var createdDate: Date
    public var days: [String]?
    public var isArchived: Bool
    public var isRemainderOn: Bool
    public var notifications: [String]?
    public var reminderDate: Date?
    public var reminderText: String?

    @Relationship(deleteRule: .cascade, inverse: \Record.habit)
    public var records: [Record] = []

    public init(
        title: String,
        category: String? = nil,
        days: [String]? = nil,
        reminderDate: Date? = nil,
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

extension Contracts.Habit {

    public init(from habit: Habit) {
        self.init(
            createdDate: habit.createdDate,
            title: habit.title,
            category: habit.category,
            days: habit.days ?? [],
            isArchived: habit.isArchived,
            isRemainderOn: habit.isRemainderOn,
            reminderDate: habit.reminderDate,
            reminderText: habit.reminderText,
            notifications: habit.notifications ?? []
        )
    }
}
