//
//  EvaluationDetailViewController.swift
//  Health
//
//  Created by Yalin on 15/8/27.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationDetailViewController: UIViewController {
    
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
//        self.view.addSubview(detailView)
//        initWithDetailView()
        
        refreshData()
        
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        widthConstraint?.constant = backgroundScrollView.frame.size.width
        
//        initFatDetailView()
        
        
        //为了兼容iOS7，http://stackoverflow.com/questions/15490140/auto-layout-error
        //iOS8下无需这句话
//        self.view.layoutSubviews()
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        backgroundScrollView.contentSize = detailView.frame.size
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Init View
//    func initWithDetailView(contentView: UIView) {
//        contentView.addSubview(detailView)
//        
//        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        detailView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        
//        // top
//        contentView.addConstraint(NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
//        // left
//        contentView.addConstraint(NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0))
//        // right
//        contentView.addConstraint(NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0))
//        
//        // detail.width
//        widthConstraint = NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: self.view.frame.size.width)
//        detailView.addConstraint(widthConstraint!)
//
//        // detail.height
//        detailView.addConstraint(NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 1074))
//    }
    
    
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
        scoreCicleView.update([(Double(score), UIColor.blueColor()), (Double(100.0 - score), UIColor.yellowColor())], animated: true)
        
        scoreLabel.text = "\(score)分"
        
        physiqueImageView.image = UIImage(named: data!.physique.imageName)
    }
    
    func refreshDescriptionData() {
        
        let font = UIFont.systemFontOfSize(15)
        evaluationDescriptionLabel.append("您的体型为隐藏性肥胖。您的得分击败了", font: font, color: UIColor.blueColor())
        evaluationDescriptionLabel.append("25%", font: font, color: UIColor.redColor())
        evaluationDescriptionLabel.append("的用户，还需继续努力，朝着", font: font, color: UIColor.blueColor())
        evaluationDescriptionLabel.append("85", font: font, color: UIColor.redColor())
        evaluationDescriptionLabel.append("分迈进。本次10项检查中有", font: font, color: UIColor.blueColor())
        evaluationDescriptionLabel.append("1", font: font, color: UIColor.redColor())
        evaluationDescriptionLabel.append("项警告，", font: font, color: UIColor.blueColor())
        evaluationDescriptionLabel.append("2", font: font, color: UIColor.redColor())
        evaluationDescriptionLabel.append("项预警，", font: font, color: UIColor.blueColor())
        evaluationDescriptionLabel.append("7", font: font, color: UIColor.redColor())
        evaluationDescriptionLabel.append("项健康。", font: font, color: UIColor.blueColor())
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
        
        fatPercentageDescriptionLabel.append("标准体脂率为", font: nil, color: UIColor.blueColor())
        fatPercentageDescriptionLabel.append("21.6%", font: nil, color: UIColor.redColor())
        fatPercentageDescriptionLabel.append("还需减掉", font: nil, color: UIColor.blueColor())
        fatPercentageDescriptionLabel.append("1.33kg", font: nil, color: UIColor.redColor())
        fatPercentageDescriptionLabel.append("脂肪", font: nil, color: UIColor.blueColor())
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
            cell?.contentView.clipsToBounds = true
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            
            
//            initWithDetailView(cell!.contentView)
        }
        
        detailView.frame = CGRect(x:0, y: 0, width: tableView.frame.size.width, height: 1074)
//        detailView.backgroundColor = UIColor.redColor()
        cell!.contentView.addSubview(detailView)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 1074
    }
}
