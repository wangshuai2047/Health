//
//  EvaluationPhysiqueDetailViewController.swift
//  Health
//
//  Created by Yalin on 15/9/11.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationPhysiqueDetailViewController: UIViewController {
    
    var physique: Physique?
    
    let selectedColor = UIColor(red: 0, green: 64/255.0, blue: 128/255.0, alpha: 1)
    let selectedFemailColor = UIColor(red: 215/255.0, green: 148/255.0, blue: 239/255.0, alpha: 1)
    
    convenience init() {
        self.init(nibName: "EvaluationPhysiqueDetailViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if physique != nil {
            let (titleLabel, button, _) = labelAndButtonAndIntroduceView(self.view.viewWithTag(physique!.rawValue + 10)!)
            titleLabel.textColor = UserManager.shareInstance().currentUser.gender ? selectedColor : selectedFemailColor
            button.selected = true
        }
        
        //为了兼容iOS7，http://stackoverflow.com/questions/15490140/auto-layout-error
        //iOS8下无需这句话
        self.view.layoutSubviews()
    }
    
    func labelAndButtonAndIntroduceView(view: UIView) -> (UILabel, UIButton, UIView) {
        let titleLabel = view.viewWithTag(1) as! UILabel
        let button = view.viewWithTag(2) as! UIButton
        let introduceView = view.viewWithTag(3)
        
        return (titleLabel, button, introduceView!)
    }
    
    func refreshView() {
        for i in 11...19 {
            let currtentview = self.view.viewWithTag(i)!
            let (titleLabel, button, _) = labelAndButtonAndIntroduceView(currtentview)
            
            let physique = Physique(rawValue: i - 10)
            
            titleLabel.textColor = UserManager.shareInstance().currentUser.gender ? selectedColor : selectedFemailColor
            button.setImage(UIImage(named: physique!.imageName(UserManager.shareInstance().currentUser.gender)), forState: UIControlState.Normal)
            button.setImage(UIImage(named: physique!.selectedImageName(UserManager.shareInstance().currentUser.gender)), forState: UIControlState.Selected)
        }
    }
    
    @IBAction func physiqueButtonPressed(sender: UIButton) {
        
        if let view = sender.superview {
            for i in 11...19 {
                let currtentview = self.view.viewWithTag(i)!
                let (_, _, introduceView) = labelAndButtonAndIntroduceView(currtentview)
                
                if i == view.tag {
                    introduceView.hidden = !introduceView.hidden
                }
                else {
                    introduceView.hidden = true
                }
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
