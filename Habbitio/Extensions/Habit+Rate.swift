//
//  Created by Антон Лобанов on 19.12.2022.
//

import Foundation

extension Habit {
    func rate(for number: Int) -> Double {
        let records = (self.records?.suffix(number).compactMap { $0 as? Record } ?? []).filter { $0.isEnabled }
        let count = records.filter { $0.done }.count
        let total = records.count
        return total == 0 ? 0 : Double(count) / Double(total)
    }
}
