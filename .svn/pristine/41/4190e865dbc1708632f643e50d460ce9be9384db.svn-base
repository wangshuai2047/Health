//
//  EvaluationPhysiqueIntroduceViewController.swift
//  Health
//
//  Created by Yalin on 15/10/23.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationPhysiqueIntroduceViewController: UIViewController {

    var introduce: String?
    var introduceTitle: String?
    var rootImage: UIImage?
    
    
    @IBOutlet weak var blurView: FXBlurView!
    @IBOutlet weak var rootControllerImageView: UIImageView!
    @IBOutlet weak var introduceTitleLabel: UILabel!
    @IBOutlet weak var introduceTextView: UITextView!
    
    class func showEvaluationPhysiqueIntroduceViewController(_ introduceTitle: String, introduce: String, rootController: UIViewController) {
        
        let controller = EvaluationPhysiqueIntroduceViewController()
        controller.introduce = introduce
        controller.introduceTitle = introduceTitle
        controller.rootImage = rootController.view.convertToImage()
        if #available(iOS 8.0, *) {
//            controller.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        } else {
            // Fallback on earlier versions
//            controller.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        }
        // UIModalPresentationFormSheet
        rootController.present(controller, animated: true, completion: nil)
//        rootController.presentViewController(controller, animated: true) { () -> Void in
//            controller.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
//        }
    }
    
    convenience init() {
        self.init(nibName: "EvaluationPhysiqueIntroduceViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.introduceTitleLabel.text = introduceTitle
        self.introduceTextView.text = introduce
        self.rootControllerImageView.image = rootImage
        
//        self.blurView.blurRadius = 40;
//        blurView.dynamic = true
        blurView.blurRadius = 20
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
}
