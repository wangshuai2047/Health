//
//  EvaluationPhysiqueDetailCell.swift
//  Health
//
//  Created by Yalin on 15/10/23.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationPhysiqueDetailCell: UITableViewCell {

    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var physiqueImageView1: UIImageView!
    @IBOutlet weak var physiqueButton1: UIButton!
    
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var physiqueImageView2: UIImageView!
    @IBOutlet weak var physiqueButton2: UIButton!
    
    @IBOutlet weak var titleLabel3: UILabel!
    @IBOutlet weak var physiqueImageView3: UIImageView!
    @IBOutlet weak var physiqueButton3: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
