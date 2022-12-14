//
//  Created by Антон Лобанов on 19.12.2022.
//

import Foundation

extension Report {
    var rate: Double {
        let records = (self.records?.compactMap { $0 as? Record } ?? []).filter { $0.isEnabled || $0.done }
        let count = records.filter { $0.done }.count
        let total = records.count
        return total == 0 ? 0 : Double(count) / Double(total)
    }

    static func rateByWeekdays(_ reports: [Report]) -> [Double] {
        reports
            .reduce(into: Array(repeating: [Double](), count: Calendar.current.weekdaySymbols.count)) { result, report in
                let day = Calendar.current.component(.weekday, from: report.date ?? .now) - 1
                result[day].append(report.rate)
            }
            .reduce(into: [Double]()) { result, arr in
                let total = arr.count
                result.append(total == 0 ? 0 : arr.reduce(0, +) / Double(total))
            }
    }
}
