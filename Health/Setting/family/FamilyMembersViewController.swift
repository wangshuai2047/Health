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
        let completeInfoController = CompleteInfoViewController()
        completeInfoController.delegate = self
        completeInfoController.canBack = true
        self.navigationController?.pushViewController(completeInfoController, animated: true)
    }
    
    func deleteButtonPressed(button: UIButton) {
        let (userId, _, _) = users[button.tag]
        
        UserManager.shareInstance().deleteUser(userId) { [unowned self] (error: NSError?) -> Void in
            if error == nil {
                self.users = UserManager.shareInstance().queryAllUsers()
                self.tableView.reloadData()
            }
            else {
                Alert.showErrorAlert("删除失败", message: error?.localizedDescription)
            }
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension FamilyMembersViewController: CompleteInfoDelegate {
    // 添加家庭成员
    func completeInfo(controller: CompleteInfoViewController, user: UserModel, phone: String?, organizationCode: String?) {
        UserManager.shareInstance().addUser(user.name, gender: user.gender, age: user.age, height: user.height, imageURL: user.headURL) { [unowned self] (userModel, error: NSError?) -> Void in
            if error == nil {
                self.users = UserManager.shareInstance().queryAllUsers()
                self.tableView.reloadData()
                
                controller.navigationController?.popViewControllerAnimated(true)
            }
            else {
                Alert.showErrorAlert("添加家庭成员失败", message: error?.localizedDescription)
            }
        }
    }
}


extension FamilyMembersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! FamilyMembersCell
        
        if indexPath.row == users.count - 1 {
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
            
            let (_, headURLStr, name) = users[indexPath.row + 1]
            cell.headImageView.sd_setImageWithURL(NSURL(string: UserManager.shareInstance().userHeadURL(headURLStr)), placeholderImage: UIImage(named: "defaultHead"))
            cell.nameLabel.text = name
        }
        
        cell.deleteButton.tag = indexPath.row + 1
        cell.addFamilyButton.addTarget(self, action: Selector("addFamilyButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        cell.deleteButton.addTarget(self, action: Selector("deleteButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76
    }
    
    
    
}