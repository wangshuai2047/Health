//
//  DeviceBindViewController.swift
//  Health
//
//  Created by Yalin on 15/10/6.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class DeviceBindViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let cellId = "DeviceBindCell"
    private var deviceBindListInfo: [[String : Any]] = []
    
    convenience init() {
        self.init(nibName: "DeviceBindViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let cellNib = UINib(nibName: cellId, bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: cellId)
        
        // Mybodymini
        deviceBindListInfo.append(["headIcon" : "wechatLogin", "title" : "Mybodymini", "execute" : { [unowned self] (isBind: Bool) in
                self.bindDevice([DeviceType.MyBodyMini], isBind: isBind)
            }])
        
        // Mybody
        deviceBindListInfo.append(["headIcon" : "qqLogin", "title" : "Mybody", "execute" : { [unowned self] (isBind: Bool) in
                self.bindDevice([DeviceType.MyBody], isBind: isBind)
            }])
        
        // MybodyPlus
        deviceBindListInfo.append(["headIcon" : "weiboLogin", "title" : "MybodyPlus", "execute" : { [unowned self] (isBind: Bool) in
                self.bindDevice([DeviceType.MyBodyPlus], isBind: isBind)
            }])
        
        // 好知体手环
        deviceBindListInfo.append(["headIcon" : "weiboLogin", "title" : "好知体手环", "execute" : { [unowned self] (isBind: Bool) in
                self.bindDevice([DeviceType.Bracelet], isBind: isBind)
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

    func bindDevice(types: [DeviceType], isBind: Bool) {
        if isBind {
            DeviceScanViewController.showDeviceScanViewController(types, delegate: self, rootController: self)
        }
        else {
            SettingManager.unBindDevice(types)
        }
    }
    
    func bindButtonPressed(button: UIButton) {
        let info = deviceBindListInfo[button.tag]
        let execute = info["execute"] as! (Bool) -> Void
        execute(button.selected)
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension DeviceBindViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceBindListInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! DeviceBindCell
        
        let info = deviceBindListInfo[indexPath.row]
        cell.titleLabel.text = info["title"] as? String
        cell.headImageView.image = UIImage(named: info["headIcon"] as! String)
        cell.bindButton.tag = indexPath.row
        cell.bindButton.removeTarget(self, action: Selector("bindButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        cell.bindButton.addTarget(self, action: Selector("bindButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
//        cell.bindButton.selected
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 116
    }
}

extension DeviceBindViewController: DeviceScanViewControllerProtocol {
    func didSelected(controller: DeviceScanViewController, device: DeviceManagerProtocol) {
        // 绑定
        SettingManager.bindDevice(device)
    }
}
