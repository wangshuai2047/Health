//
//  BindOrganzationViewController.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

protocol BindOrganzationViewControllerDelegate {
    func bindFinished(_ code: String?, error: NSError?)
}

class BindOrganzationViewController: UIViewController {

    var delegate: BindOrganzationViewControllerDelegate?
    
    @IBOutlet weak var codeTextField: UITextField!
    
    class func showBindOrganzationViewController(_ delegate: BindOrganzationViewControllerDelegate?, rootController: UIViewController) {
        
        let controller = BindOrganzationViewController()
        controller.delegate = delegate
        if #available(iOS 8.0, *) {
            controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        } else {
            // Fallback on earlier versions
            controller.modalPresentationStyle = UIModalPresentationStyle.currentContext
        }
        // UIModalPresentationFormSheet
        rootController.present(controller, animated: true) { () -> Void in
            controller.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
    }
    
    class func cancelBind(_ complete: @escaping (NSError?) -> Void) {
        LoginManager.completeInfomation(UserData.sharedInstance.name!, gender: UserData.sharedInstance.gender!, age: UserData.sharedInstance.age!, height: UserData.sharedInstance.height!, phone: UserData.sharedInstance.phone, organizationCode: nil, headURL: UserData.sharedInstance.headURL, complete: complete)
    }
    
    convenience init() {
        self.init(nibName: "BindOrganzationViewController", bundle: nil)
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

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sureButtonPressed(_ sender: AnyObject) {
        LoginManager.completeInfomation(UserData.sharedInstance.name!, gender: UserData.sharedInstance.gender!, age: UserData.sharedInstance.age!, height: UserData.sharedInstance.height!, phone: UserData.sharedInstance.phone, organizationCode: self.codeTextField.text == nil || self.codeTextField.text! == "" ? nil : self.codeTextField.text, headURL: UserData.sharedInstance.headURL) { [unowned self] (error: NSError?) -> Void in
            
            self.delegate?.bindFinished(self.codeTextField.text == nil || self.codeTextField.text == "" ? nil : self.codeTextField.text, error: error)
            
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                Alert.showError(error!)
            }
        }
    }
}
