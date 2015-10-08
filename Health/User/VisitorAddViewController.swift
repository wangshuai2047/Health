//
//  VisitorAddViewController.swift
//  Health
//
//  Created by Yalin on 15/10/8.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

protocol VisitorAddDelegate {
    func completeInfo(controller: VisitorAddViewController, user: UserModel)
}

class VisitorAddViewController: UIViewController {

    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    
    var delegate: VisitorAddDelegate?
    
    convenience init() {
        self.init(nibName: "VisitorAddViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        maleButton.selected = true
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
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func sexButtonPressed(sender: UIButton) {
        if sender == maleButton {
            maleButton.selected = true
            femaleButton.selected = false
        }
        else {
            maleButton.selected = false
            femaleButton.selected = true
        }
    }
    
    
    @IBAction func sureButtonPressed(sender: AnyObject) {
        
        let user = UserModel(userId: -1, age: ageTextField.text!.UInt8Value, gender: maleButton.selected ? true : false, height: heightTextField.text!.UInt8Value, name: "访客", headURL: nil)
        
        delegate?.completeInfo(self, user: user)
        
        closeButtonPressed(sender)
    }
    
    @IBAction func backgroundPressed(sender: AnyObject) {
        ageTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
    }
}
