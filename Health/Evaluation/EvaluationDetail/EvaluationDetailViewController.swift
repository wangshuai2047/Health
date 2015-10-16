//
//  EvaluationDetailViewController.swift
//  Health
//
//  Created by Yalin on 15/8/27.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationDetailViewController: UIViewController {
    
    var data: ScaleResultProtocol? {
        didSet {
            refreshData()
        }
    }
    var viewModel = EvaluationDetailViewModel()
    var isRefreshAllData: Bool = false
    var isVisitor: Bool = false
    
//    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet var detailView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
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
    
    @IBOutlet weak var fatWeightLabel: UILabel!     // 脂肪量
    @IBOutlet weak var musclePercentageLabel: UILabel! // 肌肉率
    @IBOutlet weak var boneMuscleLabel: UILabel!        // 骨骼肌
    @IBOutlet weak var waterPercentageLabel: UILabel!
    @IBOutlet weak var proteinPercentageLabel: UILabel!
    @IBOutlet weak var boneWeightLabel: UILabel!
    @IBOutlet weak var visceralFatWeightLabel: UILabel!
    @IBOutlet weak var BMILabel: UILabel!
    @IBOutlet weak var bodyAgeLabel: UILabel!
    
    convenience init() {
        self.init(nibName: "EvaluationDetailViewController", bundle: nil)
    }
    
    deinit {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isRefreshAllData {
            refreshAllData()
        }
        else {
            refreshData()
        }
        
        self.view.setNeedsDisplay()
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
    @IBOutlet weak var fatPercentageRulerMarkImageView: UIImageView!
    
    func initFatDetailView() {
        let rulerWidth = fatPercentageRulerImageView.frame.size.width
        
        fatPercentageLowLabelConstraint.constant = rulerWidth / 3 - fatPercentageLowLabel.frame.size.width/2
        fatPercentageHighLabelLeftConstraint.constant = rulerWidth / 3 - fatPercentageLowLabel.frame.size.width/2
        
        fatPercentageLeanLabelRightConstraint.constant = rulerWidth / 3 / 2
        fatPercentageTooHighLabelLeftConstraint.constant = rulerWidth / 3 / 2
        
        let minValue = data!.fatPercentageRange.0 - data!.fatPercentageRange.1 + data!.fatPercentageRange.0
        let maxValue = data!.fatPercentageRange.1 + data!.fatPercentageRange.1 - data!.fatPercentageRange.0
        let value = data!.fatPercentage - minValue
        fatPercentageMarkImageViewLeftConstraint.constant = rulerWidth * CGFloat(value / (maxValue - minValue)) - fatPercentageRulerMarkImageView.frame.size.width/2
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func physiqueButtonPressed(sender: AnyObject) {
        let controller = EvaluationPhysiqueDetailViewController()
        controller.physique = data?.physique
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        if data != nil {
            EvaluationManager.shareInstance().deleteEvaluationData(data!)
            refreshAllData()
        }
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        ShareViewController.showShareViewController(detailView.convertToImage(), delegate: self, rootController: self)
    }
    
}
// MARK: - 分享
extension EvaluationDetailViewController: ShareViewControllerDelegate {
    func shareFinished(shareType: ShareType, error: NSError?) {
        if error == nil {
            Alert.showErrorAlert("分享成功", message: nil)
        }
        else {
            Alert.showErrorAlert("分享失败", message: error?.localizedDescription)
        }
    }
}

// MARK: - 设置界面数据
extension EvaluationDetailViewController {
    
    func refreshAllData() {
        if tableView == nil {
            return
        }
        
        viewModel.reloadData()
        tableView.reloadData()
        
        self.data = viewModel.allDatas.first?.scaleResult
    }
    
    func refreshData() {
        if data == nil || tableView == nil {
            return
        }
        
        viewModel.reloadData()
        tableView.reloadData()
        
        // 设置数据
        
        refreshScoreData()
        refreshDescriptionData()
        
        refreshWeightData()
        refreshBMRData()
        refreshFattyLiverData()
        refreshFatData()
        
        refreshFatWeightData()
        refreshMuscleData()
        refreshBoneMuscleData()
        refreshWaterData()
        refreshProteinData()
        refreshBoneData()
        refreshVisceralFatData()
        refreshBMIData()
        refreshBodyAgeData()
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
        
        physiqueImageView.image = UIImage(named: data!.physique.selectImageName)
    }
    
    func refreshDescriptionData() {
        let (warningCount,earlyWarningCount,hCount) = healthCount()
        
        
        let font = UIFont.systemFontOfSize(15)
        evaluationDescriptionLabel.clear()
        evaluationDescriptionLabel.append("您的体型为", font: font, color: UIColor.grayColor())
        evaluationDescriptionLabel.append("\(data!.physique.description)", font: font, color: deepBlue)
        evaluationDescriptionLabel.append("。您的得分击败了", font: font, color: UIColor.grayColor())
        evaluationDescriptionLabel.append("25%", font: font, color: deepBlue)
        evaluationDescriptionLabel.append("的用户。本次9项检查中有", font: font, color: UIColor.grayColor())
        evaluationDescriptionLabel.append("\(warningCount)", font: font, color: ValueStatus.High.statusColor)
        evaluationDescriptionLabel.append("项警告，", font: font, color: UIColor.grayColor())
        evaluationDescriptionLabel.append("\(earlyWarningCount)", font: font, color: ValueStatus.Low.statusColor)
        evaluationDescriptionLabel.append("项预警，", font: font, color: UIColor.grayColor())
        evaluationDescriptionLabel.append("\(hCount)", font: font, color: ValueStatus.Normal.statusColor)
        evaluationDescriptionLabel.append("项健康。", font: font, color: UIColor.grayColor())
    }
    
    func refreshWeightData() {
        weightLabel.text = "\(data!.weight)"
        weightLabel.textColor = data!.weightStatus.statusColor
    }
    
    func refreshBMRData() {
        BMRLabel.text = "\(data!.BMR)"
    }
    
    func refreshFattyLiverData() {
        if let hepaticAdiposeInfiltration =  data?.hepaticAdiposeInfiltration {
            if hepaticAdiposeInfiltration {
                fattyLiverLabel.text = "有脂肪肝"
            }
            else {
                fattyLiverLabel.text = "没脂肪肝"
            }
        }
        else {
            fattyLiverLabel.text = "此秤不支持"
        }
        
    }
    
    func refreshFatData() {
        initFatDetailView()
        fatPercentageLabel.text = "\(data!.fatPercentage)"
        fatPercentageLabel.textColor = data!.fatPercentageStatus.statusColor
        
        fatPercentageHighLabel.text = "\(data!.fatPercentageRange.1)%"
        fatPercentageLowLabel.text = "\(data!.fatPercentageRange.0)%"
        
        fatPercentageDescriptionLabel.clear()
        fatPercentageDescriptionLabel.append("标准体脂率为", font: nil, color: UIColor.grayColor())
        fatPercentageDescriptionLabel.append("\(data!.standardFatPercentage)%", font: nil, color: UIColor.greenColor())
        
        if data!.standardFatPercentage > data!.fatPercentage {
            // 增肥
            fatPercentageDescriptionLabel.append("还需增加", font: nil, color: UIColor.grayColor())
            
            fatPercentageDescriptionLabel.append("\(data!.weight * (data!.standardFatPercentage - data!.fatPercentage)/100)kg", font: nil, color: UIColor.greenColor())
        }
        else {
            // 减肥
            fatPercentageDescriptionLabel.append("还需减掉", font: nil, color: UIColor.grayColor())
            fatPercentageDescriptionLabel.append("\(data!.weight * (data!.fatPercentage - data!.standardFatPercentage)/100)kg", font: nil, color: UIColor.greenColor())
            
        }
        
        fatPercentageDescriptionLabel.append("脂肪", font: nil, color: UIColor.grayColor())
    }
    
    func refreshFatWeightData() {
        fatWeightLabel.text = "\(data!.fatWeight)"
        fatWeightLabel.textColor = data!.fatWeightStatus.statusColor
    }
    
    func refreshMuscleData() {
        musclePercentageLabel.text = "\(data!.muscleWeight)"
        musclePercentageLabel.textColor = data!.muscleWeightStatus.statusColor
    }
    
    func refreshBoneMuscleData() {
        boneMuscleLabel.text = "\(data!.boneMuscleWeight)"
        boneMuscleLabel.textColor = data!.boneMuscleLevel.statusColor
    }
    
    func refreshWaterData() {
        waterPercentageLabel.text = "\(data!.waterWeight)"
        waterPercentageLabel.textColor = data!.waterWeightStatus.statusColor
    }
    
    func refreshProteinData() {
        proteinPercentageLabel.text = "\(data!.proteinWeight)"
        proteinPercentageLabel.textColor = data!.proteinWeightStatus.statusColor
    }
    
    func refreshBoneData() {
        boneWeightLabel.text = "\(data!.boneWeight)"
        boneWeightLabel.textColor = data!.boneWeightStatus.statusColor
    }
    
    func refreshVisceralFatData() {
        visceralFatWeightLabel.text = "\(data!.visceralFatPercentage)"
        visceralFatWeightLabel.textColor = data!.visceralFatContentStatus.statusColor
    }
    
    func refreshBMIData() {
        BMILabel.text = "\(data!.BMI)"
        BMILabel.textColor = data!.BMIStatus.statusColor
    }
    
    func refreshBodyAgeData() {
        bodyAgeLabel.text = "\(Int(data!.bodyAge))"
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension EvaluationDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // 如果是访客 没有历史记录
        if isVisitor {
            return 1
        }
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return viewModel.allDatas.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cellId = "EvaluationDetailTableViewCell"
            
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                cell?.selectionStyle = UITableViewCellSelectionStyle.None
                
            }
            
            detailView.frame = CGRect(x:0, y: 0, width: tableView.frame.size.width, height: detailView.frame.size.height)
            cell!.contentView.addSubview(detailView)
            
            return cell!
        }
        else {
            let cellId = "EvaluationDetailTableViewDataCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellId)
            }
            
            let model: EvaluationDetailCellViewModel = viewModel.allDatas[indexPath.row]
            cell?.textLabel?.text = "\(model.timeShowString)"
            cell?.detailTextLabel?.text = "体重:\(model.scaleResult.weight)kg 体脂:\(model.scaleResult.fatPercentage)%"
            
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return detailView.frame.size.height
        }
        else {
            return 54
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let model = viewModel.allDatas[indexPath.row];
            data = model.scaleResult
            refreshData()
        }
    }
}
