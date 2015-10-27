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
//            refreshData()
        }
    }
    var viewModel = EvaluationDetailViewModel()
    var isRefreshAllData: Bool = false
    var isVisitor: Bool = false
    
//    @IBOutlet weak var backgroundScrollView: UIScrollView!
//    @IBOutlet var detailView: UIView!
    
    @IBOutlet var detailTableView: EvaluationResultTableView!
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
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        scoreCicleView.update([(0, deepBlue), (100, lightBlue)], animated: true)
        
        detailTableView.physiqueDelegate = self
        
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
        ShareViewController.showShareViewController(detailTableView.convertToImage(), delegate: self, rootController: self)
    }
    
}

// MARK: - 详细view 代理
extension EvaluationDetailViewController: EvaluationResultTableViewDelegate {
    func tapPhysiqueButton() {
        let controller = EvaluationPhysiqueDetailViewController()
        controller.physique = data?.physique
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func viewHeightChanged() {
        tableView.reloadData()
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
        refreshData()
    }
    
    func refreshData() {
        if data == nil || tableView == nil {
            return
        }
        
        viewModel.reloadData()
        tableView.reloadData()
        
        // 设置数据
        
//        refreshScoreData()
//        refreshDescriptionData()
//        
//        refreshWeightData()
//        refreshBMRData()
//        refreshFattyLiverData()
//        refreshFatData()
//        
//        refreshFatWeightData()
//        refreshMuscleData()
//        refreshBoneMuscleData()
//        refreshWaterData()
//        refreshProteinData()
//        refreshBoneData()
//        refreshVisceralFatData()
//        refreshBMIData()
//        refreshBodyAgeData()
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
            
            detailTableView.frame = CGRect(x:0, y: 0, width: tableView.frame.size.width, height: detailTableView.currentViewHeight)
            detailTableView.data = data
            cell!.contentView.addSubview(detailTableView)
            cell!.contentView.clipsToBounds = true
            
            detailTableView.reloadData()
            
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
            
            let description = String(format: "体重:%.1fkg 体脂:%.1f%%", model.scaleResult.weight, model.scaleResult.fatPercentage)
            cell?.detailTextLabel?.text = description
            
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return detailTableView.currentViewHeight
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
