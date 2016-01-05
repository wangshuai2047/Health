//
//  EvaluationDetailScroeDescriptionCell.swift
//  Health
//
//  Created by Yalin on 15/10/21.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationDetailScroeDescriptionCell: UITableViewCell {

    static let normalHeight: CGFloat = 370
    var data: ScaleResultProtocol?
    var allStatus: [ValueStatus] {
        if data != nil {
            
            var status = [
                data!.weightStatus,
                data!.proteinWeightStatus,
                data!.boneWeightStatus,
                data!.waterWeightStatus,
                data!.fatWeightStatus,
                data!.muscleWeightStatus,
                data!.boneMuscleLevel,
                data!.visceralFatContentStatus,
                data!.fatPercentageStatus,
                ValueStatus.Normal,     // 身体年龄
                ValueStatus.Normal,     // 代谢
            ]
            
            if data!.hepaticAdiposeInfiltration != nil {
                status.append(data!.fattyLiverStatus)
            }
            return status
        }
        else {
            return []
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var descriptionLabel: AttributedLabel!
    @IBOutlet weak var scoreCicleView: CircleView!
    @IBOutlet weak var physiqueImageView: UIImageView!
    @IBOutlet weak var physiqueButton: UIButton!
    
    
    var lightColor: UIColor {
        if UserManager.shareInstance().currentUser.gender {
            return lightBlue
        }
        else {
            return lightPink
        }
    }
    
    var deepColor: UIColor {
        if UserManager.shareInstance().currentUser.gender {
            return deepBlue
        }
        else {
            return deepPink
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        scoreCicleView.update([(0, deepColor), (100, lightColor)], animated: true)
        physiqueImageView.image = UIImage(named: Physique.Athlete.selectedImageName(UserManager.shareInstance().currentUser.gender))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func refreshData() {
        if data != nil {
            refreshScoreData()
            refreshDescriptionData()
        }
    }
    
    func healthCount() -> (Int, Int, Int) {
        var warningCount: Int = 0
        var healthCount: Int = 0
        var earlyWarningCount: Int = 0
        
        for status in allStatus {
            // 重量
            if status == .Low {
                earlyWarningCount++
            }
            else if status == .Normal {
                healthCount++
            }
            else {
                warningCount++
            }
        }
        return (warningCount, earlyWarningCount, healthCount)
    }
    
    func refreshScoreData() {
        // 分数
        let score = data!.score
        scoreCicleView.update([(Double(score), deepColor), (Double(100.0 - score), lightColor)], animated: true)
        
        scoreLabel.text = String(format: "%d分", arguments: [Int(score)])
        scoreLabel.textColor = deepBlue
        
        physiqueImageView.image = UIImage(named: data!.physique.selectedImageName(data!.gender))
    }
    
    func refreshDescriptionData() {
        let (warningCount,earlyWarningCount,hCount) = healthCount()
        
        // 您的体型为肥胖型，本次12项检查中，有XX项预警，XX项警告，XX项正常”，
        
        let font = UIFont.systemFontOfSize(15)
        descriptionLabel.clear()
        descriptionLabel.append("您的体型为", font: font, color: UIColor.grayColor())
        descriptionLabel.append("\(data!.physique.description)", font: font, color: deepBlue)
        descriptionLabel.append("。本次\(allStatus.count)项检查中有", font: font, color: UIColor.grayColor())
        descriptionLabel.append("\(earlyWarningCount)", font: font, color: ValueStatus.Low.statusColor)
        descriptionLabel.append("项预警，", font: font, color: UIColor.grayColor())
        descriptionLabel.append("\(warningCount)", font: font, color: ValueStatus.High.statusColor)
        descriptionLabel.append("项警告，", font: font, color: UIColor.grayColor())
        descriptionLabel.append("\(hCount)", font: font, color: ValueStatus.Normal.statusColor)
        descriptionLabel.append("项正常。", font: font, color: UIColor.grayColor())
    }
}
