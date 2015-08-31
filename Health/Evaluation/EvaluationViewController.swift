//
//  EvaluationViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationViewController: UIViewController {

    @IBOutlet weak var userSelectView: UserSelectView!
    @IBOutlet weak var notConnectDeviceView: UIView!
    @IBOutlet weak var connectDeviceView: UIView!
    
    @IBOutlet weak var manualInputDataView: UIView!
    @IBOutlet weak var weightInputDataTextField: UITextField!
    @IBOutlet weak var waterContentInputDataTextField: UITextField!
    @IBOutlet weak var visceralFatContentInputDataTextField: UITextField!
    
    @IBOutlet weak var evaluationResultView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var adviceLabel: UILabel!
    @IBOutlet weak var metabolismLabel: UILabel!
    @IBOutlet weak var metabolismLevelLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightLevelLabel: UILabel!
    @IBOutlet weak var fattyLiverLabel: UILabel!
    @IBOutlet weak var fattyLiverLevelLabel: UILabel!
    @IBOutlet weak var bodyFatLabel: UILabel!
    @IBOutlet weak var bodyFatLevelLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.\
        self.navigationController?.navigationBarHidden = true
        
        if EvaluationManager.shareInstance().isConnectedMyBodyDevice {
            showView(connectDeviceView)
        }
        else {
            showView(notConnectDeviceView)
            EvaluationManager.shareInstance().scan({[unowned self] (error) -> Void in
                self.showView(self.connectDeviceView)
            })
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
    
    // MARK: - Response Method
    
    @IBAction func backgroundPressed(sender: AnyObject) {
        self.weightInputDataTextField.resignFirstResponder()
        self.waterContentInputDataTextField.resignFirstResponder()
        self.visceralFatContentInputDataTextField.resignFirstResponder()
    }
    // MARK: - notConnectDeviceView Response Method
    @IBAction func buyDevicePressed(sender: AnyObject) {
        
    }

    @IBAction func enterMyBodyDataPressed(sender: AnyObject) {
        showView(manualInputDataView)
    }
    
    @IBAction func scanMyBodyDevicePressed(sender: AnyObject) {
        EvaluationManager.shareInstance().scan { [unowned self] (error) -> Void in
            if error == nil {
                println("成功扫描到设备")
                self.showView(self.connectDeviceView)
            }
            else {
                
                UIAlertView(title: "扫描失败", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "确定").show()
            }
        }
    }
    
    // MARK: - connectDeviceView Response Method
    @IBAction func startEvaluationPressed(sender: AnyObject) {
        EvaluationManager.shareInstance().startScale {[unowned self] (result, error) -> Void in
            
            if error == nil {
                self.pushToDetailEvaluationViewController(result!)
                self.showView(self.connectDeviceView)
            } else {
                Alert.showErrorAlert("评测错误", message: error?.localizedDescription)
            }
        }
    }
    
    // MARK: - manualInputDataView Response Method
    
    @IBAction func manualInputDataCommitPressed(sender: AnyObject) {
        
        self.pushToDetailEvaluationViewController(EvaluationManager.shareInstance().startScaleInputData(self.weightInputDataTextField.text.floatValue, waterContent: self.waterContentInputDataTextField.text.floatValue, visceralFatContent: self.visceralFatContentInputDataTextField.text.floatValue))
        showMainView()
    }
    
    @IBAction func manualInputDataCancelPressed(sender: AnyObject) {
        showMainView()
    }
    
    @IBAction func tryEvaluationAgainButtonPressed(sender: AnyObject) {
        showMainView()
    }
    
    private func showMainView() {
        if EvaluationManager.shareInstance().isConnectedMyBodyDevice {
            showView(connectDeviceView)
        } else {
            showView(notConnectDeviceView)
        }
    }
    
    private func showView(view: UIView) {
        notConnectDeviceView.hidden = true
        connectDeviceView.hidden = true
        manualInputDataView.hidden = true
        evaluationResultView.hidden = true
        
        view.hidden = false
    }
    
    func pushToDetailEvaluationViewController(data: ScaleResult) {
        var detailController = EvaluationDetailViewController()
        detailController.data = data
        AppDelegate.rootNavgationViewController().pushViewController(detailController, animated: true)
    }
    
    func refreshEvaluationResultView(info: [String : AnyObject]) {
        
    }
}
