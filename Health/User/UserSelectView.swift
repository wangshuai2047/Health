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
    func headButtonPressed(_ userId: Int)
    
    // 点击访客
    func visitorClicked()
    
    // 添加家庭成员
    func addFamily()
    
    // 用户改变
    func userChangeToUserId(_ userId: Int)
}

class UserSelectView: UIView {
    
    fileprivate let headImageViewTag = 1001
    fileprivate let nameLabelTag = 1002
    fileprivate let changePeopleButtonTag = 1003
    fileprivate var userViews: [UIView] = []
    fileprivate var scrollView: UIScrollView = UIScrollView()
    fileprivate var showHeadView: UIView
    
    var delegate: UserSelectViewDelegate?
    
    var users:[(Int, String, String)] = [] // 数据格式 (userId, headURLStr, name)
    var currentShowIndex: Int = 0
    
    
    // MARK: - 初始化
    required init?(coder aDecoder: NSCoder) {
        
        showHeadView = Bundle.main.loadNibNamed("UserView", owner: nil, options: nil)?[0] as! UIView
        super.init(coder: aDecoder)
        
        self.clipsToBounds = true
        
        scrollView.frame = self.bounds
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.addSubview(scrollView)
        
        showHeadView.frame = self.bounds
        self.addSubview(showHeadView)
        
        let (headButton, _, changeButton, _) = getShowViewControl()
        headButton.addTarget(self, action: #selector(UserSelectView.headButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        changeButton.addTarget(self, action: #selector(UserSelectView.changePeoplePressed(_:)), for: UIControlEvents.touchUpInside)
        
        // 讲头像设置为圆角
        headButton.layer.cornerRadius = headButton.frame.size.width/2
        headButton.layer.masksToBounds = true
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        scrollView.frame = self.bounds
        // add user
        
        if needSetUsers != nil && needExt != nil {
            self.users = needSetUsers!
            if needExt! {
                self.users += [(-2, "", "增加用户"),(-1, "", "访客")]
            }
            
            for view in userViews {
                view.removeFromSuperview()
            }
            userViews.removeAll(keepingCapacity: false)
            
            for view in scrollView.subviews {
                view.removeFromSuperview()
            }
            
            var startCenter = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            let padding: CGFloat = 112
            
            let (_, _, changeButton, _) = getShowViewControl()
            
            if self.users.count > 0 {
                for i in 0 ..< self.users.count {
                    let (userId, headURLStr, name) = self.users[i]
                    let view = createSelectedHeadView((headURLStr, name, i))
                    view.center = startCenter
                    scrollView.addSubview(view)
                    startCenter = CGPoint(x: startCenter.x + padding, y: startCenter.y)
                    
                    if changeButton.isHidden {
                        if i == 0 {
                            setShowView((headURLStr, name))
                        }
                    }
                    else {
                        if UserManager.sharedInstance.currentUser.userId == userId {
                            setShowView((headURLStr, name))
                        }
                    }
                }
            }
            
            scrollView.contentSize = CGSize(width: startCenter.x + 48 - 112, height: 0)
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }

    fileprivate var needSetUsers: [(Int, String, String)]?
    fileprivate var needExt: Bool?
    // MARK: - 选择视图
    // 数据格式 (userId, headURLStr, name)
    func setUsers(_ users: [(Int, String, String)], isNeedExt: Bool) {
        needSetUsers = users
        needExt = isNeedExt
        self.setNeedsDisplay()
    }
    
    // 设置切换按钮的隐藏与显示
    func setChangeButton(_ hidden: Bool) {
        let (headButton, _, changeButton, nameYConstraint) = getShowViewControl()
        changeButton.isHidden = hidden
        
        headButton.isUserInteractionEnabled = !hidden
        
        if hidden {
            nameYConstraint.constant = 0
        }
        else {
            nameYConstraint.constant = 20
        }
    }
    
    func setShowViewUserId(_ userId: Int) {
        
        if needSetUsers != nil && needExt != nil {
            self.users = needSetUsers!
            if needExt! {
                self.users += [(-2, "", "增加用户"),(-1, "", "访客")]
            }
        }
        
        if self.users.count > 0 {
            for i in 0 ..< self.users.count {
                let (currentUserId, headURLStr, name) = self.users[i]
                if userId == currentUserId {
                    setShowView((headURLStr, name))
                    currentShowIndex = i
                    return
                }
            }
        }
    }
    
    func setShowView(_ info: (String, String)) {
        // 设置showView
        let (headURLStr, name) = info
        let (headButton, nameLabel, _, _) = getShowViewControl()
        
        headButton.sd_setImage(with: URL(string: headURLStr), for: UIControlState(), placeholderImage: UIImage(named: "defaultHead"))
        nameLabel.text = name
    }
    
    func createSelectedHeadView(_ info: (String, String, Int)) -> UIView {
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: self.frame.size.height))
        
        let (headURLStr, name, tag) = info
        
        // 头像
        let headImageView = UIImageView(frame: CGRect(x: 15, y: 8, width: 50, height: 50))
        headImageView.sd_setImage(with: URL(string: headURLStr), placeholderImage: UIImage(named: "defaultHead"))
        headView.addSubview(headImageView)
        headImageView.tag = headImageViewTag
        // 讲头像设置为圆角
        headImageView.layer.cornerRadius = headImageView.frame.size.width/2
        headImageView.layer.masksToBounds = true
        headImageView.layer.borderWidth = 0.1
        headImageView.layer.borderColor = UIColor.black.cgColor
        
        // 名字
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 66, width: 81, height: 21))
        nameLabel.text = name
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.tag = nameLabelTag
        headView.addSubview(nameLabel)
        
        // 点击button
        let button = UIButton(type: UIButtonType.custom)
        button.frame = headView.bounds
        button.addTarget(self, action: #selector(UserSelectView.selectHeadViewClick(_:)), for: UIControlEvents.touchUpInside)
        button.tag = tag
        headView.addSubview(button)
        
        return headView
    }
    
    func selectHeadViewClick(_ button: UIButton) {
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
            
            let (headButton, nameLabel, _, _) = getShowViewControl()
            
            headButton.sd_setImage(with: URL(string: headURLStr), for: UIControlState(), placeholderImage: UIImage(named: "defaultHead"))
            nameLabel.text = name
            
            delegate?.userChangeToUserId(userId)
            
            currentShowIndex = button.tag
        }
        
        self.scrollView.frame = CGRect(x: 0, y: -self.bounds.size.height, width: self.bounds.size.width, height: self.bounds.size.height)
        self.showHeadView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
    }
    
    // MARK: - ShowView Method
    func headButtonPressed(_ button: UIButton) {
        let (userId, _, _) = self.users[currentShowIndex]
        delegate?.headButtonPressed(userId)
    }
    
    func changePeoplePressed(_ button: UIButton) {
        
        self.showHeadView.frame = CGRect(x: 0, y: -self.bounds.size.height, width: self.bounds.size.width, height: self.bounds.size.height)
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func getShowViewControl() -> (UIButton, UILabel, UIButton, NSLayoutConstraint) {
        let headButton = showHeadView.viewWithTag(headImageViewTag) as! UIButton
        let nameLabel = showHeadView.viewWithTag(nameLabelTag) as! UILabel
        let changeButton = showHeadView.viewWithTag(changePeopleButtonTag) as! UIButton
        
        var nameYConstraint: NSLayoutConstraint?
        for constraint in showHeadView.constraints {
            if constraint.identifier == "nameYConstaint" {
                nameYConstraint = constraint
                break
            }
        }
        
        return (headButton, nameLabel, changeButton,nameYConstraint!)
    }
}

class UserView: UIView {
    
}
