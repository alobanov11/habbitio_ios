import Foundation
import Contracts
import SwiftData
import Contracts

@MainActor
public final class Store {

    public static let shared = Store()

    private let container: ModelContainer
    private let context: ModelContext

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
            container = try ModelContainer(for: schema, configurations: [configuration])
            context = ModelContext(container)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    private static var containerURL: URL {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.ru.alobanov11.habbitio")!
    }
}

extension Store: IStore {

    public func fetchArchiveHabits() async throws -> [Contracts.Habit] {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived == true },
            sortBy: [SortDescriptor(\Habit.createdDate, order: .reverse)]
        )
        let habits = try context.fetch(descriptor)
        return habits.map { Contracts.Habit(from: $0) }
    }

    public func fetchHabits() async throws -> [Contracts.Habit] {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived == false },
            sortBy: [SortDescriptor(\Habit.createdDate, order: .reverse)]
        )
        let habits = try context.fetch(descriptor)
        return habits.map { Contracts.Habit(from: $0) }
    }

    public func fetchReports() async throws -> [Contracts.Report] {
        let descriptor = FetchDescriptor<Report>(
            sortBy: [SortDescriptor(\Report.date, order: .reverse)]
        )
        let reports = try context.fetch(descriptor)
        return reports.map { Contracts.Report(from: $0) }
    }

    public func saveHabit(_ habit: Contracts.Habit) async throws {
        let title = habit.title
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate {
            $0.title == title
        })
        let existing = try context.fetch(descriptor).first
        if let existing {
            existing.category = habit.category
            existing.days = habit.days.isEmpty ? nil : habit.days
            existing.isArchived = habit.isArchived
            existing.isRemainderOn = habit.isRemainderOn
            existing.reminderDate = habit.reminderDate
            existing.reminderText = habit.reminderText
        } else {
            let model = Habit(
                title: habit.title,
                category: habit.category,
                days: habit.days.isEmpty ? nil : habit.days,
                reminderDate: habit.reminderDate,
                reminderText: habit.reminderText
            )
            model.isRemainderOn = habit.isRemainderOn
            model.isArchived = habit.isArchived
            model.createdDate = habit.createdDate
            context.insert(model)
        }
        try context.save()
        _ = try await report()
    }

    public func deleteHabit(_ habit: Contracts.Habit) async throws {
        let title = habit.title
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate {
            $0.title == title
        })
        let existing = try context.fetch(descriptor).first
        if let existing {
            context.delete(existing)
            try context.save()
        }
        _ = try await report()
    }

    public func report() async throws -> Contracts.Report {
        let currentWeekday = Calendar.current.shortWeekdaySymbols[
            Calendar.current.component(.weekday, from: .now) - 1
        ]

        let date = Calendar.current.startOfDay(for: Date())

        let habitFetchDescriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived == false },
            sortBy: [SortDescriptor(\Habit.createdDate, order: .reverse)]
        )

        let reportFetchDescriptor = FetchDescriptor<Report>(
            predicate: #Predicate {
                $0.date == date
            }
        )

        let recordFetchDescriptor = FetchDescriptor<Record>(
            predicate: #Predicate {
                $0.date == date
            }
        )

        let habits = try context.fetch(habitFetchDescriptor)
        let reports = try context.fetch(reportFetchDescriptor)
        let existingRecords = try context.fetch(recordFetchDescriptor)

        let report: Report

        if let lastReport = reports.first {
            report = lastReport
        } else {
            report = Report(date: date, records: [])
            context.insert(report)
        }

        let records = habits.map { habit -> Record in
            let record: Record

            if let existingRecord = existingRecords.first(where: {
                $0.habit?.title == habit.title
            }) {
                record = existingRecord
            } else {
                record = Record(date: date, habit: habit, report: report)
                context.insert(record)
            }

            record.isEnabled = (habit.days ?? []).contains(currentWeekday)

            return record
        }

        report.records = records
        try context.save()
        return Contracts.Report(from: report)
    }

    public func saveRecord(_ record: Contracts.Record) async throws {
        let date = record.date
        let habitTitle = record.habit.title

        let recordFetchDescriptor = FetchDescriptor<Record>(
            predicate: #Predicate {
                $0.date == date && $0.habit?.title == habitTitle
            }
        )

        if let existingRecord = try context.fetch(recordFetchDescriptor).first {
            existingRecord.done = record.done
            try context.save()
        }
    }
}
