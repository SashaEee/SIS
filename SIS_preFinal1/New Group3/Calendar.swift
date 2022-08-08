import UIKit
import CalendarKit


var rasp: [[String]]?
var JSON1: String?
struct Callendar: Decodable {
    let table: Table
    let weeks: [Int]
}
// MARK: - Table
struct Table: Decodable{
    let type, name: String
    let week: Int
    let group: String
    let table: [[String]]
    let link: String
}

class CustomCalendarExampleController: DayViewController {
  
    var data = [["лек.История Вакансия",
                 "LMS"],
                
                ["Математика Клово А. Г. LMS-1 Гамолина И. Э. LMS-1 Ляпунова И. А. LMS-1 Мнухин В. Б. LMS-1"],
                
                ["лек.Введение в инженерную деятельность Рыбальченко М. В.",
                 "LMS"],
                
                ["лаб.Физика- 1 п/г Колпачева О. В.",
                 "Д-409"],
                
                ["лаб.Алгоритмизация и программирование Барковский С. А.",
                 "Д-212"],
                
                ["Основы проектной деятельности Эксакусто Т. В. И-241 Дуганова Ю. К. Г-431 Лабынцева И. С. И-116"],
                
                ["Практикум по подготовке инженерной документации Кумов А. М. LMS"],
                
                ["лаб.Физика- 2 п/г Колпачев А. Б.",
                 "Д-409"],
                
                ["лек.Введение в инженерную деятельность Хусаинов Н. Ш.",
                 "LMS"],
                
    ]

  var generatedEvents = [EventDescriptor]()
  var alreadyGeneratedSet = Set<Date>()
  
  var colors = [UIColor.blue,
                UIColor.yellow,
                UIColor.green,
                UIColor.red]

  private lazy var rangeFormatter: DateIntervalFormatter = {
    let fmt = DateIntervalFormatter()
    fmt.dateStyle = .none
    fmt.timeStyle = .short

    return fmt
  }()

  override func loadView() {
    calendar.timeZone = TimeZone(identifier: "Europe/Paris")!

    dayView = DayView(calendar: calendar)
    view = dayView
  }
    var window: UIWindow?

  override func viewDidLoad() {
    super.viewDidLoad()
    passcode()
//    if let url = URL(string: "webcal://165.22.28.187/schedule-api/calendar/%D0%9A%D0%A2%D0%B1%D0%BE1-10") {
//            if UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url, options: [:])
//            }
//        }
    title = "Расписание"
    navigationController?.navigationBar.isTranslucent = false
    dayView.autoScrollToFirstEvent = true
    reloadData()
            
  }
    func passcode(){
        Utilities.openSecurityPinPage()
    }
  
  // MARK: EventDataSource
  
  override func eventsForDate(_ date: Date) -> [EventDescriptor] {
    if !alreadyGeneratedSet.contains(date) {
      alreadyGeneratedSet.insert(date)
      generatedEvents.append(contentsOf: generateEventsForDate(date))
    }
    return generatedEvents
  }
  
  private func generateEventsForDate(_ date: Date) -> [EventDescriptor] {
    var workingDate = Calendar.current.date(byAdding: .hour, value: Int.random(in: 1...15), to: date)!
    var events = [Event]()
    
    for i in 0...4 {
      let event = Event()

      let duration = Int.random(in: 60 ... 160)
      event.startDate = workingDate
      event.endDate = Calendar.current.date(byAdding: .minute, value: duration, to: workingDate)!

      var info = data[Int(arc4random_uniform(UInt32(data.count)))]
      
      let timezone = dayView.calendar.timeZone
      print(timezone)

      info.append(rangeFormatter.string(from: event.startDate, to: event.endDate))
      event.text = info.reduce("", {$0 + $1 + "\n"})
      event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
      event.isAllDay = Int(arc4random_uniform(2)) % 2 == 0
      event.lineBreakMode = .byTruncatingTail

      events.append(event)
      
      let nextOffset = Int.random(in: 40 ... 250)
      workingDate = Calendar.current.date(byAdding: .minute, value: nextOffset, to: workingDate)!
      event.userInfo = String(i)
    }

    print("Events for \(date)")
    return events
  }
  
  // MARK: DayViewDelegate
  
  private var createdEvent: EventDescriptor?
  
  override func dayViewDidSelectEventView(_ eventView: EventView) {
    guard let descriptor = eventView.descriptor as? Event else {
      return
    }
    print("Event has been selected: \(descriptor) \(String(describing: descriptor.userInfo))")
  }
  
  override func dayViewDidLongPressEventView(_ eventView: EventView) {
    guard let descriptor = eventView.descriptor as? Event else {
      return
    }
    endEventEditing()
    print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
    beginEditing(event: descriptor, animated: true)
    print(Date())
  }
  
  override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
    endEventEditing()
    print("Did Tap at date: \(date)")
  }
  
  override func dayViewDidBeginDragging(dayView: DayView) {
    endEventEditing()
    print("DayView did begin dragging")
  }
  
  override func dayView(dayView: DayView, willMoveTo date: Date) {
    print("DayView = \(dayView) will move to: \(date)")
  }
  
  override func dayView(dayView: DayView, didMoveTo date: Date) {
    print("DayView = \(dayView) did move to: \(date)")
  }
  
  override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
    print("Did long press timeline at date \(date)")
    // Cancel editing current event and start creating a new one
    endEventEditing()
    let event = generateEventNearDate(date)
    print("Creating a new event")
    create(event: event, animated: true)
    createdEvent = event
  }
  
  private func generateEventNearDate(_ date: Date) -> EventDescriptor {
    let duration = Int(arc4random_uniform(160) + 60)
    let startDate = Calendar.current.date(byAdding: .minute, value: -Int(CGFloat(duration) / 2), to: date)!
    let event = Event()

    event.startDate = startDate
    event.endDate = Calendar.current.date(byAdding: .minute, value: duration, to: startDate)!
    
    var info = data[Int(arc4random_uniform(UInt32(data.count)))]

    info.append(rangeFormatter.string(from: event.startDate, to: event.endDate))
    event.text = info.reduce("", {$0 + $1 + "\n"})
    event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
    event.editedEvent = event

    return event
  }
  
  override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
    print("did finish editing \(event)")
    print("new startDate: \(event.startDate) new endDate: \(event.endDate)")
    
    if let _ = event.editedEvent {
      event.commitEditing()
    }
    
    if let createdEvent = createdEvent {
      createdEvent.editedEvent = nil
      generatedEvents.append(createdEvent)
      self.createdEvent = nil
      endEventEditing()
    }
    
    reloadData()
  }
}
