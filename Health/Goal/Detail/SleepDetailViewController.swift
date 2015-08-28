//
//  SleepDetailViewController.swift
//  Health
//
//  Created by Yalin on 15/8/24.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class SleepDetailViewController: UIViewController {

    @IBOutlet weak var cicleView: CircleView!
    
    convenience init() {
        self.init(nibName: "SleepDetailViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

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
