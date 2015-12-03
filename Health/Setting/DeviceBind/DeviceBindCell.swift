//
//  DeviceBindCell.swift
//  Health
//
//  Created by Yalin on 15/10/6.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class DeviceBindCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bindButton: UIButton!
    @IBOutlet weak var headImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        titleLabel.layer.cornerRadius = 10
    }
}
