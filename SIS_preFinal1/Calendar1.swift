//
//  Calendar1.swift
//  SIS
//
//  Created by Sasha on 8/10/21.
//

import UIKit
import CalendarKit
import EventKit
import UserNotifications



class CustomCalendarExampleController1: DayViewController {
    
    private let eventStore = EKEventStore()
  
  override func viewDidLoad() {
    if let url = URL(string: "webcal://165.22.28.187/schedule-api/calendar/%D0%9A%D0%A2%D0%B1%D0%BE1-10") {
          if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url, options: [:])
          }
      }

    super.viewDidLoad()
//    passcode()
    requestAccessToCallendar()
    title = "Расписание"
      navigationController?.navigationBar.isTranslucent = true
    subscribeToNotifications()
  }
    func passcode(){
        Utilities.openSecurityPinPage()
    }
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storeChanged(_:)),
                                               name: .EKEventStoreChanged,
                                               object: eventStore)
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        reloadData()
    }
    func requestAccessToCallendar(){
        eventStore.requestAccess(to: .event) { success, error in
        }
        
    }
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!
        let predicate = eventStore.predicateForEvents(withStart: startDate,
                                                      end: endDate,
                                                      calendars: nil)
        let eventKitEvents = eventStore.events(matching: predicate)
        let calendarKitEvents = eventKitEvents.map { EKEvent -> Event in
            let ckEvent = Event()
            ckEvent.startDate = EKEvent.startDate
            ckEvent.endDate = EKEvent.endDate
            ckEvent.isAllDay = EKEvent.isAllDay
            ckEvent.text = EKEvent.title
            if let eventColor = EKEvent.calendar.cgColor{
                ckEvent.color = UIColor(cgColor: eventColor)
            }
            return ckEvent
        }
        return calendarKitEvents
    }
}
