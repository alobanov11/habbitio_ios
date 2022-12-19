//
//  Created by Антон Лобанов on 19.12.2022.
//

import SwiftUI
import Charts

struct StatsView: View {
    private enum Period: Int, Identifiable, CaseIterable {
        case week = 7
        case month = 30
        case year = 365
        case all

        var id: Int { self.rawValue }

        var title: String {
            switch self {
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            case .all: return "All"
            }
        }
    }

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)])
    private var reports: FetchedResults<Report>

    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "isArchived == %@", NSNumber(value: false))
    )
    private var habits: FetchedResults<Habit>

    @State private var period: Period = .week
    @State private var isPeriodPresented = false

    var body: some View {
        List {
            Section {
                Chart(reports.suffix(period.rawValue)) {
                    LineMark(
                        x: .value("Date", $0.date!),
                        y: .value("Rate", $0.rate)
                    )
                }
                .frame(height: 250)
            }

            Section {
                Chart(habits) {
                    let rate = ($0.records?.suffix(period.rawValue).compactMap { $0 as? Record } ?? [])
                        .map { $0.count }
                        .reduce(0, +)

                    BarMark(
                        x: .value("Name", $0.title ?? ""),
                        y: .value("Rate", rate)
                    )
                }
                .frame(height: 250)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isPeriodPresented.toggle() }) {
                    Text(period.title)
                        .foregroundColor(Color("Color"))
                        .font(.system(.body, design: .monospaced))
                }
                .confirmationDialog("Select a period", isPresented: $isPeriodPresented, titleVisibility: .visible) {
                    ForEach(Period.allCases) { period in
                        Button(period.title) {
                            self.period = period
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
        }
        .navigationTitle("Stats")
    }
}

struct StatsPreview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatsView()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}