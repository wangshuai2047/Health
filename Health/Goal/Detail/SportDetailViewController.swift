//
//  SportDetailViewController.swift
//  Health
//
//  Created by Yalin on 15/8/24.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

private let cellId = "GoalDetailTableViewCell"

class SportDetailViewController: UIViewController {

    @IBOutlet weak var cicleView: CircleView!
    
    @IBOutlet weak var todayWalkLabel: UILabel!
    @IBOutlet weak var walkPercenageLabel: UILabel!
    @IBOutlet weak var goalStepLabel: UILabel!
    @IBOutlet weak var restDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var sevenDaysData = GoalManager.querySevenDaysData()
    
    convenience init() {
        self.init(nibName: "SportDetailViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let (walk, _, _,_) = sevenDaysData.last!
        let goalWalk = GoalManager.currentGoalInfo()?.dayWalkGoal
        cicleView.update([(Double(walk), deepBlue), (Double(goalWalk! - Int(walk)) , lightBlue)], animated: true)
        
        todayWalkLabel.text = "\(walk)"
        walkPercenageLabel.text = String(format: "%.f%", arguments: [Int(walk) / goalWalk!])
        goalStepLabel.text = "\(goalWalk!)"
        restDescriptionLabel.text = "还需步行\(goalWalk! - Int(walk))步"
        
        tableView.reloadData()
        
        
        let cellNib = UINib(nibName: cellId, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: cellId)
    }
    //

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension SportDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sevenDaysData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! GoalDetailTableViewCell
        
        let colors = [lightBlue, lightBlue, lightBlue, deepBlue, deepBlue]
        let (walk, _, _,_) = sevenDaysData[indexPath.row]
        let goalWalk = GoalManager.currentGoalInfo()?.dayWalkGoal
        
        cell.setColors(colors, step: Int(walk), goalStep: goalWalk!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
}
