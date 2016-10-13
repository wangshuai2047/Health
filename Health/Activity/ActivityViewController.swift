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
    @IBOutlet weak var rankLabel: UILabel!
    
    @IBOutlet weak var adsPageControl: UIPageControl!
    
    @IBOutlet weak var superWalkerButton: UIButton!
    @IBOutlet weak var superSleeperButton: UIButton!
    @IBOutlet weak var superEvaluationerButton: UIButton!
    @IBOutlet weak var superSharerButton: UIButton!
    
    var activityAds: [RequestLoginAdModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        // 获取广告
        ActivityManager.queryActiveAds {[unowned self] (ads: [RequestLoginAdModel]?, error) -> Void in
            
            self.activityAds = ads
            if error == nil {
                
                if ads!.count > 0 {
                    for i in 0...ads!.count-1 {
                        let ad = ads![i]
                        let button = UIButton(type: UIButtonType.custom)
                        if let imageURL = URL(string: ad.imageURL) {
                            
                            DispatchQueue.global().async {
                                // qos' default value is ´DispatchQoS.QoSClass.default`
                                if let imageData = try? Data(contentsOf: imageURL) {
                                    let image = UIImage(data: imageData)
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        button.setBackgroundImage(image, for: UIControlState())
                                    })
                                }
                            }
                        }
                        button.addTarget(self, action: #selector(ActivityViewController.adPressed(_:)), for: UIControlEvents.touchUpInside)
                        button.tag = i
                        
                        button.frame = CGRect(x: CGFloat(i) * self.adsScrollView.frame.size.width, y: 0, width: self.adsScrollView.frame.size.width, height: self.adsScrollView.frame.size.height)
                        self.adsScrollView.addSubview(button)
                    }
                }
                
                
                self.adsPageControl.numberOfPages = ads!.count
                self.adsPageControl.currentPage = 0
                self.adsScrollView.contentOffset = CGPoint(x: 0, y: 0)
                self.adsScrollView.contentSize = CGSize(width: self.adsScrollView.frame.size.width * CGFloat(ads!.count), height: self.adsScrollView.frame.size.height)
                
                if ads!.count > 1 {
                    Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ActivityViewController.adsScrollTimer), userInfo: nil, repeats: true)
                }
            }
            else {
                // 获取失败
            }
        }
        
        userSelectView.setChangeButton(true)
        userSelectView.setUsers(UserManager.sharedInstance.queryAllUsers(), isNeedExt: false)
//        userSelectView.setShowViewUserId(UserManager.mainUser.userId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ActivityManager.queryScoreAds {[unowned self] (score: Int?, rank: Int?, error: NSError?) -> Void in
            if error == nil {
                self.scoreLabel.text = "\(score!)"
                self.rankLabel.text = "\(rank!)"
            }
            else {
                self.scoreLabel.text = "0"
                self.rankLabel.text = "0"
            }
        }
        
        let (walker, sleeper, evaluationer, sharer) = ActivityManager.queryActivityDatas()
        
        superWalkerButton.isSelected = walker
        superSleeperButton.isSelected = sleeper
        superEvaluationerButton.isSelected = evaluationer
        superSharerButton.isSelected = sharer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Response
    func adPressed(_ button: UIButton) {
        let ad = activityAds![button.tag]
        if let linkurl = URL(string: ad.linkURL) {
            if UIApplication.shared.canOpenURL(linkurl) {
                UIApplication.shared.openURL(linkurl)
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

    @IBAction func scoreRuleButtonPressed(_ sender: AnyObject) {
        
    }
    
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adsPageControl.currentPage = NSInteger((scrollView.contentOffset.x + scrollView.frame.size.width) / scrollView.frame.size.width) - 1
    }
}
