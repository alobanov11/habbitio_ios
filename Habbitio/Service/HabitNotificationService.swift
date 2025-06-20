import Foundation
import Contracts
import NotificationCenter

protocol IHabitNotificationService {

	func scheduleNotifications(for habit: Habit) async throws -> [String]
}

final class HabitNotificationService: IHabitNotificationService {

	private let notificationCenter: UNUserNotificationCenter

	init(notificationCenter: UNUserNotificationCenter = .current()) {
		self.notificationCenter = notificationCenter
	}

	func scheduleNotifications(for habit: Habit) async throws -> [String] {
		notificationCenter.removePendingNotificationRequests(
			withIdentifiers: habit.notifications
		)

		guard
			habit.isRemainderOn,
			let reminderText = habit.reminderText,
			let reminderDate = habit.reminderDate
		else {
			return []
		}

		let content = UNMutableNotificationContent()
		content.title = habit.title
		content.subtitle = reminderText
		content.sound = .default

		var notifications: [String] = []
		let calendar = Calendar.current
		let weekdaySymbols = calendar.shortWeekdaySymbols

		for indexOfDay in 0..<weekdaySymbols.count {
			if habit.days.contains(weekdaySymbols[indexOfDay]) == false {
				continue
			}

			let id = UUID().uuidString
			let hour = calendar.component(.hour, from: reminderDate)
			let minute = calendar.component(.minute, from: reminderDate)

			var components = DateComponents()
			components.hour = hour
			components.minute = minute
			components.weekday = indexOfDay + 1

			let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
			let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

			try await UNUserNotificationCenter.current().add(request)

			notifications.append(id)
		}

		return notifications
	}
}

