import SwiftUI
import Store

@MainActor
struct Context {

	var habitList: HabitListRoute.UseCase
	var archive: ArchiveRoute.UseCase
	var habitEdit: HabitEditRoute.UseCase
	var stats: StatsRoute.UseCase
}

extension Context {

	init() {
		let store = Store.shared
		let habitNotificationService = HabitNotificationService()
		self.habitList = HabitListRoute.UseCase(
			store: store,
			habitNotificationService: habitNotificationService
		)
		self.archive = ArchiveRoute.UseCase(store: store)
		self.habitEdit = HabitEditRoute.UseCase(
			store: store,
			habitNotificationService: habitNotificationService
		)
		self.stats = StatsRoute.UseCase(store: store)
	}
}

extension EnvironmentValues {

	@MainActor
	private struct ContextKey: @preconcurrency EnvironmentKey {

		static var defaultValue = Context(
			habitList: .init(),
			archive: .init(),
			habitEdit: .init(),
			stats: .init()
		)
	}

	var context: Context {
		get { self[ContextKey.self] }
		set { self[ContextKey.self] = newValue }
	}
}
