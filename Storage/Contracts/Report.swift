import Foundation

public struct Report: Hashable, Sendable, Identifiable {

    public var id: Date {
        date
    }

    public var date: Date
    public var records: [Record]

    public init(date: Date, records: [Record]) {
        self.date = date
        self.records = records
    }
}

extension Report {

    public var rate: Double {
        let records = self.records.filter { $0.isEnabled || $0.done }
        let count = records.filter { $0.done }.count
        let total = records.count
        return total == 0 ? 0 : Double(count) / Double(total)
    }
}

extension [Report] {

    public func rateByWeekdays(period: Int) -> [Double] {
        var weekdays: [[Double]] = Calendar.current.weekdaySymbols.map { _ in [] }
        for report in self.suffix(period) {
            let day = Calendar.current.component(.weekday, from: report.date) - 1
            weekdays[day].append(report.rate)
        }
        var result: [Double] = []
        for day in weekdays {
            let total = day.count
            result.append(total == 0 ? 0 : day.reduce(0, +) / Double(total))
        }
        return result
    }

    public func rateByHabit(habit: Habit, period: Int) -> Double {
        let records = flatMap { $0.records }.suffix(period).filter {
            ($0.isEnabled || $0.done) && $0.habit.id == habit.id
        }
        let count = records.filter { $0.done }.count
        let total = records.count
        return total == 0 ? 0 : Double(count) / Double(total)
    }
}
