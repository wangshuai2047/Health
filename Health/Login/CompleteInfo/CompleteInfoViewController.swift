//
//  CompleteInfoViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class CompleteInfoViewController: UIViewController {

    var canBack: Bool = false
    
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
        
        frontPageButton.hidden = true
        
        // 头像方法
        headAndNameDataView.headIconButton.addTarget(self, action: Selector("headIconButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        
        backButton.hidden = !canBack
    }
    
    override func viewDidAppear(animated: Bool) {
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    func initContentView() {
        scrollView.addSubview(scrollContentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        
        // top
        scrollView.addConstraint(NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
        
        // bottom
        scrollView.addConstraint(NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
        
        // left
        scrollView.addConstraint(NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0))
        
        // right
        scrollView.addConstraint(NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0))
        
        // height
        heightConstraint = NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: scrollView.frame.size.height)
        scrollContentView.addConstraint(heightConstraint!)
        
        // width
        widthConstraint = NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: scrollView.frame.size.width * 5)
        scrollContentView.addConstraint(widthConstraint!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Response Method
    func headIconButtonPressed() {
        // 选取照片 上传
        UIActionSheet(title: "选取照片", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "拍照", "照片库").showInView(self.view)
    }
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func backgroundPressed(sender: AnyObject) {
        headAndNameDataView.nickNameTextField.resignFirstResponder()
        organizationDataView.phoneTextField.resignFirstResponder()
        organizationDataView.codeTextField.resignFirstResponder()
    }

    @IBAction func frontPageButtonPressed(sender: AnyObject) {
        scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x - scrollView.bounds.size.width, 0), animated: true)
    }
    
    @IBAction func nextPageButtonPressed(sender: AnyObject) {
        
        if pageControl.currentPage == 4 {
            
            LoginManager.completeInfomation(headAndNameDataView.name!, gender: genderDataView.gender, age: ageDataView.age, height: UInt8(heightDataView.height), phone: organizationDataView.phone, organizationCode: organizationDataView.code, complete: {[unowned self] (error) -> Void in
                
                if error == nil {
                    // 跳转到主页
                    if self.canBack {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    else {
                        AppDelegate.applicationDelegate().changeToMainController()
                    }
                    
                }
                else {
                    UIAlertView(title: "完善信息失败", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "确定").show()
                }
            })
            
            
        }
        else {
            scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x + scrollView.bounds.size.width, 0), animated: true)
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.headAndNameDataView.headIconButton.setImage(image, forState: UIControlState.Normal)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CompleteInfoViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            // 拍照
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                var picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                picker.videoQuality = UIImagePickerControllerQualityType.TypeLow
                picker.sourceType = UIImagePickerControllerSourceType.Camera
                self.navigationController?.presentViewController(picker, animated: true, completion: nil)
            }
            else {
                UIAlertView(title: "错误", message: "设备不支持拍照", delegate: nil, cancelButtonTitle: "确定").show()
            }
        }
        else if buttonIndex == 2 {
            // 照片库
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                var picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                picker.videoQuality = UIImagePickerControllerQualityType.TypeLow
                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.navigationController?.presentViewController(picker, animated: true, completion: nil)
            }
            else {
                UIAlertView(title: "错误", message: "设备不支持选取照片", delegate: nil, cancelButtonTitle: "确定").show()
            }
        }
    }
}

extension CompleteInfoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x + scrollView.bounds.size.width / 2
        let page = Int(offsetX / scrollView.bounds.size.width)
        self.pageControl.currentPage = page
        
        frontPageButton.hidden = false
        nextPageButton.hidden = false
        nextPageButton.setTitle("下一页", forState: UIControlState.Normal)
        if page == pageControl.numberOfPages - 1 {
            nextPageButton.setTitle("提交", forState: UIControlState.Normal)
        }
        else if page == 0 {
            frontPageButton.hidden = true
        }
    }
}
