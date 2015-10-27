//
//  FamilyMembersViewController.swift
//  Health
//
//  Created by Yalin on 15/10/19.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class FamilyMembersViewController: UIViewController {

    private let cellId = "FamilyMembersCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var users = UserManager.shareInstance().queryAllUsers()
    
    var isEditUser: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
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

    func addFamilyButtonPressed() {
        
        isEditUser = false
        let completeInfoController = CompleteInfoViewController()
        completeInfoController.delegate = self
        completeInfoController.canBack = true
        self.navigationController?.pushViewController(completeInfoController, animated: true)
    }
    
    func deleteButtonPressed(button: UIButton) {
        let (userId, _, _) = users[button.tag]
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "删除中", detailMsg: nil, progress: nil)
        UserManager.shareInstance().deleteUser(userId) { [unowned self] (error: NSError?) -> Void in
            if error == nil {
                self.users = UserManager.shareInstance().queryAllUsers()
                self.tableView.reloadData()
            }
            else {
                Alert.showErrorAlert("删除失败", message: error?.localizedDescription)
            }
            AppDelegate.applicationDelegate().hiddenHUD()
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension FamilyMembersViewController: CompleteInfoDelegate {
    // 添加家庭成员
    func completeInfo(controller: CompleteInfoViewController, user: UserModel, phone: String?, organizationCode: String?) {
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.Hotwheels, message: "提交数据", detailMsg: nil, progress: nil)
        if isEditUser {
            UserManager.shareInstance().changeUserInfo(user, complete: { [unowned self] (error: NSError?) -> Void in
                if error == nil {
                    self.users = UserManager.shareInstance().queryAllUsers()
                    self.tableView.reloadData()
                    
                    controller.navigationController?.popViewControllerAnimated(true)
                }
                else {
                    Alert.showErrorAlert("修改家庭成员失败", message: error?.localizedDescription)
                }
                AppDelegate.applicationDelegate().hiddenHUD()
            })
        }
        else {
            UserManager.shareInstance().addUser(user.name, gender: user.gender, age: user.age, height: user.height, imageURL: user.headURL) { [unowned self] (userModel, error: NSError?) -> Void in
                if error == nil {
                    self.users = UserManager.shareInstance().queryAllUsers()
                    self.tableView.reloadData()
                    
                    controller.navigationController?.popToRootViewControllerAnimated(true)
                    UserManager.shareInstance().changeUserToUserId(userModel!.userId)
                    // 成功后直接跳转到评测主页开始评测
                    AppDelegate.applicationDelegate().changeToMainIndex(0)
                    
                }
                else {
                    Alert.showErrorAlert("添加家庭成员失败", message: error?.localizedDescription)
                }
                AppDelegate.applicationDelegate().hiddenHUD()
            }
        }
    }
}


extension FamilyMembersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! FamilyMembersCell
        
        if indexPath.row == users.count {
            cell.addFamilyButton.hidden = false
            cell.headImageView.hidden = true
            cell.nameLabel.hidden = true
            cell.deleteButton.hidden = true
        }
        else {
            cell.addFamilyButton.hidden = true
            cell.headImageView.hidden = false
            cell.nameLabel.hidden = false
            cell.deleteButton.hidden = false
            
            let (_, headURLStr, name) = users[indexPath.row]
            cell.headImageView.sd_setImageWithURL(NSURL(string: headURLStr), placeholderImage: UIImage(named: "defaultHead"))
            cell.nameLabel.text = name
        }
        
        // 主账户不能删除
        if indexPath.row == 0 {
            cell.deleteButton.hidden = true
        }
        
        cell.deleteButton.tag = indexPath.row
        cell.addFamilyButton.addTarget(self, action: Selector("addFamilyButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        cell.deleteButton.addTarget(self, action: Selector("deleteButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let fCell = cell as? FamilyMembersCell {
            fCell.addFamilyButton.removeTarget(self, action: Selector("addFamilyButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
            fCell.deleteButton.removeTarget(self, action: Selector("deleteButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row != users.count {
            // 成员资料修改管理
            let (userId, _, _) = users[indexPath.row]
            isEditUser = true
            let controller = CompleteInfoViewController()
            
            if userId == UserManager.mainUser.userId {
                controller.userModel = UserManager.mainUser
            }
            else {
                controller.userModel = UserManager.shareInstance().queryUser(userId)
            }
            
            controller.canBack = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        
    }
    
}

