//
//  FirstButtonBarViewController.swift
//  BS TASK
//
//  Created by Hardik on 1/18/21.
//  Copyright © 2021 macbook. All rights reserved.
//

import UIKit

class FirstButtonBarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onClickPush(_ sender: Any) {
        print("Push")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            
        let nextvc = storyboard.instantiateViewController(withIdentifier: "VoiceViewController")as! VoiceViewController
        nextvc.hidesBottomBarWhenPushed = false
        navigationController?.pushViewController(nextvc, animated: true)
        print("go")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
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
