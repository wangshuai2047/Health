//
//  GoalSettingViewController.swift
//  Health
//
//  Created by Yalin on 15/9/5.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class GoalSettingViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    
    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var scrollContentView: UIView!
    @IBOutlet weak var frontButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet var setGoalView: UIView!
    @IBOutlet weak var weightGoalButton: UIButton!
    @IBOutlet weak var fatGoalButton: UIButton!
    @IBOutlet weak var muscleGoalButton: UIButton!
    
    @IBOutlet var setNumberGoalView: UIView!
    @IBOutlet weak var setNumberAttLabel: AttributedLabel!
    @IBOutlet weak var setNumberGoalPicker: UIPickerView!
    
    @IBOutlet var setDaysGoalView: UIView!
    @IBOutlet weak var setDaysAttLabel: AttributedLabel!
    @IBOutlet weak var setDaysGoalPicker: UIPickerView!
    
    convenience init() {
        self.init(nibName: "GoalSettingViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backButton.hidden = !GoalManager.isSetGoal
        
        initContentView()
        
        frontButton.hidden = true
        
        setGoalButtonPressed(weightGoalButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        heightConstraint?.constant = scrollView.frame.size.height
        widthConstraint?.constant = scrollView.frame.size.width * 3
        
        //为了兼容iOS7，http://stackoverflow.com/questions/15490140/auto-layout-error
        //iOS8下无需这句话
        self.view.layoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initContentView() {
        scrollView.addSubview(scrollContentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        
        // top
        scrollView.addConstraint(NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -20))
        
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
        widthConstraint = NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: scrollView.frame.size.width * 3)
        scrollContentView.addConstraint(widthConstraint!)
    }
    
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - scrollView Button
    @IBAction func frontButtonPressed(sender: AnyObject) {
        scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x - scrollView.bounds.size.width, 0), animated: true)
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        
        if scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.frame.size.width {
            
            GoalManager.setGoal(goalType, number: strategyNumberRange[setNumberGoalPicker.selectedRowInComponent(0)], days: strategyDayRange[setDaysGoalPicker.selectedRowInComponent(0)])
            backButtonPressed(NSObject())
        }
        else {
            scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x + scrollView.bounds.size.width, 0), animated: true)
        }
        
    }
    
    
    // MARK: - setGoal Button
    
    @IBAction func setGoalButtonPressed(button: UIButton) {
        
        weightGoalButton.selected = false
        fatGoalButton.selected = false
        muscleGoalButton.selected = false
        
        button.selected = true
        
        freshGoalStrategy()
    }
    
    
    // 策略单位
    var goalType: UserGoalData.GoalType = .None
    var unit: String?
    var strategyNumberRange: [Int] = []
    var strategyDayRange: [Int] = []
    
    func freshGoalStrategy() {
        
        // 数值数据 测试
        strategyNumberRange = []
        strategyDayRange = []
        for index in 0...100 {
            strategyNumberRange += [index]
            strategyDayRange += [index]
        }
        
        var goalString = ""
        // 数值数据单位
        if weightGoalButton.selected {
            unit = "kg"
            goalString = "减重"
            goalType = .Weight
        }
        else if fatGoalButton.selected {
            unit = "公斤"
            goalString = "减脂"
            goalType = .Fat
        }
        else if muscleGoalButton.selected {
            unit = "double斤"
            goalString = "增肌"
            goalType = .Muscle
        }
        
        // 设置数值
        setNumberAttLabel.attributedString.deleteCharactersInRange(NSRange(location: 0, length: setNumberAttLabel.attributedString.length))
        setNumberAttLabel.append("系统根据您的身体数据分析\n建议您将\(goalString)目标设置为: ", font: nil, color: deepBlue)
        setNumberAttLabel.append("\(goalNumber())", font: nil, color: lightBlue)
        setNumberAttLabel.append("\(unit)\n您也可以上下滑动修改目标数值", font: nil, color: deepBlue)
        
        // 设置天数
        setDaysAttLabel.attributedString.deleteCharactersInRange(NSRange(location: 0, length: setDaysAttLabel.attributedString.length))
        setDaysAttLabel.append("系统根据您的身体数据分析\n为了健康减重到", font: nil, color: deepBlue)
        setDaysAttLabel.append("\(self.setNumberGoalPicker.selectedRowInComponent(0))", font: nil, color: lightBlue)
        setDaysAttLabel.append("公斤\n建议您采取", font: nil, color: deepBlue)
        setDaysAttLabel.append("\(calculeDays())", font: nil, color: lightBlue)
        setDaysAttLabel.append("天的周期\n您也可以上下滑动修改目标数值", font: nil, color: deepBlue)
        
        // 刷新界面
        setNumberGoalPicker.reloadAllComponents()
        setDaysGoalPicker.reloadAllComponents()
    }
    
    func goalNumber() -> Int {
        return 49
    }
    
    func calculeDays() -> Int {
        return 56
    }
}


extension GoalSettingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x + scrollView.bounds.size.width / 2
        let page = Int(offsetX / scrollView.bounds.size.width)
        
        frontButton.hidden = false
        nextButton.hidden = false
        nextButton.setTitle("下一页", forState: UIControlState.Normal)
        if page == 2 {
            nextButton.setTitle("完成", forState: UIControlState.Normal)
        }
        else if page == 0 {
            frontButton.hidden = true
        }
    }
}

extension GoalSettingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            
            if pickerView == setNumberGoalPicker {
                return strategyNumberRange.count
            }
            else if pickerView == setDaysGoalPicker {
                return strategyDayRange.count
            }
            
            
        }
        else {
            return 1
        }
        
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == setNumberGoalPicker {
            if component == 0 {
                return "\(strategyNumberRange[row])"
            }
            else {
                return unit
            }
        }
        else if pickerView == setDaysGoalPicker {
            if component == 0 {
                return "\(strategyDayRange[row])"
            }
            else {
                return "天"
            }
        }
        
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }
}