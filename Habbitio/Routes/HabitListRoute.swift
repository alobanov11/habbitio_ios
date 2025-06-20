import SwiftUI
import Contracts

struct HabitListRoute: View {

	struct UseCase {

		var invalidateNotifications: () async throws -> Void
		var loadReport: () async throws -> Report
		var toggleRecord: (Record) async throws -> Void
	}

	@AppStorage("isNotificationsInvalidated")
	var isNotificationsInvalidated = false

	@Environment(\.context.habitList)
	var useCase

	@State
	var report: Report?

	@State
	var error: Error?

	@State
	var toastError: Error?

	var body: some View {
		ZStack {
			Color.backgroundPrimary.ignoresSafeArea()

			VStack(spacing: 16) {
				NavigationBar {
					Text(String(localized: "HABIT_LIST_TITLE"))
						.largeTitle(.textPrimary)
						.maxWidth(.leading)
				}

				if let report, report.records.isEmpty {
					Text(String(localized: "HABIT_LIST_EMPTY"))
						.multilineTextAlignment(.center)
						.footnote(.textSecondary)
						.maxHeight(.center)
						.padding(.horizontal, 24)
						.padding(.bottom, 100)
				} else if let report {
					ScrollView {
						let sections = report.records.reduce(
							into: [String: [Record]]()
						) { result, record in
							let category = record.habit.category ?? String(localized: "COMMON_UNCATEGORIZED")
							result[category, default: []].append(record)
						}.map { ($0.key, $0.value) }.sorted { $0.0 < $1.0 }

						LazyVStack(spacing: 16) {
							ForEach(sections, id: \.0) { section, records in
								VStack(alignment: .leading, spacing: 2) {
									Text(section)
										.headline(.textSecondary)
										.maxWidth(.leading)
										.padding(.horizontal, 16)
										.padding(.bottom, 8)

									let sortedRecords = records.sorted { $0.habit.title < $1.habit.title }

									ForEach(sortedRecords, id: \.self) { record in
										RecordRow(record: record) {
											do {
												try await useCase.toggleRecord(record)
												if let index = report.records.firstIndex(of: record) {
													withAnimation {
														self.report?.records[index].done.toggle()
													}
												}
											} catch {
												withAnimation {
													toastError = error
												}
											}
										}
									}
								}
								.padding(.horizontal, 8)
								.padding(.bottom, 8)
							}
						}
					}
				} else {
					Spacer()
				}
			}
		}
		.toast(error: $toastError, success: .constant(nil))
		.overlay(alignment: .center) {
			if report == nil {
				ProgressView()
			}
		}
		.overlay(alignment: .bottom) {
			TabsView()
				.safeAreaPadding(.bottom)
		}
		.onForeground {
			Task {
				do {
					report = try await useCase.loadReport()
				} catch {
					withAnimation {
						self.error = error
					}
				}
			}
		}
		.onAppear {
			Task {
				do {
					report = try await useCase.loadReport()
					if !isNotificationsInvalidated {
						try? await useCase.invalidateNotifications()
						isNotificationsInvalidated = true
					}
				} catch {
					withAnimation {
						self.error = error
					}
				}
			}
		}
	}
}

private extension HabitListRoute {

	struct RecordRow: View {

		var record: Record
		var onToggle: () async -> Void

		var body: some View {
			NavigationLink {
				HabitEditRoute(habit: record.habit)
			} label: {
				HStack {
					Text(record.habit.title)
						.headline(.textPrimary)

					Spacer()

					if record.isEnabled {
						Button {
							Task {
								await onToggle()
							}
						} label: {
							Image(systemName: record.done ? "checkmark.circle.fill" : "circle")
								.foregroundColor(record.done ? .textPrimary : .textSecondary)
								.font(.system(size: 24, design: .rounded))
								.padding(8)
								.clipShape(Rectangle())
						}
						.padding(-8)
						.buttonStyle(ScaleButtonStyle())
					}
				}
				.padding(.horizontal, 24)
				.frame(height: 52)
				.background(
					RoundedRectangle(cornerRadius: 24)
						.fill(Color.backgroundTertiary)
				)
			}
			.buttonStyle(ScaleButtonStyle())
		}
	}

	struct TabsView: View {

		var body: some View {
			HStack(spacing: 4) {
				NavigationLink {
					ArchiveRoute()
				} label: {
					Image(systemName: "archivebox")
						.font(.system(size: 17, design: .rounded))
						.foregroundColor(.textPrimary)
						.padding(16)
						.frame(minWidth: 56)
						.background(
							RoundedRectangle(cornerRadius: 48)
								.fill(Color.backgroundSecondary)
						)
				}
				.buttonStyle(ScaleButtonStyle())

				NavigationLink {
					StatsRoute()
				} label: {
					Image(systemName: "chart.pie.fill")
						.font(.system(size: 17, design: .rounded))
						.foregroundColor(.textPrimary)
						.padding(16)
						.frame(minWidth: 56)
						.background(
							RoundedRectangle(cornerRadius: 48)
								.fill(Color.backgroundSecondary)
						)
				}
				.buttonStyle(ScaleButtonStyle())

				NavigationLink {
					HabitEditRoute()
				} label: {
					HStack(spacing: 8) {
						Image(systemName: "plus.circle")
							.font(.system(size: 17, design: .rounded))
							.foregroundColor(.textPrimaryInvariably)

						Text(String(localized: "COMMON_CREATE"))
							.callout(.textPrimaryInvariably)
					}
					.padding(16)
					.frame(minWidth: 56)
					.background(
						RoundedRectangle(cornerRadius: 48)
							.fill(Color.backgroundAccentAlternative)
					)
				}
				.buttonStyle(ScaleButtonStyle())
			}
		}
	}
}

extension HabitListRoute.UseCase {

	init(store: IStore, habitNotificationService: IHabitNotificationService) {
		loadReport = {
			try await store.report()
		}
		toggleRecord = { record in
			var record = record
			record.done.toggle()
			try await store.saveRecord(record)
		}
		invalidateNotifications = {
			let habits = try await store.fetchHabits()
			for var habit in habits {
				habit.notifications = try await habitNotificationService.scheduleNotifications(for: habit)
				try await store.saveHabit(habit)
			}
		}
	}

	init() {
		loadReport = {
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
		}
		toggleRecord = { _ in }
		invalidateNotifications = {}
	}
}


#Preview {
	NavigationStack {
		HabitListRoute()
			.navigationStackRootPage()
	}
}
