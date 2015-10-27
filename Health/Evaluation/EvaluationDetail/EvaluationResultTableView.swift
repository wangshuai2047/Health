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
    func viewHeightChanged()
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
    
    var list: [EvaluationDetailExtendViewModel] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dataSource = self
        self.delegate = self
        
        self.registerNib(UINib(nibName: scoreCellId, bundle: nil), forCellReuseIdentifier: scoreCellId)
        self.registerNib(UINib(nibName: detailCellId, bundle: nil), forCellReuseIdentifier: detailCellId)
        
        // 脂肪肝
//        EvaluationDetailExtendViewModel(type
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.fattyLiver))
        
        // 体重
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.weight))

        // 体脂率
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.fatPercentage))
        
        // 脂肪量
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.fat))
        
        // 肌肉
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.muscle))
        
        // 骨骼肌
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.boneMuscle))
        
        // 水分
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.water))
        
        // 蛋白质
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.protein))
        
        // 骨量
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.bone))
        
        // 内脏脂肪
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.visceralFat))
        
        // BMI
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.bmi))
        
        // 基础代谢
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.BMR))
        
        
        // 身体年龄
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.bodyAge))
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
            
            var info = list[indexPath.row]
            info.data = self.data
            cell.setViewModel(info)
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
            let canExtend = info.type.canExtend
            if canExtend {
                if selectedIndexRow == indexPath.row {
                    selectedIndexRow = -1
                }
                else {
                    selectedIndexRow = indexPath.row
                }
                tableView.reloadData()
                
                self.physiqueDelegate?.viewHeightChanged()
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}