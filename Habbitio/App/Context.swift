import SwiftUI
import Contracts

@MainActor
struct Context {

	var habitList = HabitListRoute.UseCase()
	var archive = ArchiveRoute.UseCase()
	var habitEdit = HabitEditRoute.UseCase()
	var stats = StatsRoute.UseCase()
}

extension Context {

	init(store: IStore) {
		self.habitList = HabitListRoute.UseCase(store: store)
		self.archive = ArchiveRoute.UseCase(store: store)
		self.habitEdit = HabitEditRoute.UseCase(store: store)
		self.stats = StatsRoute.UseCase(store: store)
	}
}

extension EnvironmentValues {

	@MainActor
	private struct ContextKey: @preconcurrency EnvironmentKey {

		static var defaultValue = Context()
	}

	var context: Context {
		get { self[ContextKey.self] }
		set { self[ContextKey.self] = newValue }
	}
}
