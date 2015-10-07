//
//  ActivityViewController.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var userSelectView: UserSelectView!
    @IBOutlet weak var adsScrollView: UIScrollView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var adsPageControl: UIPageControl!
    
    @IBOutlet weak var superWalkerButton: UIButton!
    @IBOutlet weak var superSleeperButton: UIButton!
    @IBOutlet weak var superEvaluationerButton: UIButton!
    @IBOutlet weak var superSharerButton: UIButton!
    
    var activityAds: [RequestLoginAdModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
        
        // 获取广告
        ActivityManager.queryActiveAds {[unowned self] (ads: [RequestLoginAdModel]?, error) -> Void in
            
            self.activityAds = ads
            if error == nil {
                for i in 0...ads!.count-1 {
                    let ad = ads![i]
                    let button = UIButton(type: UIButtonType.Custom)
                    if let imageURL = NSURL(string: ad.imageURL) {
                        if let imageData = NSData(contentsOfURL: imageURL) {
                            button.setBackgroundImage(UIImage(data: imageData), forState: UIControlState.Normal)
                        }
                    }
                    button.addTarget(self, action: Selector("adPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
                    button.tag = i
                    
                    button.frame = CGRectMake(CGFloat(i) * self.adsScrollView.frame.size.width, 0, self.adsScrollView.frame.size.width, self.adsScrollView.frame.size.height)
                    self.adsScrollView.addSubview(button)
                }
                
                self.adsPageControl.numberOfPages = ads!.count
                self.adsPageControl.currentPage = 0
                self.adsScrollView.contentOffset = CGPoint(x: 0, y: 0)
                
                if ads!.count > 1 {
                    NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("adsScrollTimer"), userInfo: nil, repeats: true)
                }
            }
            else {
                // 获取失败
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ActivityManager.queryScoreAds {[unowned self] (score: Float?, error: NSError?) -> Void in
            if error == nil {
                self.scoreLabel.text = "\(score!)"
            }
            else {
                self.scoreLabel.text = "0"
            }
        }
        
        let (walker, sleeper, evaluationer, sharer) = ActivityManager.queryActivityDatas()
        
        superWalkerButton.selected = walker
        superSleeperButton.selected = sleeper
        superEvaluationerButton.selected = evaluationer
        superSharerButton.selected = sharer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Response
    func adPressed(button: UIButton) {
        let ad = activityAds![button.tag]
        if let linkurl = NSURL(string: ad.linkURL) {
            if UIApplication.sharedApplication().canOpenURL(linkurl) {
                UIApplication.sharedApplication().openURL(linkurl)
                return
            }
        }
        Alert.showErrorAlert("打开广告页失败", message: "不是一个有效的链接")
    }
    
    func adsScrollTimer() {
        var nextOffset = adsScrollView.contentOffset.x + adsScrollView.frame.size.width
        
        if nextOffset >= adsScrollView.frame.size.width * CGFloat(adsPageControl.numberOfPages) {
            nextOffset = 0
        }
        
        adsScrollView.contentOffset = CGPoint(x: nextOffset, y: 0)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func scoreRuleButtonPressed(sender: AnyObject) {
        
    }
    
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        adsPageControl.currentPage = NSInteger((scrollView.contentOffset.x + scrollView.frame.size.width) / scrollView.frame.size.width) - 1
    }
}
