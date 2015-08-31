//
//  GoalViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController {

    @IBOutlet weak var goalDetailLabel: AttributedLabel!
    @IBOutlet weak var suggestCalorieLabel: AttributedLabel!
    
    @IBOutlet weak var connectDeviceView: UIView!
    @IBOutlet weak var sportDetailLabel: AttributedLabel!
    @IBOutlet weak var sleepDetailLabel: AttributedLabel!
    
    @IBOutlet weak var noDeviceView: UIView!
    @IBOutlet weak var noDeviceDetailLabel: AttributedLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
        
        showView(GoalManager.isConnectDevice() ? connectDeviceView : noDeviceView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - set View
    func setGoalDetail() {
        
    }
    
    func setSuggestCalorie() {
        
    }
    
    func setConnectDevice() {
        
    }
    
    func setSportDetail() {
        
    }
    
    func setSleepDetail() {
        
    }
    
    func setNoDeviceView() {
        
    }

    func showView(view: UIView) {
        noDeviceView.hidden = true
        connectDeviceView.hidden = true
        view.hidden = false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button Response
    @IBAction func setGoalPressed(sender: AnyObject) {
        
    }

    @IBAction func showSportDetailPressed(sender: AnyObject) {
        AppDelegate.rootNavgationViewController().pushViewController(SportDetailViewController(), animated: true)
    }
    
    @IBAction func showSleepDetailPressed(sender: AnyObject) {
        AppDelegate.rootNavgationViewController().pushViewController(SleepDetailViewController(), animated: true)
    }
    
    @IBAction func buyDevicePressed(sender: AnyObject) {
    }
    
    @IBAction func bindDevicePressed(sender: AnyObject) {
    }
    
    
    
    
}
