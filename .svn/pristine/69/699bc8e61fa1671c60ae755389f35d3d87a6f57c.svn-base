//
//  GUIViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class GUIViewController: UIViewController {
    
    var imageViews:[UIImageView] = []
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var frontButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    convenience init() {
        self.init(nibName: "GUIViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageViews.append(UIImageView(image: UIImage(named: "GUI001")))
        imageViews.append(UIImageView(image: UIImage(named: "GUI002")))
        imageViews.append(UIImageView(image: UIImage(named: "GUI003")))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for i in 0...imageViews.count-1 {
            let imageView = imageViews[i]
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.frame = CGRect(x: CGFloat(i) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(imageViews.count), height: 0)
        
        self.view.layoutSubviews()
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
    @IBAction func frontButtonPressed(_ sender: AnyObject) {
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x - scrollView.bounds.size.width, y: 0), animated: true)
    }
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        if pageControl.currentPage == imageViews.count - 1 {
            skipButtonPressed(sender)
            
        }
        else {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x + scrollView.bounds.size.width, y: 0), animated: true)
        }
    }

    @IBAction func skipButtonPressed(_ sender: AnyObject) {
        if !LoginManager.isLogin || LoginManager.isNeedCompleteInfo{
            _ = AppDelegate.applicationDelegate().changeToLoginController()
        }
        else {
            _ = AppDelegate.applicationDelegate().changeToMainController()
        }
        
        LoginManager.showedGUI = true
    }
    
}

extension GUIViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x + scrollView.bounds.size.width / 2
        let page = Int(offsetX / scrollView.bounds.size.width)
        self.pageControl.currentPage = page
        
        frontButton.isHidden = false
        nextButton.isHidden = false
        nextButton.setTitle("下一页", for: UIControlState())
        if page == pageControl.numberOfPages - 1 {
            nextButton.setTitle("开始使用", for: UIControlState())
        }
        else if page == 0 {
            frontButton.isHidden = true
        }
    }
}
