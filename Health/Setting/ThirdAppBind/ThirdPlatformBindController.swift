//
//  ThirdPlatformBindController.swift
//  Health
//
//  Created by Yalin on 15/10/6.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class ThirdPlatformBindController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let cellId = "ThirdPlatformBindCell"
    private var thirdPlatformBindListInfo: [[String : Any]] = []
    
    convenience init() {
        self.init(nibName: "ThirdPlatformBindController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let cellNib = UINib(nibName: cellId, bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: cellId)
        
        // 微信朋友圈
        thirdPlatformBindListInfo.append(["headIcon" : "wechatLogin", "title" : "微信朋友圈",
            "execute" : { [unowned self] () in
                self.thirdPartBindChange(ShareType.WeChatSession)
            },
            "isBind": {() -> Bool in
                return LoginManager.isBindThirdParty(ThirdPlatformType.WeChat)
            }])
        
        // 腾讯
        thirdPlatformBindListInfo.append(["headIcon" : "qqLogin", "title" : "腾讯",
            "execute" : {[unowned self] () in
                self.thirdPartBindChange(ShareType.QQFriend)
            },
            "isBind": {() -> Bool in
                return LoginManager.isBindThirdParty(ThirdPlatformType.QQ)
            }])
        
        // 微博
        thirdPlatformBindListInfo.append(["headIcon" : "weiboLogin", "title" : "微博",
            "execute" : { [unowned self] () in
                self.thirdPartBindChange(ShareType.WeiBo)
            },
            "isBind": {() -> Bool in
                return LoginManager.isBindThirdParty(ThirdPlatformType.Weibo)
            }])
        
        // 集团账户
        thirdPlatformBindListInfo.append(["headIcon" : "orgazation", "title" : "集团账户",
            "execute" : { [unowned self] () in
                BindOrganzationViewController.showBindOrganzationViewController(self, rootController: self)
            },
            "isBind": {() -> Bool in
                return UserData.shareInstance().organizationCode != nil
            }])
        
        // 手机号
        thirdPlatformBindListInfo.append(["headIcon" : "phone", "title" : "手机号",
            "execute" : { [unowned self] () in
                BindPhoneViewController.showBindPhoneViewController(self, rootController: self)
            },
            "isBind": {() -> Bool in
                return UserData.shareInstance().phone != nil
            }])
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

    func bindButtonPressed(button: UIButton) {
        let info = thirdPlatformBindListInfo[button.tag]
        let execute = info["execute"] as! () -> Void
        execute()
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - 业务执行
    func thirdPartBindChange(type: ShareType) {
        
        let pType: ThirdPlatformType
        if type == ShareType.QQFriend {
            pType = ThirdPlatformType.QQ
        }
        else if type == ShareType.WeiBo {
            pType = ThirdPlatformType.Weibo
        }
        else {
            pType = ThirdPlatformType.WeChat
        }
        
        
        if LoginManager.isBindThirdParty(pType) {
            LoginManager.cancelBindThirdParty(pType, complete: { (error: NSError?) -> Void in
                if error == nil {
                    self.tableView.reloadData()
                }
                else {
                    Alert.showErrorAlert("改变失败", message: error!.localizedDescription)
                }
            })
        }
        else {
            LoginManager.bindThirdParty(pType, complete: { (error: NSError?) -> Void in
                if error == nil {
                    self.tableView.reloadData()
                }
                else {
                    Alert.showErrorAlert("改变失败", message: error!.localizedDescription)
                }
            })
        }
    }
}

extension ThirdPlatformBindController: BindOrganzationViewControllerDelegate, BindPhoneViewControllerDelegate {
    func bindFinished(codeOrCode: String?, error: NSError?) {
        if error == nil {
            self.tableView.reloadData()
        }
    }
}

extension ThirdPlatformBindController : UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thirdPlatformBindListInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! ThirdPlatformBindCell
        
        let info = thirdPlatformBindListInfo[indexPath.row]
        cell.titleLabel.text = info["title"] as? String
        cell.headImageView.image = UIImage(named: info["headIcon"] as! String)
        cell.bindButton.tag = indexPath.row
        
        cell.bindButton.addTarget(self, action: Selector("bindButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let isBind = info["isBind"] as! () -> Bool
        cell.bindButton.selected = isBind()
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 116
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let c = cell as? ThirdPlatformBindCell {
            c.bindButton.removeTarget(self, action: Selector("bindButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
    }
}
