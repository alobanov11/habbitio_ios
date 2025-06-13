import Foundation
import SwiftData
import Contracts

@Model
public final class Report {

    @Attribute(.unique)
    public var date: Date

    @Relationship(deleteRule: .nullify, inverse: \Record.report)
    public var records: [Record] = []

    public init(date: Date = Date(), records: [Record] = []) {
        self.date = date
		self.records = records
    }
}

extension Contracts.Report {

    init(from report: Report) {
        self.init(
            date: report.date,
            records: report.records.map { Contracts.Record(from: $0) }
        )
    }
}
