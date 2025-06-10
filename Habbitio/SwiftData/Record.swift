import Foundation
import SwiftData

@Model
class Record {
    var date: Date
    var done: Bool
    var isEnabled: Bool
    
    var habit: Habit?
    var report: Report?
    
    init(date: Date = Date(), done: Bool = false, isEnabled: Bool = true) {
        self.date = date
        self.done = done
        self.isEnabled = isEnabled
    }
}
