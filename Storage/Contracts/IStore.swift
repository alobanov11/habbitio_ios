import Foundation

public protocol IStore {

    func fetchArchiveHabits() async throws -> [Habit]

    func fetchHabits() async throws -> [Habit]

    func fetchReports() async throws -> [Report]

    func saveHabit(_ habit: Habit) async throws

    func deleteHabit(_ habit: Habit) async throws

    func report() async throws -> Report

    func saveRecord(_ record: Record) async throws
}

