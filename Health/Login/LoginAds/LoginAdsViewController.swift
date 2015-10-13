//
//  LoginAdsViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class LoginAdsViewController: UIViewController {

    @IBOutlet weak var adTimerButton: UIButton!
    @IBOutlet weak var adImageView: UIImageView!
    
    convenience init() {
        self.init(nibName: "LoginAdsViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Response Method
    @IBAction func adTimerButtonPressed(sender: AnyObject) {
        
        if LoginManager.showedGUI {
            
            let loginController = LoginViewController()
            self.navigationController?.pushViewController(loginController, animated: true)
        }
        else {
            let guiController = GUIViewController()
            self.navigationController?.pushViewController(guiController, animated: true)
        }
    }
    
    @IBAction func enterUrlButtonPressed(sender: AnyObject) {
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
