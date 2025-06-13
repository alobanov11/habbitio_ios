import Foundation

public struct Record: Hashable, Sendable {

    public var date: Date
    public var habit: Habit
    public var isEnabled: Bool
	public var done: Bool

    public init(
		date: Date,
		habit: Habit,
		isEnabled: Bool,
		done: Bool
	) {
        self.date = date
        self.habit = habit
        self.isEnabled = isEnabled
		self.done = done
    }
}
