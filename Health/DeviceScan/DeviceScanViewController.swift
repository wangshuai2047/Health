//
//  DeviceScanViewController.swift
//  Health
//
//  Created by Yalin on 15/10/11.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

protocol DeviceScanViewControllerProtocol {
    func didSelected(controller: DeviceScanViewController, device: DeviceManagerProtocol)
}

class DeviceScanViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var scanTypes: [DeviceType]?
    var scanResult: [DeviceManagerProtocol] = []
    let cellId = "DeviceScanCell"
    
    var delegate: DeviceScanViewControllerProtocol?
    
    class func showDeviceScanViewController(scanTypes: [DeviceType]?, delegate: DeviceScanViewControllerProtocol?, rootController: UIViewController) {
        
        let controller = DeviceScanViewController()
        controller.scanTypes = scanTypes
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
        self.init(nibName: "DeviceScanViewController", bundle: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let cellNib = UINib(nibName: cellId, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: cellId)
        
        BluetoothManager.shareInstance.scanDevice(scanTypes) { [unowned self] (results: [DeviceManagerProtocol], error: NSError?) -> Void in
            self.scanResult = results
            self.tableView.reloadData()
        }
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
        BluetoothManager.shareInstance.stopScanDevice()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension DeviceScanViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanResult.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! DeviceScanCell
        
        let device = scanResult[indexPath.row]
        
        cell.iconImageView.image = UIImage(named: "weiboLogin")
        cell.nameLabel.text = device.name
        cell.uuidLabel.text = device.uuid
        cell.rssiLabel.text = "\(device.RSSI.integerValue)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let device = scanResult[indexPath.row]
        BluetoothManager.shareInstance.stopScanDevice()
        delegate?.didSelected(self, device: device)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
