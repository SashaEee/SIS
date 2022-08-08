//
//  StaticViewController.swift
//  StaticViewController
//
//  Created by Sasha on 10/13/21.
//

import UIKit
import Alamofire
import SwiftyJSON



class Lessons : NSObject, NSCoding{

    var byTeacher : String!
    var date : String!
    var disc : String!
    var duration : String!
    var status : String!
    var timeIn : String!
    var timeOut : String!

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        byTeacher = json["by_teacher"].stringValue
        date = json["date"].stringValue
        disc = json["disc"].stringValue
        duration = json["duration"].stringValue
        status = json["status"].stringValue
        timeIn = json["time_in"].stringValue
        timeOut = json["time_out"].stringValue
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if byTeacher != nil{
            dictionary["by_teacher"] = byTeacher
        }
        if date != nil{
            dictionary["date"] = date
        }
        if disc != nil{
            dictionary["disc"] = disc
        }
        if duration != nil{
            dictionary["duration"] = duration
        }
        if status != nil{
            dictionary["status"] = status
        }
        if timeIn != nil{
            dictionary["time_in"] = timeIn
        }
        if timeOut != nil{
            dictionary["time_out"] = timeOut
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
        byTeacher = aDecoder.decodeObject(forKey: "by_teacher") as? String
        date = aDecoder.decodeObject(forKey: "date") as? String
        disc = aDecoder.decodeObject(forKey: "disc") as? String
        duration = aDecoder.decodeObject(forKey: "duration") as? String
        status = aDecoder.decodeObject(forKey: "status") as? String
        timeIn = aDecoder.decodeObject(forKey: "time_in") as? String
        timeOut = aDecoder.decodeObject(forKey: "time_out") as? String
    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
    {
        if byTeacher != nil{
            aCoder.encode(byTeacher, forKey: "by_teacher")
        }
        if date != nil{
            aCoder.encode(date, forKey: "date")
        }
        if disc != nil{
            aCoder.encode(disc, forKey: "disc")
        }
        if duration != nil{
            aCoder.encode(duration, forKey: "duration")
        }
        if status != nil{
            aCoder.encode(status, forKey: "status")
        }
        if timeIn != nil{
            aCoder.encode(timeIn, forKey: "time_in")
        }
        if timeOut != nil{
            aCoder.encode(timeOut, forKey: "time_out")
        }

    }

}


class StaticStudentViewController: UIViewController{
    struct Item {
        let disc, user, group, timeOut: String
        let duration, status, byTeacher: String
    }
    fileprivate var items = [Item]()

    
    struct Section{
        let letter : String
        let names : [String]
    }
    
    @IBOutlet weak var tableView: UITableView!

    var usernames = [""]

    var sections = [Section]()
    var date = [""]

            
    let identifire = "myCell"
    
    override func viewDidLoad() {
        getStat()
        super.viewDidLoad()
        createTableView()
    }
    func createTableView(){
        
        // group the array to ["N": ["Nancy"], "S": ["Sue", "Sam"], "J": ["John", "James", "Jenna"], "E": ["Eric"]]
        let groupedDictionary = Dictionary(grouping: usernames, by: {String($0.prefix(1))})
        // get the keys and sort them
        let keys = groupedDictionary.keys.sorted()
        // map the sorted keys to a struct
        sections = keys.map{ Section(letter: $0, names: groupedDictionary[$0]!.sorted()) }
        self.tableView.reloadData()


        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifire)
        
        tableView.delegate = self
        
        tableView.dataSource = self

    }
    
    func getStat(){
        let url = "http://54.189.168.253/user/get_stat?id=" + studID!
        print(url)
        AF.request(url, method: .get).responseData { [self] response in
            switch response.result {
            case .success(_):
                var json = JSON(response.value!)
                json = JSON(json)
                print(json[0])
                usernames = []
                var n = 0
                for i in json {
                    let user = RootClass(fromJson: json[n])
                    usernames.append(user.disc)
                    date.append(user.date)
                    print(usernames)
                    print(date)
                    n+=1
                    createTableView()
                }
//                print(json)
                // Getting a string from a JSON Dictionary
            case .failure(_):
                print("Ошибка при запросе данных \(String(describing: response.error))")
                return
            }
        }
        print(usernames)

    }
}

extension StaticStudentViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 44
    }
}

extension StaticStudentViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].letter
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifire)

        let section = sections[indexPath.section]
        let username = section.names[indexPath.row]
        cell.textLabel?.text = username
        cell.detailTextLabel?.text = "2021-10-29"
        return cell
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map{$0.letter}

    }
}