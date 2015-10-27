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
    static var extendHeight: CGFloat = 246
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBOutlet weak var markLowLabel: UILabel!
    @IBOutlet weak var markHighLabel: UILabel!
    @IBOutlet weak var descriptionLabel: AttributedLabel!
    
    
    @IBOutlet weak var markBgImageView: UIImageView!
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
        
//        let a = value[0]
        var isNumber = true
        for c in value.characters {
            if c == "0" || c == "1" || c == "2" || c == "3" || c == "4" || c == "5" || c == "6" || c == "7" || c == "8" || c == "9" {
                break
            }
            else {
                isNumber = false
                break
            }
        }
        
        if isNumber {
            let numberValues = value.floatValue
            resultLabel.text = String(format: "%.1f", numberValues)
            
            markHighLabel.text = String(format: "%.1f\(unit)", range.1)
            markLowLabel.text = String(format: "%.1f\(unit)", range.0)
            
            descriptionLabel.clear()
            
            if status == ValueStatus.High {
                descriptionLabel.append("\(titleLabel!.text!)出现警告,请重视!", font: nil, color: status?.statusColor)
            }
            else if status == ValueStatus.Normal {
                descriptionLabel.append("\(titleLabel!.text!)正常, 请保持!", font: nil, color: status?.statusColor)
            }
            else if status == ValueStatus.Low {
                descriptionLabel.append("\(titleLabel!.text!)出现警告, 注意控制!", font: nil, color: status?.statusColor)
            }
            
            
            // 计算标记位置
            let rulerWidth = markBgImageView.frame.size.width
            let labelPad = rulerWidth / 3 / 2 + 15
            let labelPad2 = rulerWidth / 2 - 20
            
            
            fatPercentageLeanLabelCenterConstraint.constant = -1 * labelPad2
            fatPercentageTooHighLabelCenterConstraint.constant = labelPad2
            
            markHighLabelCenterConstraint.constant = labelPad
            markLowLabelConstraint.constant = labelPad * -1
            
            let middleValue = (range.0 + range.1) / 2
            let offset = numberValues - middleValue
        
            if range.1 != middleValue {
                
                var constant = CGFloat(offset) * (labelPad / CGFloat(range.1 - middleValue))
                
                if constant > markBgImageView.frame.size.width / 2 {
                    constant = markBgImageView.frame.size.width / 2
                }
                else if constant < -1 * markBgImageView.frame.size.width / 2 {
                    constant = -1 * markBgImageView.frame.size.width / 2
                }
                
                markIconCenterConstraint.constant = constant
            }
            
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
