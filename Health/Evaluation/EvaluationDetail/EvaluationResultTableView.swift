//
//  EvaluationResultTableView.swift
//  Health
//
//  Created by Yalin on 15/10/21.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

protocol EvaluationResultTableViewDelegate {
    func tapPhysiqueButton()
}

class EvaluationResultTableView: UITableView {

    private let scoreCellId = "EvaluationDetailScroeDescriptionCell"
    private let detailCellId = "EvaluationDetailExtendCell"
    
    var selectedIndexRow: Int = -1
    var data: ScaleResultProtocol?
    var physiqueDelegate: EvaluationResultTableViewDelegate?
    
    var currentViewHeight: CGFloat {
        if selectedIndexRow < 0 {
            return EvaluationDetailScroeDescriptionCell.normalHeight + CGFloat(list.count) * EvaluationDetailExtendCell.normalHeight
        }
        else {
            return EvaluationDetailScroeDescriptionCell.normalHeight + CGFloat(list.count - 1) * EvaluationDetailExtendCell.normalHeight + EvaluationDetailExtendCell.extendHeight
        }
    }
    
    var list: [[String : Any]] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dataSource = self
        self.delegate = self
        
        self.registerNib(UINib(nibName: scoreCellId, bundle: nil), forCellReuseIdentifier: scoreCellId)
        self.registerNib(UINib(nibName: detailCellId, bundle: nil), forCellReuseIdentifier: detailCellId)
        
        // 脂肪肝
        list.append([
            "headIcon" : "fattyLiverIcon",
            "title" : "脂肪肝",
            "unit" : "",
            "range": {() -> (Float, Float) in
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    if let has = self.data!.hepaticAdiposeInfiltration {
                        if has {
                            return "有脂肪肝"
                        }
                        else {
                            return "无脂肪肝"
                        }
                    }
                }
                return "此秤不支持"
            },
            "canExtend": {() -> Bool in
                return false
            },
            "status" : ValueStatus.High
            ])
        
        // 体重
        list.append([
            "headIcon" : "weightIcon",
            "title" : "体重",
            "unit" : "kg",
            "range": {() -> (Float, Float) in
                if self.data != nil {
                    return self.data!.SWRange
                }
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.weight)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return true
            },
            "status" : self.data?.weightStatus
            ])

        // 体脂率
        list.append([
            "headIcon" : "fatIcon",
            "title" : "体脂率",
            "unit" : "%",
            "range": {() -> (Float, Float) in
                if self.data != nil {
                    return self.data!.fatPercentageRange
                }
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.fatPercentage)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return true
            },
            "status" : self.data?.fatPercentageStatus
            ])
        
        // 脂肪量
        list.append([
            "headIcon" : "proteinIcon",
            "title" : "脂肪量",
            "unit" : "kg",
            "range": {() -> (Float, Float) in
                if self.data != nil {
                    return self.data!.fatWeightRange
                }
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.fatWeight)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return true
            },
            "status" : self.data?.fatWeightStatus
            ])
        
        // 肌肉
        list.append([
            "headIcon" : "muscleIcon",
            "title" : "肌肉",
            "unit" : "kg",
            "range": {() -> (Float, Float) in
                if self.data != nil {
                    return self.data!.muscleWeightRange
                }
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.muscleWeight)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return true
            },
            "status" : self.data?.muscleWeightStatus
            ])
        
        // 骨骼肌
        list.append([
            "headIcon" : "muscleIcon",
            "title" : "骨骼肌",
            "unit" : "kg",
            "range": {() -> (Float, Float) in
                if self.data != nil {
                    return self.data!.boneMuscleRange
                }
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.boneMuscleWeight)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return true
            },
            "status" : self.data?.boneMuscleLevel
            ])
        
        // 水分
        list.append([
            "headIcon" : "waterIcon",
            "title" : "水分",
            "unit" : "kg",
            "range": {() -> (Float, Float) in
                if self.data != nil {
                    return self.data!.waterWeightRange
                }
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.waterWeight)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return true
            },
            "status" : self.data?.waterWeightStatus
            ])
        
        // 蛋白质
        list.append([
            "headIcon" : "proteinIcon",
            "title" : "蛋白质",
            "unit" : "kg",
            "range": {() -> (Float, Float) in
                if self.data != nil {
                    return self.data!.proteinWeightRange
                }
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.proteinWeight)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return true
            },
            "status" : self.data?.proteinWeightStatus
            ])
        
        // 骨量
        list.append([
            "headIcon" : "boneIcon",
            "title" : "骨量",
            "unit" : "kg",
            "range": {() -> (Float, Float) in
                if self.data != nil {
                    return self.data!.boneWeightRange
                }
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.boneWeight)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return true
            },
            "status" : self.data?.boneWeightStatus
            ])
        
        // 内脏脂肪
        list.append([
            "headIcon" : "visceralFatIcon",
            "title" : "内脏脂肪",
            "unit" : "",
            "range": {() -> (Float, Float) in
                if self.data != nil {
                    return self.data!.visceralFatContentRange
                }
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.visceralFatPercentage)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return true
            },
            "status" : self.data?.visceralFatContentStatus
            ])
        
        // BMI
        list.append([
            "headIcon" : "BMI",
            "title" : "BMI",
            "unit" : "",
            "range": {() -> (Float, Float) in
                if self.data != nil {
                    return self.data!.BMIRange
                }
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.BMI)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return true
            },
            "status" : self.data?.BMIStatus
            ])
        
        // 基础代谢
        list.append([
            "headIcon" : "BMRIcon",
            "title" : "基础代谢",
            "unit" : "",
            "range": {() -> (Float, Float) in
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.BMR)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return false
            },
            "status" : ValueStatus.Normal
            ])
        
        
        // 身体年龄
        list.append([
            "headIcon" : "BMI",
            "title" : "身体年龄",
            "unit" : "岁",
            "range": {() -> (Float, Float) in
                return (0,0)
            },
            "value": {() -> String in
                if self.data != nil {
                    return "\(self.data!.bodyAge)"
                }
                return "0"
            },
            "canExtend": {() -> Bool in
                return false
            },
            "status" : ValueStatus.Normal
            ])
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }

    func refreshData() {
        
    }
    
    func tapPhysiqueButton() {
        self.physiqueDelegate?.tapPhysiqueButton()
    }
}

extension EvaluationResultTableView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return list.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(scoreCellId, forIndexPath: indexPath) as! EvaluationDetailScroeDescriptionCell
            cell.physiqueButton.addTarget(self, action: Selector("tapPhysiqueButton"), forControlEvents: UIControlEvents.TouchUpInside)
            
            // score
            cell.data = data
            cell.refreshData()
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(detailCellId, forIndexPath: indexPath) as! EvaluationDetailExtendCell
            
            let info = list[indexPath.row]
            let iconName = info["headIcon"] as? String
            let title = info["title"] as? String
            let unit = info["unit"] as? String
            let range = info["range"] as? () -> (Float, Float)
            let value = info["value"] as? () -> String
            // "status" : ValueStatus.Normal
            let status = info["status"] as? ValueStatus
            
            cell.iconImageView.image = UIImage(named: iconName!)
            cell.titleLabel.text = title!
            cell.setResultValue(value!(), range: range!(), unit: unit!, status: status)
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return EvaluationDetailScroeDescriptionCell.normalHeight
        }
        else {
            if indexPath.row == selectedIndexRow {
                return EvaluationDetailExtendCell.extendHeight
            } else {
                return EvaluationDetailExtendCell.normalHeight
            }
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if let disCell = cell as? EvaluationDetailScroeDescriptionCell {
                disCell.physiqueButton.removeTarget(self, action: Selector("tapPhysiqueButton"), forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        else {
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 {
            let info = list[indexPath.row]
            let canExtend = info["canExtend"] as? () -> Bool
            if canExtend!() {
                selectedIndexRow = indexPath.row
                tableView.reloadData()
            }
            
        }
    }
}