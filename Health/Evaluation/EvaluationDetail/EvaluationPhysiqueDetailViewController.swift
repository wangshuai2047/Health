//
//  EvaluationPhysiqueDetailViewController.swift
//  Health
//
//  Created by Yalin on 15/9/11.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationPhysiqueDetailViewController: UIViewController {
    
    var physique: ScaleResult.Physique?
    
    var physiqueButtonAndViews: [(UIButton, UIView)] = []
    
    convenience init() {
        self.init(nibName: "EvaluationPhysiqueDetailViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionViews()
        
        //为了兼容iOS7，http://stackoverflow.com/questions/15490140/auto-layout-error
        //iOS8下无需这句话
        self.view.layoutSubviews()
    }
    
    func collectionViews() {
        
        physiqueButtonAndViews.removeAll(keepCapacity: true)
        for i in 1...9 {
            let button = self.view.viewWithTag(i) as? UIButton
            let view = self.view.viewWithTag(i + 10)
            
            if physique?.rawValue == i {
                button?.selected = true
            }
            
            if button != nil && view != nil {
                let datas = (button!, view!)
                physiqueButtonAndViews.append(datas)
            }
        }
    }
    
    
    @IBAction func physiqueButtonPressed(sender: UIButton) {
        for (button, view) in physiqueButtonAndViews {
            if button.tag == sender.tag {
                view.hidden = !view.hidden
            }
            else {
                view.hidden = true
            }
        }
        
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
