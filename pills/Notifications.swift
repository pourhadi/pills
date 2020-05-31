//
//  Notifications.swift
//  pills
//
//  Created by dan on 11/10/19.
//  Copyright © 2019 dan. All rights reserved.
//

import UIKit
import UserNotifications

class Notifications {

    static func reschedule() {
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.removeAllPendingNotificationRequests()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (60*60*3), repeats: false)

        let content = UNMutableNotificationContent()
        content.title = "Three Hours"
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
    }
    
}
