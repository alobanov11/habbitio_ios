import SwiftUI
import Charts
import Contracts

struct StatsRoute: View {

	enum Period: Int, Identifiable, CaseIterable {

		case week = 7
		case month = 30
		case year = 365
		case all

		var id: Int { self.rawValue }

		var title: String {
			switch self {
			case .week: return String(localized: "STATS_PERIOD_WEEK")
			case .month: return String(localized: "STATS_PERIOD_MONTH")
			case .year: return String(localized: "STATS_PERIOD_YEAR")
			case .all: return String(localized: "STATS_PERIOD_ALL")
			}
		}
	}

	struct UseCase {

		var loadHabits: () async throws -> [Habit]
		var loadReports: () async throws -> [Report]
	}

	@Environment(\.context.stats)
	var useCase

	@State
	var habits: [Habit] = []

	@State
	var reports: [Report] = []

	@AppStorage("stats_period")
	var period: Period = .all

	@State
	var error: Error?

	var body: some View {
		ZStack {
			Color.backgroundPrimary.ignoresSafeArea()

			VStack(spacing: 16) {
				NavigationBar()

				ScrollView {
					VStack(spacing: 16) {
						VStack(spacing: 12) {
							Text(String(localized: "STATS_TITLE"))
								.largeTitle(.textPrimary)
								.maxWidth(.leading)

							Text(String(localized: "STATS_SUBTITLE"))
								.body(.textSecondary)
								.maxWidth(.leading)
						}
						.padding(.horizontal, 24)
						.padding(.bottom, 12)

						if habits.isEmpty || reports.isEmpty {
							empty
						} else {
							content
						}
					}
				}
			}
		}
		.overlay(alignment: .bottom) {
			if !habits.isEmpty && !reports.isEmpty {
				TabsView(period: $period)
					.safeAreaPadding(.bottom)
			}
		}
		.navigationBarHidden(true)
		.onAppear {
			Task {
				do {
					habits = try await useCase.loadHabits()
					reports = try await useCase.loadReports()
				} catch {
					self.error = error
				}
			}
		}
	}

	var empty: some View {
		Text(String(localized: "STATS_EMPTY"))
			.multilineTextAlignment(.center)
			.footnote(.textSecondary)
			.maxHeight(.center)
			.padding(.horizontal, 24)
			.padding(.vertical, 200)
	}

	@ViewBuilder
	var content: some View {
		VStack(spacing: 8) {
			reportsChart
			reportByWeekdays
			habitsChart
		}
		.padding(.horizontal, 16)
		.padding(.bottom, 100)
	}

	var reportsChart: some View {
		Chart(reports.suffix(period.rawValue)) {
			LineMark(
				x: .value("Date", $0.date),
				y: .value("Rate", $0.rate)
			)
			.foregroundStyle(Color.backgroundAccent)
			.interpolationMethod(.catmullRom)

			AreaMark(
				x: .value("Date", $0.date),
				y: .value("Rate", $0.rate)
			)
			.foregroundStyle(
				LinearGradient(
					colors: [Color.backgroundAccent.opacity(0.3), Color.backgroundAccent.opacity(0)],
					startPoint: .top,
					endPoint: .bottom
				)
			)
			.interpolationMethod(.catmullRom)
		}
		.frame(height: 160)
		.padding(24)
		.background(
			RoundedRectangle(cornerRadius: 24)
				.fill(Color.backgroundTertiary)
		)
		.chartYAxis {
			AxisMarks(position: .leading) { _ in
				AxisGridLine()
				AxisValueLabel()
					.font(.mailSansRoman(10))
			}
		}
		.chartXAxis {
			AxisMarks { _ in
				AxisValueLabel()
					.font(.mailSansRoman(10))
			}
		}
	}

	@ViewBuilder
	var reportByWeekdays: some View {
		let weekdayStats = reports.rateByWeekdays(period: period.rawValue)
		Chart(Calendar.current.shortWeekdaySymbols.indices, id: \.self) {
		  BarMark(
			x: .value("Name", Calendar.current.shortWeekdaySymbols[$0]),
			y: .value("Total", weekdayStats[$0])
		  )
		  .foregroundStyle(Color.backgroundAccent)
		  .cornerRadius(4)
		}
		.frame(height: 160)
		.padding(24)
		.background(
			RoundedRectangle(cornerRadius: 24)
				.fill(Color.backgroundTertiary)
		)
		.chartYAxis {
			AxisMarks(position: .leading) { _ in
				AxisGridLine()
				AxisValueLabel()
					.font(.mailSansRoman(10))
			}
		}
		.chartXAxis {
			AxisMarks { _ in
				AxisValueLabel()
					.font(.mailSansRoman(10))
			}
		}
	}

	var habitsChart: some View {
		Chart(habits) {
			BarMark(
				x: .value(
					"Name",
					$0.title
				),
				y: .value(
					"Total",
					reports.rateByHabit(habit: $0, period: period.rawValue)
				)
			)
			.foregroundStyle(Color.backgroundAccent)
			.cornerRadius(4)
		}
		.frame(height: 160)
		.padding(24)
		.background(
			RoundedRectangle(cornerRadius: 24)
				.fill(Color.backgroundTertiary)
		)
		.chartYAxis {
			AxisMarks(position: .leading) { _ in
				AxisGridLine()
				AxisValueLabel()
					.font(.mailSansRoman(10))
			}
		}
		.chartXAxis {
			AxisMarks { _ in
				AxisValueLabel()
					.font(.mailSansRoman(10))
			}
		}
	}
}

extension StatsRoute {

	struct TabsView: View {

		@Binding
		var period: StatsRoute.Period

		var body: some View {
			HStack(spacing: 4) {
				ForEach(StatsRoute.Period.allCases) { period in
					Button {
						withAnimation {
							self.period = period
						}
					} label: {
						Text(
							self.period == period
								? period.title
								: String(period.title.prefix(1)).uppercased()
						)
						.callout(
							self.period == period
								? .textPrimaryInvariably
								: .textSecondary
						)
						.fixedSize()
						.padding(16)
						.frame(minWidth: 56)
						.background(
							RoundedRectangle(cornerRadius: 48)
								.fill(
									self.period == period
										? Color.backgroundAccentAlternative
										: Color.backgroundTertiary
								)
						)
					}
					.buttonStyle(ScaleButtonStyle())
				}
			}
		}
	}
}

extension StatsRoute.UseCase {

	init(store: IStore) {
		loadHabits = {
			try await store.fetchHabits()
		}
		loadReports = {
			try await store.fetchReports()
		}
	}

	init() {
		loadHabits = {
			[
				Habit(
					title: "Exercise",
					category: "Work",
					days: Array(Calendar.current.shortWeekdaySymbols[0..<2]),
					isArchived: true,
					isRemainderOn: false,
					reminderDate: nil,
					reminderText: nil
				)
			]
		}
		loadReports = {
			[
				Report(
					date: Date(),
					records: [
						Record(
							date: Date(),
							habit: Habit(
								title: "Water Intake",
								category: "Health",
								days: Array(Calendar.current.shortWeekdaySymbols[0..<2]),
								isArchived: false,
								isRemainderOn: false,
								reminderDate: nil,
								reminderText: nil
							),
							isEnabled: true,
							done: false
						),
						Record(
							date: Date(),
							habit: Habit(
								title: "Exercise",
								category: "Work",
								days: Array(Calendar.current.shortWeekdaySymbols[0..<2]),
								isArchived: false,
								isRemainderOn: false,
								reminderDate: nil,
								reminderText: nil
							),
							isEnabled: false,
							done: true
						)
					]
				)
			]
		}
	}
}

#Preview {
	NavigationView {
		StatsRoute()
	}
}
