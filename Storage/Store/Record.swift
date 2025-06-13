import Foundation
import SwiftData
import Contracts

@Model
public final class Record {

    public var date: Date
    public var done: Bool
    public var isEnabled: Bool
    public var habit: Habit?
    public var report: Report?

    public init(
		date: Date = Date(),
		done: Bool = false,
		isEnabled: Bool = true,
		habit: Habit? = nil,
		report: Report? = nil
	) {
        self.date = date
        self.done = done
        self.isEnabled = isEnabled
		self.habit = habit
		self.report = report
    }
}

extension Contracts.Record {

    public init(from record: Record) {
        let habit = Contracts.Habit(
            createdDate: record.habit?.createdDate ?? Date(),
            title: record.habit?.title ?? "",
            category: record.habit?.category,
            days: record.habit?.days ?? [],
            isArchived: record.habit?.isArchived ?? false,
            isRemainderOn: record.habit?.isRemainderOn ?? false,
            reminderDate: record.habit?.reminderDate,
            reminderText: record.habit?.reminderText
        )
        self.init(
            date: record.date,
            habit: habit,
            isEnabled: record.isEnabled,
            done: record.done
        )
    }
}
