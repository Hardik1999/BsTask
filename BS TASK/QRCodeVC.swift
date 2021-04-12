//
//  QRCodeVC.swift
//  BS TASK
//
//  Created by Hardik on 8/5/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit

class QRCodeVC: BaseVC {

    @IBOutlet weak var ivQRCode: UIImageView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var lblQR: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        ivQRCode.isHidden = true
        lblQR.isHidden = true
    }
    

    @IBAction func onClickSubmit(_ sender: Any) {
        ivQRCode.isHidden = false
        lblQR.isHidden = false

        doGetQR(myString: tfName.text!, image: ivQRCode)
    }
    
}
