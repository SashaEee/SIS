//
//  ProfileViewController.swift
//  SIS
//
//  Created by Sasha on 5/10/21.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import IRPasscode_swift

struct Section{
    let title: String
    let options: [SettingsOption]
}

struct SettingsOption{
    let title: String
    let icon: UIImage?
    let iconBackgroundColour: UIColor
    let handler: (() -> Void)
}

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Таблица
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsTableViewCell.identifer,
            for: indexPath) as? SettingsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.section].options[indexPath.row]
        model.handler()
    }

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifer)
        return table
    }()
    var models = [Section]()
    

    func configure(){
        if(isTeacher == 0){
            models.append(Section(title: "Настройки студента", options: [
                SettingsOption(title: "Количество посещений", icon: UIImage(systemName: "graduationcap"), iconBackgroundColour: .systemIndigo){
                self.nextNavView(idView: "stat")
                }
            ]))
        }
        if(isTeacher == 1){
            models.append(Section(title: "Настройки преподавателя", options: [
                SettingsOption(title: "Список присутствующих", icon: UIImage(systemName: "graduationcap"), iconBackgroundColour: .systemIndigo){
                }
            ]))
        }
        models.append(Section(title: "Общие настройки", options: [
            SettingsOption(title: "Уведомления", icon: UIImage(systemName: "bell.badge"), iconBackgroundColour: .systemRed){
            self.nextNavView(idView: "notif")
            },
            SettingsOption(title: "Безопасность", icon: UIImage(systemName: "lock"), iconBackgroundColour: .systemPink){
            let xibBundle = Bundle.init(for: IRPasscodeLockSettingViewController.self)
            let vc = IRPasscodeLockSettingViewController.init(nibName: "IRPasscodeLockSettingViewController", bundle: xibBundle)
            self.navigationController?.pushViewController(vc, animated: true)
        },
            SettingsOption(title: "Внешний вид", icon: UIImage(systemName: "paintbrush.pointed"), iconBackgroundColour: .systemGreen){
            self.nextNavView(idView: "design")
            },
            SettingsOption(title: "Язык", icon: UIImage(systemName: "globe.asia.australia"), iconBackgroundColour: .systemOrange){
            self.nextNavView(idView: "lang")
            }
            ]))

            }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    func nextNavView(idView: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: idView)
         navigationController?.pushViewController(vc,
         animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        title = "Settings"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
    }
    


}
