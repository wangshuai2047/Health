//
//  EvaluationDetailExtendCell.swift
//  Health
//
//  Created by Yalin on 15/10/21.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationDetailExtendCell: UITableViewCell {
    
    static var normalHeight: CGFloat = 65
    static var extendHeight: CGFloat = 194
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBOutlet weak var markLowLabel: UILabel!
    @IBOutlet weak var markHighLabel: UILabel!
    @IBOutlet weak var descriptionLabel: AttributedLabel!
    
    
    @IBOutlet weak var markIconCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var markHighLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var markLowLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var fatPercentageTooHighLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var fatPercentageLeanLabelCenterConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setResultValue(value: String, range: (Float, Float), unit: String, status: ValueStatus?) {
        unitLabel.text = unit
        
        
        if let numberValues = (value as? NSString)?.floatValue {
            resultLabel.text = "\(numberValues)"
            
            markHighLabel.text = "\(range.1)\(unit)"
            markLowLabel.text = "\(range.0)\(unit)"
            
            descriptionLabel.clear()
            
            if status == ValueStatus.High {
                descriptionLabel.append("\(titleLabel!.text)出现警告,请重视!", font: nil, color: status?.statusColor)
            }
            else if status == ValueStatus.Normal {
                descriptionLabel.append("\(titleLabel!.text)正常, 请保持!", font: nil, color: status?.statusColor)
            }
            else if status == ValueStatus.Low {
                descriptionLabel.append("\(titleLabel!.text)出现警告, 注意控制!", font: nil, color: status?.statusColor)
            }
            
//            descriptionLabel.append("标准\(titleLabel!.text)为", font: nil, color: UIColor.grayColor())
//            descriptionLabel.append("\(data!.standardFatPercentage)%", font: nil, color: UIColor.greenColor())
//            
//            if data!.standardFatPercentage > data!.fatPercentage {
//                // 增肥
//                descriptionLabel.append("还需增加", font: nil, color: UIColor.grayColor())
//                
//                descriptionLabel.append("\(data!.weight * (data!.standardFatPercentage - data!.fatPercentage)/100)kg", font: nil, color: UIColor.greenColor())
//            }
//            else {
//                // 减肥
//                descriptionLabel.append("还需减掉", font: nil, color: UIColor.grayColor())
//                descriptionLabel.append("\(data!.weight * (data!.fatPercentage - data!.standardFatPercentage)/100)kg", font: nil, color: UIColor.greenColor())
//                
//            }
//            
//            descriptionLabel.append("脂肪", font: nil, color: UIColor.grayColor())
        }
        else {
            resultLabel.text = value
        }
        
        if status != nil {
            resultLabel.textColor = status?.statusColor
        }
        else {
            resultLabel.textColor = UIColor.grayColor()
        }
    }
    
//    func refreshFatData() {
//        initFatDetailView()
//        
//        fatPercentageLabel.text = "\(data!.fatPercentage)"
//        fatPercentageLabel.textColor = data!.fatPercentageStatus.statusColor
//        
//        fatPercentageHighLabel.text = "\(data!.fatPercentageRange.1)%"
//        fatPercentageLowLabel.text = "\(data!.fatPercentageRange.0)%"
//        
//        
//    }
//    
//    func initFatDetailView() {
//        let rulerWidth = fatPercentageRulerImageView.frame.size.width
//        
//        fatPercentageLowLabelConstraint.constant = rulerWidth / 3 - fatPercentageLowLabel.frame.size.width/2
//        fatPercentageHighLabelLeftConstraint.constant = rulerWidth / 3 - fatPercentageLowLabel.frame.size.width/2
//        
//        fatPercentageLeanLabelRightConstraint.constant = rulerWidth / 3 / 2
//        fatPercentageTooHighLabelLeftConstraint.constant = rulerWidth / 3 / 2
//        
//        let minValue = data!.fatPercentageRange.0 - data!.fatPercentageRange.1 + data!.fatPercentageRange.0
//        let maxValue = data!.fatPercentageRange.1 + data!.fatPercentageRange.1 - data!.fatPercentageRange.0
//        let value = data!.fatPercentage - minValue
//        fatPercentageMarkImageViewLeftConstraint.constant = rulerWidth * CGFloat(value / (maxValue - minValue)) - fatPercentageRulerMarkImageView.frame.size.width/2
//    }
}
