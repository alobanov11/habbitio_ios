import Foundation
import SwiftData

@Model
class Report {
    var date: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Record.report)
    var records: [Record] = []
    
    init(date: Date = Date()) {
        self.date = date
    }
}

extension Report {
    var rate: Double {
        let records = self.records.filter { $0.isEnabled || $0.done }
        let count = records.filter { $0.done }.count
        let total = records.count
        return total == 0 ? 0 : Double(count) / Double(total)
    }
    
    static func rateByWeekdays(_ reports: [Report]) -> [Double] {
        reports
            .reduce(into: Array(repeating: [Double](), count: Calendar.current.weekdaySymbols.count)) {
                result, report in
                let day = Calendar.current.component(.weekday, from: report.date) - 1
                result[day].append(report.rate)
            }
            .reduce(into: [Double]()) { result, arr in
                let total = arr.count
                result.append(total == 0 ? 0 : arr.reduce(0, +) / Double(total))
            }
    }
}
