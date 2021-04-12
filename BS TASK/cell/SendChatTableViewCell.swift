//
//  SendChatTableViewCell.swift
//  BS TASK
//
//  Created by Hardik on 10/29/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit

class SendChatTableViewCell: UITableViewCell {

    @IBOutlet weak var imgBubbel: UIImageView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var lblSpeech: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
