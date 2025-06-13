import Foundation

public struct Habit: Hashable, Sendable, Identifiable {

    public var id: String {
        title
    }

    public var createdDate: Date
    public var title: String
    public var category: String?
    public var days: [String]
    public var isArchived: Bool
    public var isRemainderOn: Bool
    public var reminderDate: Date?
    public var reminderText: String?
    public var notifications: [String]

    public init(
        createdDate: Date = Date(),
        title: String,
        category: String?,
        days: [String],
        isArchived: Bool,
        isRemainderOn: Bool,
        reminderDate: Date?,
        reminderText: String?,
        notifications: [String] = []
    ) {
        self.createdDate = createdDate
        self.title = title
        self.category = category
        self.days = days
        self.isArchived = isArchived
        self.isRemainderOn = isRemainderOn
        self.reminderDate = reminderDate
        self.reminderText = reminderText
        self.notifications = notifications
    }
}


