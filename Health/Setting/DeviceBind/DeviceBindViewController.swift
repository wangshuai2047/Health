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
    
    fileprivate let cellId = "DeviceBindCell"
    fileprivate var deviceBindListInfo: [[String : Any]] = []
    
    convenience init() {
        self.init(nibName: "DeviceBindViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let cellNib = UINib(nibName: cellId, bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: cellId)
        
        // Mybodymini
//        deviceBindListInfo.append(["headIcon" : "blue_circle_bg", "title" : "Mybodymini", "type" : DeviceType.MyBodyMini, "execute" : { [unowned self] (isBind: Bool) in
//                self.bindDevice([DeviceType.MyBodyMini], isBind: isBind)
//            }])
        
        // Mybody
//        deviceBindListInfo.append(["headIcon" : "blue_circle_bg", "title" : "Mybody", "type" : DeviceType.MyBody, "execute" : { [unowned self] (isBind: Bool) in
//                self.bindDevice([DeviceType.MyBody], isBind: isBind)
//            }])
        
        // MybodyPlus
//        deviceBindListInfo.append(["headIcon" : "blue_circle_bg", "title" : "MybodyPlus", "type" : DeviceType.MyBodyPlus, "execute" : { [unowned self] (isBind: Bool) in
//                self.bindDevice([DeviceType.MyBodyPlus], isBind: isBind)
//            }])
        
        // 好知体手环
        deviceBindListInfo.append(["headIcon" : "green_circle_bg", "title" : "MyStep", "type" : DeviceType.bracelet, "execute" : { [unowned self] (isBind: Bool) in
                self.bindDevice([DeviceType.bracelet], isBind: isBind)
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

    func bindDevice(_ types: [DeviceType], isBind: Bool) {
        if isBind {
            DeviceScanViewController.showDeviceScanViewController(types, delegate: self, rootController: self)
        }
        else {
            SettingManager.unBindDevice(types)
            self.tableView.reloadData()
        }
    }
    
    func bindButtonPressed(_ button: UIButton) {
        let info = deviceBindListInfo[button.tag]
        let execute = info["execute"] as! (Bool) -> Void
        execute(!button.isSelected)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension DeviceBindViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceBindListInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DeviceBindCell
        
        let info = deviceBindListInfo[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = info["title"] as? String
        cell.headImageView.image = UIImage(named: info["headIcon"] as! String)
        cell.bindButton.tag = (indexPath as NSIndexPath).row
        cell.bindButton.removeTarget(self, action: #selector(DeviceBindViewController.bindButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        cell.bindButton.addTarget(self, action: #selector(DeviceBindViewController.bindButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        cell.bindButton.isSelected = SettingManager.isBindDevice([info["type"] as! DeviceType])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }
}

extension DeviceBindViewController: DeviceScanViewControllerProtocol {
    func didSelected(_ controller: DeviceScanViewController, device: DeviceManagerProtocol) {
        // 绑定
        SettingManager.bindDevice(device)
        
        self.tableView.reloadData()
    }
}
