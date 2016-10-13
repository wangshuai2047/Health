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
    
    fileprivate let cellId = "ThirdPlatformBindCell"
    fileprivate var thirdPlatformBindListInfo: [[String : Any]] = []
    
    convenience init() {
        self.init(nibName: "ThirdPlatformBindController", bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        thirdPlatformBindListInfo.removeAll()
        // 微信朋友圈
        thirdPlatformBindListInfo.append(["headIcon" : "wechatLogin", "title" : "微信",
            "execute" : { [unowned self] () in
                self.thirdPartBindChange(ShareType.weChatSession)
            },
            "isBind": {() -> Bool in
                return LoginManager.isBindThirdParty(ThirdPlatformType.WeChat)
            }])
        
        // 腾讯
        thirdPlatformBindListInfo.append(["headIcon" : "qqLogin", "title" : "QQ",
            "execute" : {[unowned self] () in
                self.thirdPartBindChange(ShareType.qqFriend)
            },
            "isBind": {() -> Bool in
                return LoginManager.isBindThirdParty(ThirdPlatformType.QQ)
            }])
        
        // 微博
        thirdPlatformBindListInfo.append(["headIcon" : "weiboLogin", "title" : "微博",
            "execute" : { [unowned self] () in
                self.thirdPartBindChange(ShareType.weiBo)
            },
            "isBind": {() -> Bool in
                return LoginManager.isBindThirdParty(ThirdPlatformType.Weibo)
            }])
        
        // 集团账户
        thirdPlatformBindListInfo.append(["headIcon" : "orgazation", "title" : "集团账户",
            "execute" : { [unowned self] () in
                
                if UserData.sharedInstance.organizationCode == nil {
                    BindOrganzationViewController.showBindOrganzationViewController(self, rootController: self)
                }
                else {
                    
                    BindOrganzationViewController.cancelBind({[unowned self] (error: NSError?) -> Void in
                        if error == nil {
                            UserData.sharedInstance.organizationCode = nil
                            self.tableView.reloadData()
                        }
                        else {
                            Alert.showError(error!)
                        }
                        })
                }
            },
            "isBind": {() -> Bool in
                return UserData.sharedInstance.organizationCode != nil
            }])
        
        
        if UserData.sharedInstance.phone == nil {
            // 手机号
            thirdPlatformBindListInfo.append(["headIcon" : "phone", "title" : "手机号",
                "execute" : { [unowned self] () in
                    
                    if UserData.sharedInstance.phone != nil {
                        
                        BindPhoneViewController.cancelBind({ [unowned self] (error: NSError?) -> Void in
                            if error == nil {
                                UserData.sharedInstance.phone = nil
                                self.tableView.reloadData()
                            }
                            else {
                                Alert.showError(error!)
                            }
                            })
                        
                    }
                    else {
                        BindPhoneViewController.showBindPhoneViewController(self, rootController: self)
                    }
                },
                "isBind": {() -> Bool in
                    return UserData.sharedInstance.phone != nil
                }])
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let cellNib = UINib(nibName: cellId, bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: cellId)
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

    func bindButtonPressed(_ button: UIButton) {
        let info = thirdPlatformBindListInfo[button.tag]
        let execute = info["execute"] as! () -> Void
        execute()
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 业务执行
    func thirdPartBindChange(_ type: ShareType) {
        
        let pType: ThirdPlatformType
        if type == ShareType.qqFriend {
            pType = ThirdPlatformType.QQ
        }
        else if type == ShareType.weiBo {
            pType = ThirdPlatformType.Weibo
        }
        else {
            pType = ThirdPlatformType.WeChat
        }
        
        
        if LoginManager.isBindThirdParty(pType) {
            LoginManager.cancelBindThirdParty(pType, complete: {[unowned self] (error: NSError?) -> Void in
                if error == nil {
                    self.tableView.reloadData()
                }
                else {
                    Alert.showErrorAlert("改变失败", message: error!.localizedDescription)
                }
            })
        }
        else {
            LoginManager.bindThirdParty(pType, complete: {[unowned self] (error: NSError?) -> Void in
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
    func bindFinished(_ codeOrCode: String?, error: NSError?) {
        if error == nil {
            self.tableView.reloadData()
        }
    }
}

extension ThirdPlatformBindController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thirdPlatformBindListInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ThirdPlatformBindCell
        
        let info = thirdPlatformBindListInfo[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = info["title"] as? String
        cell.headImageView.image = UIImage(named: info["headIcon"] as! String)
        cell.bindButton.tag = (indexPath as NSIndexPath).row
        
        cell.bindButton.addTarget(self, action: Selector("bindButtonPressed:"), for: UIControlEvents.touchUpInside)
        
        let isBind = info["isBind"] as! () -> Bool
        cell.bindButton.isSelected = isBind()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let c = cell as? ThirdPlatformBindCell {
            c.bindButton.removeTarget(self, action: Selector("bindButtonPressed:"), for: UIControlEvents.touchUpInside)
        }
        
    }
}
