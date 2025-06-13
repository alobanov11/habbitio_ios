import SwiftUI
import Contracts

struct ArchiveRoute: View {

	struct UseCase {

		var loadHabits: () async throws -> [Habit]
	}

	@Environment(\.context.archive)
	var useCase

	@State
	var habits: [Habit] = []

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
							Text(String(localized: "ARCHIVE_TITLE"))
								.largeTitle(.textPrimary)
								.maxWidth(.leading)

							Text(String(localized: "ARCHIVE_SUBTITLE"))
								.body(.textSecondary)
								.maxWidth(.leading)
						}
						.padding(.horizontal, 24)
						.padding(.bottom, 12)

						if habits.isEmpty {
							empty
						} else {
							content
						}
					}
				}
			}
		}
		.navigationBarHidden(true)
		.onAppear {
			Task {
				do {
					habits = try await useCase.loadHabits()
				} catch {
					self.error = error
				}
			}
		}
	}

	var empty: some View {
		Text(String(localized: "ARCHIVE_EMPTY"))
			.multilineTextAlignment(.center)
			.footnote(.textSecondary)
			.maxHeight(.center)
			.padding(.horizontal, 24)
			.padding(.vertical, 200)
	}

	@ViewBuilder
	var content: some View {
		let sections = habits.reduce(into: [String: [Habit]]()) { result, habit in
			let category = habit.category ?? String(localized: "COMMON_UNCATEGORIZED")
			result[category, default: []].append(habit)
		}.map { ($0.key, $0.value) }.sorted { $0.0 < $1.0 }

		LazyVStack(spacing: 16) {
			ForEach(sections, id: \.0) { section, habits in
				VStack(alignment: .leading, spacing: 2) {
					Text(section)
						.title3(.textSecondary)
						.maxWidth(.leading)
						.padding(.horizontal, 16)
						.padding(.bottom, 8)

					ForEach(habits, id: \.self) { habit in
						NavigationLink {
							HabitEditRoute(habit: habit)
						} label: {
							HStack {
								Text(habit.title)
									.headline(.textPrimary)

								Spacer()

								Text(habit.createdDate, style: .date)
									.footnote(.textSecondary)
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
				.padding(.horizontal, 8)
			}
		}
	}
}

extension ArchiveRoute.UseCase {

	init(store: IStore) {
		loadHabits = {
			try await store.fetchArchiveHabits()
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
	}
}

#Preview {
	NavigationView {
		ArchiveRoute()
	}
}
