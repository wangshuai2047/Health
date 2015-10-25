//
//  SettingViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    // 数据格式为  (ImageName, Title, 进入的Controller)
    var list: [(String, String, UIViewController)] = [
//        ("membersManager", "成员资料修改管理", UIViewController()),
        ("membersManager", "人员资料修改管理", FamilyMembersViewController()),
        ("socialBind", "社交账号绑定管理", ThirdPlatformBindController()),
        ("deviceManager", "健康设备管理", DeviceBindViewController()),
        ("feedback", "用户建议反馈", FeedBackViewController()),
//        ("HealthCenterBind", "健康中心绑定", UIViewController()),
//        ("checkUpdate", "检查软件更新", UIViewController()),
    ]
//    var list: [(String, String, UIViewController)] = [
//        ("membersManager", "成员资料修改管理", UIViewController()),
//        ("socialBind", "社交账号绑定管理", UIViewController()),
//        ("deviceManager", "健康设备管理", UIViewController()),
//        ("HealthCenterBind", "健康中心绑定", UIViewController()),
//        ("checkUpdate", "检查软件更新", UIViewController()),
//        ("feedback", "用户建议反馈", UIViewController()),
//    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
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

}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // +1 最后一项是退出登录
        return list.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "SettingTableViewCellId"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        
        if indexPath.row == list.count {
            cell?.imageView?.image = UIImage()
            cell?.textLabel?.text = "退出登录"
        } else {
            let (imageName, title, _) = list[indexPath.row]
            cell?.imageView?.image = UIImage(named: imageName)
            cell?.textLabel?.text = title
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == list.count {
            SettingManager.removeLocalNotification()
            LoginManager.logout()
            AppDelegate.applicationDelegate().changeToLoginController()
        }
        else if indexPath.row == -1 {
            // 成员资料修改管理
            let controller = CompleteInfoViewController()
            controller.userModel = UserManager.mainUser
            controller.canBack = true
            controller.delegate = self
            AppDelegate.rootNavgationViewController().pushViewController(controller, animated: true)
        }
//        else if indexPath.row == 1 {
//            // 社交账号绑定管理
//        }
//        else if indexPath.row == 2 {
//            // 健康设备绑定管理
//        }
//        else if indexPath.row == 3 {
//            // 健康中心绑定管理管理
//        }
//        else if indexPath.row == 4 {
//            // 检查软件更新
//        }
//        else if indexPath.row == 5 {
//            // 用户反馈管理
//        }
        else {
            let (_, _, controller) = list[indexPath.row]
            AppDelegate.rootNavgationViewController().pushViewController(controller, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
}

extension SettingViewController: CompleteInfoDelegate {
    
    func completeInfo(controller: CompleteInfoViewController, user: UserModel, phone: String?, organizationCode: String?) {
        
        LoginManager.completeInfomation(user.name, gender: user.gender, age: user.age, height: UInt8(user.height), phone: phone, organizationCode: organizationCode, headURL:user.headURL, complete: { (error) -> Void in
            
            if error == nil {
                // 跳转到主页
                controller.navigationController?.popViewControllerAnimated(true)
            }
            else {
                UIAlertView(title: "完善信息失败", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "确定").show()
            }
        })
    }
}
