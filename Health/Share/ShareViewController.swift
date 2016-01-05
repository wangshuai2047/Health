//
//  ShareViewController.swift
//  Health
//
//  Created by Yalin on 15/10/9.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

protocol ShareViewControllerDelegate {
    func shareFinished(shareType: ShareType, error: NSError?)
}

class ShareViewController: UIViewController {

    var delegate: ShareViewControllerDelegate?
    var shareImage: UIImage?
    
    @IBOutlet weak var weChatFriendButton: UIButton!
    @IBOutlet weak var weChatFriendLabel: UILabel!
    @IBOutlet weak var weChatSessionButton: UIButton!
    @IBOutlet weak var weChatSessionLabel: UILabel!
    @IBOutlet weak var qqButton: UIButton!
    @IBOutlet weak var qqLabel: UILabel!
    @IBOutlet weak var sinaButton: UIButton!
    @IBOutlet weak var sinaLabel: UILabel!
    
    
    class func showShareViewController(image: UIImage, delegate: ShareViewControllerDelegate?, rootController: UIViewController) {
        
        let controller = ShareViewController()
        controller.shareImage = image
        controller.delegate = delegate
        if #available(iOS 8.0, *) {
            controller.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        } else {
            // Fallback on earlier versions
            controller.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        }
        // UIModalPresentationFormSheet
        rootController.presentViewController(controller, animated: true) { () -> Void in
            controller.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
    }
    
    convenience init() {
        self.init(nibName: "ShareViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        qqButton.hidden = !LoginManager.isExistShareApp(ShareType.QQFriend)
        qqLabel.hidden = !LoginManager.isExistShareApp(ShareType.QQFriend)
        
        weChatFriendButton.hidden = !LoginManager.isExistShareApp( ShareType.WeChatTimeline)
        weChatFriendLabel.hidden = !LoginManager.isExistShareApp( ShareType.WeChatTimeline)
        weChatSessionButton.hidden = !LoginManager.isExistShareApp( ShareType.WeChatTimeline)
        weChatSessionLabel.hidden = !LoginManager.isExistShareApp( ShareType.WeChatTimeline)
        
        sinaButton.hidden = !LoginManager.isExistShareApp(ShareType.WeiBo)
        sinaLabel.hidden = !LoginManager.isExistShareApp(ShareType.WeiBo)
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

    @IBAction func shareButtonPressed(sender: UIButton) {
        
        
        if shareImage == nil {
            self.delegate?.shareFinished(ShareType(rawValue: sender.tag)!, error: NSError(domain: "分享失败", code: -2, userInfo: [NSLocalizedDescriptionKey : "分享图片为空"]))
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        EvaluationManager.shareInstance().share(ShareType(rawValue: sender.tag)!, image: shareImage!) { [unowned self] (error: NSError?) -> Void in
            self.delegate?.shareFinished(ShareType(rawValue: sender.tag)!, error: error)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
}
