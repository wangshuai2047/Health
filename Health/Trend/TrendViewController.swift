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

    @IBOutlet weak var titleDetailView: UIView!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var fatButton: UIButton!
    @IBOutlet weak var muscleButton: UIButton!
    @IBOutlet weak var waterButton: UIButton!
    @IBOutlet weak var proteinButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
        
//        let datas = viewModel.eightDaysDatas()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.eightDaysDatas()
        tableView.reloadData()
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

    @IBAction func selectButtonPressed(button: UIButton) {
        
        if button.selected {
            button.selected = false
        }
        else {
            if selectCount() < 2 {
                button.selected = true
            }
        }
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
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.allDatas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "TrendTableViewDataCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? UITableViewCell
        
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
        
        var detailController = EvaluationDetailViewController()
        detailController.data = model.scaleResult
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
    }
}
