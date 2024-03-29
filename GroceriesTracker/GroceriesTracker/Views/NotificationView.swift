//
//  NotificationView.swift
//  GroceriesTracker
//
//  Created by Sophia on 4/19/21.
//

import Foundation
import UserNotifications
import SwiftUI

// used for notifications
// for demo purposes, sets the time of notification to one min from
// current time (demo for if the expiration time is 0 days/months/weeks/years)
struct NotificationView: View {
  var notificationCenter:UNUserNotificationCenter!
  var notificationDelegate: UNUserNotificationCenterDelegate
  
  init() {
    self.notificationCenter = UNUserNotificationCenter.current()
    self.notificationDelegate = NotificationDelegate()
    setupNotification()
  }
  
  func setupNotification() {
    let options:UNAuthorizationOptions = [.alert, .sound]
    notificationCenter.requestAuthorization(options: options, completionHandler: {
       success, error in
        guard success == true else { print("Access not granted or error"); return }
        print("notification access granted")
    })
  }
  
  func setupAndFireNotification(date: DateComponents, item: String) {
    
    let options:UNAuthorizationOptions = [.alert, .sound]
    notificationCenter.requestAuthorization(options: options, completionHandler: {
       success, error in
        guard success == true else { print("Access not granted or error"); return }
        print("notification access granted")
    })
    
    let content = UNMutableNotificationContent()
    content.title = "Item Expiring: " + item
    content.body = "Consume or dispose of your food!"
    content.sound = UNNotificationSound.default
    
    let categoryId = "edu.jhu.epp.Grade-Notification-Interface.notification"

    let category = UNNotificationCategory(identifier: categoryId, actions: [], intentIdentifiers: [], options: [])
    notificationCenter.setNotificationCategories([category])

    content.categoryIdentifier = categoryId
    
    //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
    print(date)

    let notification = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    notificationCenter.add(notification, withCompletionHandler:
    {
        error in
        if let error = error
        {
            print("Error firing notification: \(error.localizedDescription)")
        }
        print("adding to center")
    })
  }
  
  var body: some View {
    EmptyView()
  }
  
}


class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
  
  override init() {
    super.init()
    UNUserNotificationCenter.current().delegate = self
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

    print("got notification in foreground")
    print("notification content \(notification.request.content.title)")
    completionHandler([.banner,.sound])

  }
}
