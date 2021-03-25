//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Boris Ezhov on 17.01.2021.
//

import Foundation
import UserNotifications

private let dateFormatter: DateFormatter = {
  let dateFormatter = DateFormatter()
  dateFormatter.dateStyle = .short
  return dateFormatter
}()

class ChecklistItem: Equatable, Codable {
  var id: UUID
  var name: String
  var isChecked: Bool
  var shouldRemind: Bool
  var dueDate: Date
  var dueDateString: String {
    dateFormatter.string(from: dueDate)
  }

  init(name: String, isChecked: Bool = false, shouldRemind: Bool = false, dueDate: Date = Date()) {
    self.id = UUID()
    self.name = name
    self.isChecked = isChecked
    self.shouldRemind = shouldRemind
    self.dueDate = dueDate
  }

  deinit {
    removeNotification()
  }

  // Equatable 
  static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
    return lhs.id == rhs.id
  }

  // MARK: - Notification Methods
  func scheduleNotification() {
    removeNotification()

    if shouldRemind && dueDate > Date() {
      let content = UNMutableNotificationContent()
      content.title = "Reminder:"
      content.body = name
      content.sound = UNNotificationSound.default

      let calendar = Calendar(identifier: .gregorian)
      let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
      let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
      let center = UNUserNotificationCenter.current()
      center.add(request)

      print("Scheduled: \(request) for item with id: \(id)")
    }
  }

  func removeNotification() {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
  }
}
