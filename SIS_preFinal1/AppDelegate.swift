//
//  AppDelegate.swift
//  QR Codes
//
//  Created by Kyle Howells on 31/12/2019.
//  Copyright © 2019 Kyle Howells. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

var firstName: String?
var secondName: String?
var lastName: String?
var formLearn: String?
var studID: String?
var speciality: String?
var levelLearn: String?
var stGroup: String?
var email: String?
var email2: String?
var grade: String?
var isTeacher: Int?
var group: String?
var middlename: String?
var UID: String?
var ImageURL: String?
var avatar: UIImage?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var modeDescriptionViewController: UIViewController!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        let currentUser = Auth.auth().currentUser
        
        if currentUser != nil {
        print("Пользователь авторизован")
            authSfedu()
            getFireBase()
        } else { print("Пользователь не авторизован") }
        Thread.sleep(forTimeInterval: 2.0)
        registerForPushNotifications()
        
        return true
	}
    
    

 	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
    func getFireBase(){ //Получаем данные с FireBase
        let user = Auth.auth().currentUser
        if let user = user {
            email = user.email
        db.collection("users").whereField("email", isEqualTo: email!)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            ImageURL = document.get("avatarURL") as? String
                            firstName = document.get("firstname") as? String
                            lastName = document.get("lastname") as? String
                            studID = document.get("studID") as? String
                            let url = URL(string: ImageURL!)
                            print(ImageURL!)
                            if let data = try? Data(contentsOf: url!)
                            {
                                avatar = UIImage(data: data)
                                print ("ГОТОВОООООО")
                            }
                        }
                    }
            }
        }
    }
    func authSfedu(){
        if (email2 != nil) {email = email2}
        let user = "projectoffice"
        let password = "q90h5ju4"
        let usr = Auth.auth().currentUser
        if let usr = usr {
            email = usr.email
        }
        if (email2 != nil) {email = email2}

        let headers: HTTPHeaders = [.authorization(username: user, password: password)]
        
        let url = "http://api.sync.ictis.sfedu.ru/find/student/email?email=" + email!
        //let url = "http://api.sync.ictis.sfedu.ru/find/student/email?email=azenkovskii@sfedu.ru"
        print ("url \(url)")
        AF.request(url,
                   headers: headers)
            .responseData { response in
            }
            .responseJSON { response in

                let json = JSON(response.data as Any)
                print(json)
                guard let data = response.data else {return}
                do
                {
                    let student = try JSONDecoder().decode(UserData.self, from: data)
                    firstName = student.student.firstName
                    lastName = student.student.lastName
                    secondName = student.student.secondName
                    stGroup = student.student.stGroup
                    studID = student.student.studID
                    grade = String(student.student.grade)
                    isTeacher = student.student.isTeacher
                    levelLearn = student.student.levelLearn
                    print (UserData.self)
                    print(student)
                    self.requestParse()
                }
                catch {
                    print("1")
                }
            }
        
        func cropImage(image: UIImage, toRect: CGRect) -> UIImage? {
            // Cropping is available trhough CGGraphics
            let cgImage :CGImage! = image.cgImage
            let croppedCGImage: CGImage! = cgImage.cropping(to: toRect)

            return UIImage(cgImage: croppedCGImage)
        }
        

    }
    func requestParse(){
            let url1 = "http://ictis.sfedu.ru/schedule-api/?query=" + "КТ" + "\(levelLearn![(levelLearn?.startIndex)!])" + "о" + grade! + "-" + stGroup!
        let url = url1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        AF.request(String(url!)).responseJSON { response in
            let json = JSON(response.data as Any)
            print(json)
            guard let data = response.data else {return}
            do
            {
                let call = try JSONDecoder().decode(Callendar.self, from: data)
                print(call)
                rasp = call.table.table
            }
            catch {
                print("1")
            }

        }
        .responseString{
            response in
            JSON1 = response.value
            print("JSONNNNNN: \(String(describing: JSON1))")
            
        }

    }
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
        (granted, error) in
        print("Permission granted: \(granted)")

        guard granted else { return }
        self.getNotificationSettings()
      }
    }

    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { (settings) in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      let tokenParts = deviceToken.map { data -> String in
        return String(format: "%02.2hhx", data)
      }
      
      let token = tokenParts.joined()
      print("Device Token: \(token)")
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Failed to register: \(error)")
    }


    


}

