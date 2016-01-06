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
        self.view.layoutSubviews()
        self.view.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Init View
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backButtonPressed(sender: AnyObject) {
        BluetoothManager.shareInstance.stopScanDevice()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        
        UIAlertView(title: "确认删除?", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定").show()
        
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        ShareViewController.showShareViewController(detailTableView.convertToImage(), delegate: self, rootController: self)
    }
    
}

extension EvaluationDetailViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if data != nil {
                AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "删除中", detailMsg: nil, progress: nil)
                EvaluationManager.shareInstance().deleteEvaluationData(data!, complete: { [unowned self] (error: NSError?) -> Void in
                    if error == nil {
                        self.refreshAllData()
                    }
                    else {
                        Alert.showErrorAlert("删除失败", message: error!.localizedDescription)
                    }
                    
                    AppDelegate.applicationDelegate().hiddenHUD()
                })
                
            }
        }
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
            cell?.textLabel?.textColor = UIColor.darkGrayColor()
            
            let description = String(format: "体重:%.1fkg 体脂:%.1f%%", model.scaleResult.weight, model.scaleResult.fatPercentage)
            cell?.detailTextLabel?.text = description
            cell?.detailTextLabel?.textColor = UIColor.darkGrayColor()
            
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
