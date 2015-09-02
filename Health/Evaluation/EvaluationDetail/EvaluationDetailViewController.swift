//
//  EvaluationDetailViewController.swift
//  Health
//
//  Created by Yalin on 15/8/27.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationDetailViewController: UIViewController {
    
    let lightBlue = UIColor(red: 121/255.0, green: 199/255.0, blue: 235/255.0, alpha: 1)
    let deepBlue: UIColor = UIColor(red: 26/255.0, green: 146/255.0, blue: 214/255.0, alpha: 1)
    var data: ScaleResult?
    
//    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet var detailView: UIView!
    
    // 显示数据
    @IBOutlet weak var scoreCicleView: CircleView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var physiqueImageView: UIImageView!
    @IBOutlet weak var evaluationDescriptionLabel: AttributedLabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var BMRLabel: UILabel!   // 代谢
    @IBOutlet weak var fattyLiverLabel: UILabel! // 脂肪肝
    @IBOutlet weak var fatPercentageLabel: UILabel! // 体脂率、脂肪
    @IBOutlet weak var fatPercentageLowLabel: UILabel!
    @IBOutlet weak var fatPercentageHighLabel: UILabel!
    @IBOutlet weak var fatPercentageDescriptionLabel: AttributedLabel!
    
    @IBOutlet weak var musclePercentageLabel: UILabel! // 肌肉率
    @IBOutlet weak var waterPercentageLabel: UILabel!
    @IBOutlet weak var proteinPercentageLabel: UILabel!
    @IBOutlet weak var boneWeightLabel: UILabel!
    @IBOutlet weak var visceralFatWeightLabel: UILabel!
    @IBOutlet weak var BMILabel: UILabel!
    
    convenience init() {
        self.init(nibName: "EvaluationDetailViewController", bundle: nil)
    }
    
    deinit {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Init View
    
    @IBOutlet weak var fatPercentageLowLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var fatPercentageHighLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var fatPercentageMarkImageViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var fatPercentageLeanLabelRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fatPercentageTooHighLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var fatPercentageRulerImageView: UIImageView!
    
    func initFatDetailView() {
        let rulerWidth = fatPercentageRulerImageView.frame.size.width
        
        fatPercentageLowLabelConstraint.constant = rulerWidth / 3 - 18
        fatPercentageHighLabelLeftConstraint.constant = rulerWidth / 3 - 18
        
        fatPercentageLeanLabelRightConstraint.constant = rulerWidth / 3 / 2
        fatPercentageTooHighLabelLeftConstraint.constant = rulerWidth / 3 / 2
    }
    
    func refreshData() {
        if data == nil {
            return
        }
        
        // 设置数据
        
        refreshScoreData()
        refreshDescriptionData()
        refreshWeightData()
        refreshBMRData()
        refreshFattyLiverData()
        refreshFatData()
        refreshMuscleData()
        refreshWaterData()
        refreshProteinData()
        refreshBoneData()
        refreshVisceralFatData()
        refreshBMIData()
    }
    
    func refreshScoreData() {
        // 分数
        let score = data!.score
        scoreCicleView.update([(Double(score), deepBlue), (Double(100.0 - score), lightBlue)], animated: true)
        
        scoreLabel.text = "\(score)分"
        scoreLabel.textColor = deepBlue
        
        physiqueImageView.image = UIImage(named: data!.physique.imageName)
    }
    
    func refreshDescriptionData() {
        
        let font = UIFont.systemFontOfSize(15)
        evaluationDescriptionLabel.append("您的体型为隐藏性肥胖。您的得分击败了", font: font, color: UIColor.grayColor())
        evaluationDescriptionLabel.append("25%", font: font, color: deepBlue)
        evaluationDescriptionLabel.append("的用户，还需继续努力，朝着", font: font, color: UIColor.grayColor())
        evaluationDescriptionLabel.append("85", font: font, color: deepBlue)
        evaluationDescriptionLabel.append("分迈进。本次10项检查中有", font: font, color: UIColor.grayColor())
        evaluationDescriptionLabel.append("1", font: font, color: UIColor.redColor())
        evaluationDescriptionLabel.append("项警告，", font: font, color: UIColor.grayColor())
        evaluationDescriptionLabel.append("2", font: font, color: UIColor.orangeColor())
        evaluationDescriptionLabel.append("项预警，", font: font, color: UIColor.grayColor())
        evaluationDescriptionLabel.append("7", font: font, color: UIColor.greenColor())
        evaluationDescriptionLabel.append("项健康。", font: font, color: UIColor.grayColor())
    }
    
    func refreshWeightData() {
        weightLabel.text = "\(data!.weight)"
    }
    
    func refreshBMRData() {
        BMRLabel.text = "\(data!.BMR)"
    }
    
    func refreshFattyLiverData() {
        fattyLiverLabel.text = "此秤不支持"
    }
    
    func refreshFatData() {
        fatPercentageLabel.text = "\(data!.fatPercentage)"
        
        fatPercentageHighLabel.text = "\(data!.fatPercentageRange.1)%"
        fatPercentageLowLabel.text = "\(data!.fatPercentageRange.0)%"
        
        fatPercentageDescriptionLabel.append("标准体脂率为", font: nil, color: UIColor.grayColor())
        fatPercentageDescriptionLabel.append("21.6%", font: nil, color: UIColor.greenColor())
        fatPercentageDescriptionLabel.append("还需减掉", font: nil, color: UIColor.grayColor())
        fatPercentageDescriptionLabel.append("1.33kg", font: nil, color: UIColor.greenColor())
        fatPercentageDescriptionLabel.append("脂肪", font: nil, color: UIColor.grayColor())
    }
    
    func refreshMuscleData() {
        musclePercentageLabel.text = "\(data!.muscleWeight * 100 / data!.weight)"
    }
    
    func refreshWaterData() {
        waterPercentageLabel.text = "\(data!.waterPercentage)"
    }
    
    func refreshProteinData() {
        proteinPercentageLabel.text = "\(data!.proteinWeight * 100 / data!.weight)"
    }
    
    func refreshBoneData() {
        boneWeightLabel.text = "\(data!.boneWeight / data!.weight)"
    }
    
    func refreshVisceralFatData() {
        visceralFatWeightLabel.text = "\(data!.visceralFatPercentage)"
    }
    
    func refreshBMIData() {
        BMILabel.text = "\(data!.bmi)"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension EvaluationDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "EvaluationDetailTableViewCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            
        }
        
        detailView.frame = CGRect(x:0, y: 0, width: tableView.frame.size.width, height: detailView.frame.size.height)
        cell!.contentView.addSubview(detailView)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return detailView.frame.size.height
    }
}
