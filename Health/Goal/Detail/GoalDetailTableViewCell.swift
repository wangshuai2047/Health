//
//  GoalDetailTableViewCell.swift
//  Health
//
//  Created by Yalin on 15/9/21.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class GoalDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var process1Label: UILabel!
    @IBOutlet weak var process2Label: UILabel!
    @IBOutlet weak var process3Label: UILabel!
    @IBOutlet weak var process4Label: UILabel!
    @IBOutlet weak var process5Label: UILabel!
    
    @IBOutlet weak var processLabelConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // colors 必须有5个 3个是目标之前的 3个是目标之后的
    func setColors(colors: [UIColor], step: Int, goalStep: Int) {
        if colors.count < 5 {
            process1Label.backgroundColor = UIColor.clearColor()
            process2Label.backgroundColor = UIColor.clearColor()
            process3Label.backgroundColor = UIColor.clearColor()
            process4Label.backgroundColor = UIColor.clearColor()
            process5Label.backgroundColor = UIColor.clearColor()
            
            processLabelConstraint.constant = self.bounds.size.width
        }
        else {
            process1Label.backgroundColor = colors[0]
            process2Label.backgroundColor = colors[1]
            process3Label.backgroundColor = colors[2]
            process4Label.backgroundColor = colors[3]
            process5Label.backgroundColor = colors[4]
            
            processLabelConstraint.constant = self.bounds.size.width * CGFloat(goalStep - step) / CGFloat(goalStep)
        }
    }
}
