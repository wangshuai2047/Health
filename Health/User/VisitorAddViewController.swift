//
//  VisitorAddViewController.swift
//  Health
//
//  Created by Yalin on 15/10/8.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

protocol VisitorAddDelegate {
    func completeInfo(_ controller: VisitorAddViewController, user: UserModel)
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
        maleButton.isSelected = true
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
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func sexButtonPressed(_ sender: UIButton) {
        if sender == maleButton {
            maleButton.isSelected = true
            femaleButton.isSelected = false
        }
        else {
            maleButton.isSelected = false
            femaleButton.isSelected = true
        }
    }
    
    
    @IBAction func sureButtonPressed(_ sender: AnyObject) {
        
        let user = UserModel(userId: -1, age: ageTextField.text!.UInt8Value, gender: maleButton.isSelected ? true : false, height: heightTextField.text!.UInt8Value, name: "访客", headURL: nil)
        
        delegate?.completeInfo(self, user: user)
        
        closeButtonPressed(sender)
    }
    
    @IBAction func backgroundPressed(_ sender: AnyObject) {
        ageTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
    }
}
