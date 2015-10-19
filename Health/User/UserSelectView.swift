//
//  UserSelectView.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

protocol UserSelectViewDelegate {
    // 点击人物头像
    func headButtonPressed(userId: Int)
    
    // 点击访客
    func visitorClicked()
    
    // 添加家庭成员
    func addFamily()
    
    // 用户改变
    func userChangeToUserId(userId: Int)
}

class UserSelectView: UIView {
    
    private let headImageViewTag = 1001
    private let nameLabelTag = 1002
    private let changePeopleButtonTag = 1003
    private var userViews: [UIView] = []
    private var scrollView: UIScrollView = UIScrollView()
    private var showHeadView: UIView
    
    var delegate: UserSelectViewDelegate?
    
    var users:[(Int, String, String)] = [] // 数据格式 (userId, headURLStr, name)
    var currentShowIndex: Int = 0
    
    
    // MARK: - 初始化
    required init?(coder aDecoder: NSCoder) {
        
        showHeadView = NSBundle.mainBundle().loadNibNamed("UserView", owner: nil, options: nil)[0] as! UIView
        
        super.init(coder: aDecoder)
        
        self.clipsToBounds = true
        
        scrollView.frame = self.bounds
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.addSubview(scrollView)
        
        showHeadView.frame = self.bounds
        self.addSubview(showHeadView)
        
        let (headButton, _, changeButton) = getShowViewControl()
        headButton.addTarget(self, action: Selector("headButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        changeButton.addTarget(self, action: Selector("changePeoplePressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 讲头像设置为圆角
        headButton.layer.cornerRadius = headButton.frame.size.width/2
        headButton.layer.masksToBounds = true
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        scrollView.frame = self.bounds
        // add user
//        setUsers([(UserManager.mainUser.userId, UserManager.mainUser.headURL == nil ? "" : UserManager.mainUser.headURL!, UserManager.mainUser.name)], isNeedExt: false)
        
        if needSetUsers != nil && needExt != nil {
            self.users = needSetUsers!
            if needExt! {
                self.users += [(-1, "", "访客"), (-2, "", "新增")]
            }
            
            for view in userViews {
                view.removeFromSuperview()
            }
            userViews.removeAll(keepCapacity: false)
            
            var startCenter = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            let padding: CGFloat = 112
            for var i = 0; i < self.users.count; i++ {
                let (_, headURLStr, name) = self.users[i]
                let view = createSelectedHeadView((headURLStr, name, i))
                view.center = startCenter
                scrollView.addSubview(view)
                startCenter = CGPoint(x: startCenter.x + padding, y: startCenter.y)
                
                if i == 0 {
                    setShowView((headURLStr, name))
                }
            }
            
            scrollView.contentSize = CGSize(width: startCenter.x + 48 - 112, height: 0)
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }

    private var needSetUsers: [(Int, String, String)]?
    private var needExt: Bool?
    // MARK: - 选择视图
    // 数据格式 (userId, headURLStr, name)
    func setUsers(users: [(Int, String, String)], isNeedExt: Bool) {
        needSetUsers = users
        needExt = isNeedExt
    }
    
    // 设置切换按钮的隐藏与显示
    func setChangeButton(hidden: Bool) {
        let (headButton, _, changeButton) = getShowViewControl()
        changeButton.hidden = hidden
        
        headButton.userInteractionEnabled = !hidden
    }
    
    func setShowViewUserId(userId: Int) {
        
        for var i = 0; i < self.users.count; i++ {
            let (currentUserId, headURLStr, name) = self.users[i]
            if userId == currentUserId {
                setShowView((headURLStr, name))
                currentShowIndex = i
                break
            }
        }
    }
    
    func setShowView(info: (String, String)) {
        // 设置showView
        let (headURLStr, name) = info
        let (headButton, nameLabel, _) = getShowViewControl()
        
        headButton.sd_setImageWithURL(NSURL(string: headURLStr), forState: UIControlState.Normal, placeholderImage: UIImage(named: "defaultHead"))
        nameLabel.text = name
    }
    
    func createSelectedHeadView(info: (String, String, Int)) -> UIView {
        let headView = UIView(frame: CGRectMake(0, 0, 80, self.frame.size.height))
        
        let (headURLStr, name, tag) = info
        
        // 头像
        let headImageView = UIImageView(frame: CGRectMake(15, 8, 50, 50))
        headImageView.sd_setImageWithURL(NSURL(string: headURLStr), placeholderImage: UIImage(named: "defaultHead"))
        headView.addSubview(headImageView)
        headImageView.tag = headImageViewTag
        // 讲头像设置为圆角
        headImageView.layer.cornerRadius = headImageView.frame.size.width/2
        headImageView.layer.masksToBounds = true
        
        // 名字
        let nameLabel = UILabel(frame: CGRectMake(0, 66, 81, 21))
        nameLabel.text = name
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.tag = nameLabelTag
        headView.addSubview(nameLabel)
        
        // 点击button
        let button = UIButton(type: UIButtonType.Custom)
        button.frame = headView.bounds
        button.addTarget(self, action: Selector("selectHeadViewClick:"), forControlEvents: UIControlEvents.TouchUpInside)
        button.tag = tag
        headView.addSubview(button)
        
        return headView
    }
    
    func selectHeadViewClick(button: UIButton) {
        let (userId, headURLStr, name) = self.users[button.tag]
        if userId == -2 {
            // 新增
            delegate?.addFamily()
        }
        else if userId == -1 {
            // 访客
            delegate?.visitorClicked()
        }
        else {
            
            let (headButton, nameLabel, _) = getShowViewControl()
            
            headButton.sd_setImageWithURL(NSURL(string: headURLStr), forState: UIControlState.Normal, placeholderImage: UIImage(named: "defaultHead"))
            nameLabel.text = name
            
            delegate?.userChangeToUserId(userId)
            
            currentShowIndex = button.tag
        }
        
        self.scrollView.frame = CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)
        self.showHeadView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)
    }
    
    // MARK: - ShowView Method
    func headButtonPressed(button: UIButton) {
        
        // 直接用主账户操作
//        delegate?.headButtonPressed(UserManager.mainUser.userId)
        
        let (userId, _, _) = self.users[currentShowIndex]
        delegate?.headButtonPressed(userId)
    }
    
    func changePeoplePressed(button: UIButton) {
        
        // 功能暂不开放
        self.showHeadView.frame = CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)
        self.scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func getShowViewControl() -> (UIButton, UILabel, UIButton) {
        let headButton = showHeadView.viewWithTag(headImageViewTag) as! UIButton
        let nameLabel = showHeadView.viewWithTag(nameLabelTag) as! UILabel
        let changeButton = showHeadView.viewWithTag(changePeopleButtonTag) as! UIButton
        
        return (headButton, nameLabel, changeButton)
    }
}

class UserView: UIView {
    
}