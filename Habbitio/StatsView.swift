import Charts
import SwiftData
import SwiftUI

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

  @Environment(\.modelContext) private var modelContext

  @Query(sort: \Report.date)
  private var reports: [Report]

  @Query(
    filter: #Predicate<Habit> { $0.isArchived == false }
  )
  private var habits: [Habit]

  @State private var period: Period = .week
  @State private var isPeriodPresented = false

  var body: some View {
    List {
      Section {
        Chart(reports.suffix(period.rawValue)) {
          LineMark(
            x: .value("Date", $0.date),
            y: .value("Rate", $0.rate)
          )
        }
        .frame(height: 250)
      }

      Section {
        let weekdayStats = Report.rateByWeekdays(reports.suffix(period.rawValue))
        Chart(Calendar.current.shortWeekdaySymbols.indices, id: \.self) {
          BarMark(
            x: .value("Name", Calendar.current.shortWeekdaySymbols[$0]),
            y: .value("Total", weekdayStats[$0])
          )
        }
        .frame(height: 250)
      }

      Section {
        Chart(habits) {
          BarMark(
            x: .value("Name", $0.title),
            y: .value("Total", $0.rate(for: period.rawValue))
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
        .confirmationDialog(
          "Select a period", isPresented: $isPeriodPresented, titleVisibility: .visible
        ) {
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
    .modelContainer(DataManager.preview.modelContainer)
  }
}
