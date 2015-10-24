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
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var descriptionLabel: AttributedLabel!
    @IBOutlet weak var scoreCicleView: CircleView!
    @IBOutlet weak var physiqueImageView: UIImageView!
    @IBOutlet weak var physiqueButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        scoreCicleView.update([(0, deepBlue), (100, lightBlue)], animated: true)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func refreshData() {
        refreshScoreData()
        refreshDescriptionData()
    }
    
    func healthCount() -> (Int, Int, Int) {
        var warningCount: Int = 0
        var healthCount: Int = 0
        var earlyWarningCount: Int = 0
        
        let allStatus: [ValueStatus] = [
            data!.weightStatus,
            data!.proteinWeightStatus,
            data!.boneWeightStatus,
            data!.waterWeightStatus,
            data!.fatWeightStatus,
            data!.muscleWeightStatus,
            data!.boneMuscleLevel,
            data!.visceralFatContentStatus,
            data!.fatPercentageStatus,
        ]
        
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
        scoreCicleView.update([(Double(score), deepBlue), (Double(100.0 - score), lightBlue)], animated: true)
        
        scoreLabel.text = "\(score)分"
        scoreLabel.textColor = deepBlue
        
        physiqueImageView.image = UIImage(named: data!.physique.selectedImageName(data!.gender))
    }
    
    func refreshDescriptionData() {
        let (warningCount,earlyWarningCount,hCount) = healthCount()
        
        
        let font = UIFont.systemFontOfSize(15)
        descriptionLabel.clear()
        descriptionLabel.append("您的体型为", font: font, color: UIColor.grayColor())
        descriptionLabel.append("\(data!.physique.description)", font: font, color: deepBlue)
        descriptionLabel.append("。您的得分击败了", font: font, color: UIColor.grayColor())
        descriptionLabel.append("25%", font: font, color: deepBlue)
        descriptionLabel.append("的用户。本次9项检查中有", font: font, color: UIColor.grayColor())
        descriptionLabel.append("\(warningCount)", font: font, color: ValueStatus.High.statusColor)
        descriptionLabel.append("项警告，", font: font, color: UIColor.grayColor())
        descriptionLabel.append("\(earlyWarningCount)", font: font, color: ValueStatus.Low.statusColor)
        descriptionLabel.append("项预警，", font: font, color: UIColor.grayColor())
        descriptionLabel.append("\(hCount)", font: font, color: ValueStatus.Normal.statusColor)
        descriptionLabel.append("项健康。", font: font, color: UIColor.grayColor())
    }
}
