//
//  PasswordSettingsViewController.swift
//  SIS
//
//  Created by Sasha on 7/24/21.
//

import UIKit
import IRPasscode_swift

class PasswordSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let xibBundle = Bundle.init(for: IRPasscodeLockSettingViewController.self)
        let vc = IRPasscodeLockSettingViewController.init(nibName: "IRPasscodeLockSettingViewController", bundle: xibBundle)
        self.navigationController?.pushViewController(vc, animated: true)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
