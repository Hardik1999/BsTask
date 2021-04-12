//
//  CustomTabViewController.swift
//  BS TASK
//
//  Created by Hardik on 1/19/21.
//  Copyright © 2021 macbook. All rights reserved.
//

import UIKit
import STTabbar

class CustomTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let myTabbar = tabBar as? STTabbar {
            myTabbar.centerButtonActionHandler = {
                print("Center Button Tapped")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoiceViewController") as! VoiceViewController
                self.present(vc, animated: true, completion: nil)
            }
        }
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
