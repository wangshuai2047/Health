//
//  FamilyMembersViewController.swift
//  Health
//
//  Created by Yalin on 15/10/19.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class FamilyMembersViewController: UIViewController {

    fileprivate let cellId = "FamilyMembersCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var users = UserManager.sharedInstance.queryAllUsers()
    
    var isEditUser: Bool = false
    
    convenience init() {
        self.init(nibName: "FamilyMembersViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        users = UserManager.sharedInstance.queryAllUsers()
        tableView.reloadData()
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
    
    func deleteButtonPressed(_ button: UIButton) {
        let (userId, _, _) = users[button.tag]
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.hotwheels, message: "删除中", detailMsg: nil, progress: nil)
        UserManager.sharedInstance.deleteUser(userId) { [unowned self] (error: NSError?) -> Void in
            if error == nil {
                self.users = UserManager.sharedInstance.queryAllUsers()
                self.tableView.reloadData()
            }
            else {
                Alert.showErrorAlert("删除失败", message: error?.localizedDescription)
            }
            AppDelegate.applicationDelegate().hiddenHUD()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FamilyMembersViewController: CompleteInfoDelegate {
    // 添加家庭成员
    func completeInfo(_ controller: CompleteInfoViewController, user: UserModel, phone: String?, organizationCode: String?) {
        
        AppDelegate.applicationDelegate().updateHUD(HUDType.hotwheels, message: "提交数据", detailMsg: nil, progress: nil)
        if isEditUser {
            UserManager.sharedInstance.changeUserInfo(user, phone: phone, organizationCode: organizationCode, complete: { [unowned self] (error: NSError?) -> Void in
                if error == nil {
                    self.users = UserManager.sharedInstance.queryAllUsers()
                    self.tableView.reloadData()
                    
                    controller.navigationController?.popViewController(animated: true)
                }
                else {
                    Alert.showErrorAlert("修改家庭成员失败", message: error?.localizedDescription)
                }
                AppDelegate.applicationDelegate().hiddenHUD()
            })
        }
        else {
            UserManager.sharedInstance.addUser(user.name, gender: user.gender, age: user.age, height: user.height, imageURL: user.headURL) { [unowned self] (userModel, error: NSError?) -> Void in
                if error == nil {
                    self.users = UserManager.sharedInstance.queryAllUsers()
                    self.tableView.reloadData()
                    
                    controller.navigationController?.popToRootViewController(animated: true)
                    UserManager.sharedInstance.changeUserToUserId(userModel!.userId)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! FamilyMembersCell
        
        if (indexPath as NSIndexPath).row == users.count {
            cell.addFamilyButton.isHidden = false
            cell.headImageView.isHidden = true
            cell.nameLabel.isHidden = true
            cell.deleteButton.isHidden = true
        }
        else {
            cell.addFamilyButton.isHidden = true
            cell.headImageView.isHidden = false
            cell.nameLabel.isHidden = false
            cell.deleteButton.isHidden = false
            
            let (_, headURLStr, name) = users[(indexPath as NSIndexPath).row]
            cell.headImageView.sd_setImage(with: URL(string: headURLStr), placeholderImage: UIImage(named: "defaultHead"))
            cell.nameLabel.text = name
        }
        
        // 主账户不能删除
        if (indexPath as NSIndexPath).row == 0 {
            cell.deleteButton.isHidden = true
        }
        
        cell.deleteButton.tag = (indexPath as NSIndexPath).row
        cell.addFamilyButton.addTarget(self, action: #selector(FamilyMembersViewController.addFamilyButtonPressed), for: UIControlEvents.touchUpInside)
        cell.deleteButton.addTarget(self, action: #selector(FamilyMembersViewController.deleteButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let fCell = cell as? FamilyMembersCell {
            fCell.addFamilyButton.removeTarget(self, action: #selector(FamilyMembersViewController.addFamilyButtonPressed), for: UIControlEvents.touchUpInside)
            fCell.deleteButton.removeTarget(self, action: #selector(FamilyMembersViewController.deleteButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row != users.count {
            // 成员资料修改管理
            let (userId, _, _) = users[(indexPath as NSIndexPath).row]
            isEditUser = true
            let controller = CompleteInfoViewController()
            
            if userId == UserManager.mainUser.userId {
                controller.userModel = UserManager.mainUser
            }
            else {
                controller.userModel = UserManager.sharedInstance.queryUser(userId)
            }
            
            controller.canBack = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        
    }
    
}

