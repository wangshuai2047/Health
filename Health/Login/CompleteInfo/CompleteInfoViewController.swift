//
//  CompleteInfoViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

protocol CompleteInfoDelegate {
    func completeInfo(_ controller: CompleteInfoViewController, user: UserModel, phone: String?, organizationCode: String?)
}

class CompleteInfoViewController: UIViewController {

    var delegate: CompleteInfoDelegate?
    
    var canBack: Bool = false
    var userModel: UserModel?
    var phone: String?
    var organizationCode: String?
    
    var name: String?
    var headURLString: String?
    
    fileprivate let tempHeadPath = NSHomeDirectory() + "/Documents/headImage.jpg"
    
    @IBOutlet weak var backButton: UIButton!
    
    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var scrollContentView: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var frontPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    
    @IBOutlet var headAndNameDataView: CompleteHeadAndNameDataView!
    @IBOutlet var genderDataView: CompleteGenderDataView!
    @IBOutlet var ageDataView: CompleteAgeDataView!
    @IBOutlet var heightDataView: CompleteHeightDataView!
    @IBOutlet var organizationDataView: CompleteOrganizationDataView!
    
    convenience init() {
        self.init(nibName: "CompleteInfoViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initContentView()
        
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        
        frontPageButton.isHidden = true
        
        // 头像方法
        headAndNameDataView.headIconButton.addTarget(self, action: #selector(CompleteInfoViewController.headIconButtonPressed), for: UIControlEvents.touchUpInside)
        
        backButton.isHidden = !canBack
        
        initIfExistUserModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        heightConstraint?.constant = scrollView.frame.size.height
        widthConstraint?.constant = scrollView.frame.size.width * 5
        
        //为了兼容iOS7，http://stackoverflow.com/questions/15490140/auto-layout-error
        //iOS8下无需这句话
        self.view.layoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    func initContentView() {
        scrollView.addSubview(scrollContentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        
        // top
        scrollView.addConstraint(NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0))
        
        // bottom
        scrollView.addConstraint(NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0))
        
        // left
        scrollView.addConstraint(NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0))
        
        // right
        scrollView.addConstraint(NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0))
        
        // height
        heightConstraint = NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: scrollView.frame.size.height)
        scrollContentView.addConstraint(heightConstraint!)
        
        // width
        widthConstraint = NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: scrollView.frame.size.width * 5)
        scrollContentView.addConstraint(widthConstraint!)
    }
    
    func initIfExistUserModel() {
        
        if name != nil {
            headAndNameDataView.nickNameTextField.text = name
        }
        
        if headURLString != nil {
            if let headURL = URL(string: headURLString!) {
                headAndNameDataView.headIconButton.sd_setImage(with: headURL, for: UIControlState())
            }
        }
        
        if let user = userModel {
            self.headAndNameDataView.nickNameTextField.text = user.name
            
            self.headAndNameDataView.headIconButton.setImage(UIImage(named: "defaultHead"), for: UIControlState())
            if let headUrlStr =  user.headURL {
                if let headURL = URL(string: headUrlStr) {
                    self.headAndNameDataView.headIconButton.sd_setImage(with: headURL, for: UIControlState())
                }
            }
            
            genderDataView.womanButton.isSelected = !user.gender
            genderDataView.menButton.isSelected = user.gender
            
            ageDataView.selectedRow = Int(user.age)
            
            heightDataView.height = Double(user.height)
            
            if let phone = self.phone {
                organizationDataView.phoneTextField.text = phone
            }
            
            if let code = self.organizationCode {
                organizationDataView.codeTextField.text = code
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Response Method
    func headIconButtonPressed() {
        // 选取照片 上传
        UIActionSheet(title: "选取照片", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "拍照", "照片库").show(in: self.view)
    }
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backgroundPressed(_ sender: AnyObject) {
        headAndNameDataView.nickNameTextField.resignFirstResponder()
        organizationDataView.phoneTextField.resignFirstResponder()
        organizationDataView.codeTextField.resignFirstResponder()
    }

    @IBAction func frontPageButtonPressed(_ sender: AnyObject) {
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x - scrollView.bounds.size.width, y: 0), animated: true)
    }
    
    @IBAction func nextPageButtonPressed(_ sender: AnyObject) {
        
        
        if headAndNameDataView.name == nil || headAndNameDataView.name == "" {
            Alert.showErrorAlert("", message: "请输入名字")
            return
        }
        
        if pageControl.currentPage == 4 {
            
            let userId = userModel == nil ? 0 : userModel!.userId
            let user = UserModel(userId: userId, age: ageDataView.age, gender: genderDataView.gender, height: UInt8(heightDataView.height), name: headAndNameDataView.name!, headURL:tempHeadPath)
            delegate?.completeInfo(self, user: user, phone: organizationDataView.phone, organizationCode: organizationDataView.code)
        }
        else {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x + scrollView.bounds.size.width, y: 0), animated: true)
        }
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

extension CompleteInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        try? UIImageJPEGRepresentation(image, 0.2)?.write(to: URL(fileURLWithPath: tempHeadPath), options: [])
        
        self.headAndNameDataView.headIconButton.setImage(image, for: UIControlState())
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CompleteInfoViewController: UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            // 拍照
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                picker.videoQuality = UIImagePickerControllerQualityType.typeLow
                picker.sourceType = UIImagePickerControllerSourceType.camera
                self.navigationController?.present(picker, animated: true, completion: nil)
            }
            else {
                UIAlertView(title: "错误", message: "设备不支持拍照", delegate: nil, cancelButtonTitle: "确定").show()
            }
        }
        else if buttonIndex == 2 {
            // 照片库
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                picker.videoQuality = UIImagePickerControllerQualityType.typeLow
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.navigationController?.present(picker, animated: true, completion: nil)
            }
            else {
                UIAlertView(title: "错误", message: "设备不支持选取照片", delegate: nil, cancelButtonTitle: "确定").show()
            }
        }
    }
}

extension CompleteInfoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x + scrollView.bounds.size.width / 2
        let page = Int(offsetX / scrollView.bounds.size.width)
        self.pageControl.currentPage = page
        
        frontPageButton.isHidden = false
        nextPageButton.isHidden = false
        nextPageButton.setTitle("下一页", for: UIControlState())
        if page == pageControl.numberOfPages - 1 {
            nextPageButton.setTitle("提交", for: UIControlState())
        }
        else if page == 0 {
            frontPageButton.isHidden = true
        }
    }
}

extension CompleteInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
