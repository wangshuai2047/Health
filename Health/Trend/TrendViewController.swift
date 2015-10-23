//
//  TrendViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class TrendViewController: UIViewController {
    
    var viewModel = TrendViewModel()

    @IBOutlet weak var userSelectView: UserSelectView!
    @IBOutlet weak var titleDetailView: UIView!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var fatButton: UIButton!
    @IBOutlet weak var muscleButton: UIButton!
    @IBOutlet weak var waterButton: UIButton!
    @IBOutlet weak var proteinButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chartView: DoubleYAxisLineChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
        chartView.dataSource = self
//        let datas = viewModel.eightDaysDatas()
        userSelectView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        weightButton.selected = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userSelectView.setUsers(UserManager.shareInstance().queryAllUsers(), isNeedExt: false)
        userSelectView.setShowViewUserId(UserManager.shareInstance().currentUser.userId)
        viewModel.eightDaysDatas()
        tableView.reloadData()
        chartView.reloadDatas()
        refreshSelectedData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func selectedButton() -> UIButton? {
        
        if muscleButton.selected {
            return muscleButton
        }
        
        if fatButton.selected {
            return fatButton
        }
        
        if waterButton.selected {
            return waterButton
        }
        
        if proteinButton.selected {
            return proteinButton
        }
        
        return nil
    }

    @IBAction func selectButtonPressed(button: UIButton) {
        
        if weightButton == button {
            if weightButton.selected {
                weightButton.selected = false
                refreshSelectedData()
            }
            else {
                if selectCount() > 1 {
                    if let selectButton = selectedButton() {
                        weightButton.selected = true
                        selectButton.selected = false
                        refreshSelectedData()
                    }
                }
                else {
                    weightButton.selected = true
                    refreshSelectedData()
                }
                
            }
        }
        else {
            if button.selected {
                button.selected = false
                refreshSelectedData()
            }
            else {
                if weightButton.selected {
                    if let selectButton = selectedButton() {
                        selectButton.selected = false
                        
                    }
                    button.selected = true
                    refreshSelectedData()
                }
                else {
                    if selectCount() < 2 {
                        button.selected = true
                        refreshSelectedData()
                    }
                }
                
            }
        }
        
        
    }
    
    func refreshSelectedData() {
        var count = 0
        
        viewModel.selectedTag = (nil, nil)
        
        if weightButton.selected {
            viewModel.selectedTag = (weightButton.tag, nil)
            count++
        }
        
        if fatButton.selected {
            if count == 1 {
                viewModel.selectedTag = (viewModel.selectedTag.0, fatButton.tag)
            }
            else if count == 0 {
                viewModel.selectedTag = (fatButton.tag, nil)
                count++
            }
        }
        
        if muscleButton.selected {
            if count == 1 {
                viewModel.selectedTag = (viewModel.selectedTag.0, muscleButton.tag)
            }
            else if count == 0 {
                viewModel.selectedTag = (muscleButton.tag, nil)
                count++
            }
        }
        
        if waterButton.selected {
            if count == 1 {
                viewModel.selectedTag = (viewModel.selectedTag.0, waterButton.tag)
            }
            else if count == 0 {
                viewModel.selectedTag = (waterButton.tag, nil)
                count++
            }
        }
        
        if proteinButton.selected {
            if count == 1 {
                viewModel.selectedTag = (viewModel.selectedTag.0, proteinButton.tag)
            }
            else if count == 0 {
                viewModel.selectedTag = (proteinButton.tag, nil)
                count++
            }
        }
        
        self.chartView.reloadDatas()
    }
    
    func selectCount() -> Int {
        var selectCount: Int = 0
        selectCount += weightButton.selected ? 1 : 0
        selectCount += fatButton.selected ? 1 : 0
        selectCount += muscleButton.selected ? 1 : 0
        selectCount += waterButton.selected ? 1 : 0
        selectCount += proteinButton.selected ? 1 : 0
        return selectCount
    }
}

extension TrendViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.allDatas.count > 5 {
            return 5
        }
        return viewModel.allDatas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "TrendTableViewDataCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellId)
        }
        
        let model: TrendCellViewModel = viewModel.allDatas[indexPath.row]
        cell?.textLabel?.text = "\(model.timeShowString)"
        cell?.detailTextLabel?.text = "体重:\(model.scaleResult.weight)kg 体脂:\(model.scaleResult.fatPercentage)%"
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let model: TrendCellViewModel = viewModel.allDatas[indexPath.row]
        
        let detailController = EvaluationDetailViewController()
        detailController.data = model.scaleResult
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
    }
}

extension TrendViewController: DoubleYAxisLineChartDataSource {
    
    func chart(chart: DoubleYAxisLineChart, colorOfChart isLeftYAxis: Bool) -> UIColor {
        
        return viewModel.chartColor(isLeftYAxis)
    }
    
    func chart(chart: DoubleYAxisLineChart, minAndMaxLabelDatasOfYAxis isLeftYAxis: Bool) -> (minValue: Double, maxValue: Double)? {
        
        if isLeftYAxis {
            return viewModel.rangeOfSelectTag(viewModel.selectedTag.0)
        }
        return viewModel.rangeOfSelectTag(viewModel.selectedTag.1)
    }
    
    func chart(chart: DoubleYAxisLineChart, valueOfIndex: Int) -> (Double?, Double?, String) {
        
        return viewModel.value(valueOfIndex)
    }
    
    func numberOfDatas(chart: DoubleYAxisLineChart) -> Int {
        return viewModel.weightDatas.count
    }
}

extension TrendViewController: UserSelectViewDelegate {
    // 点击人物头像
    func headButtonPressed(userId: Int) {
        let detailController = EvaluationDetailViewController()
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
        detailController.isRefreshAllData = true
    }
    
    // 点击访客
    func visitorClicked() {
        
    }
    
    // 添加家庭成员
    func addFamily() {
    }
    
    // 用户改变
    func userChangeToUserId(userId: Int) {
        UserManager.shareInstance().changeUserToUserId(userId)
        userSelectView.setShowViewUserId(userId)
        
        // 刷新界面
        viewModel.eightDaysDatas()
        tableView.reloadData()
        chartView.reloadDatas()
    }
}
