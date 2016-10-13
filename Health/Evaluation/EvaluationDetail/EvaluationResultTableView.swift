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

    fileprivate let scoreCellId = "EvaluationDetailScroeDescriptionCell"
    fileprivate let detailCellId = "EvaluationDetailExtendCell"
    
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
        
        self.register(UINib(nibName: scoreCellId, bundle: nil), forCellReuseIdentifier: scoreCellId)
        self.register(UINib(nibName: detailCellId, bundle: nil), forCellReuseIdentifier: detailCellId)
        
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
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.bmr))
        
        
        // 身体年龄
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.bodyAge))
        
        // 肥胖等级
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.fatLevel))
        
        // 标准体重
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.standardWeight))
        
        // 体重控制量
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.weightControl))
        
        // 去脂体重
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.noFatWeight))
        
        // 脂肪控制量
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.fatControl))
        
        // 肌肉控制量
        list.append(EvaluationDetailExtendViewModel(type: EvaluationDetailExtendType.muscleControl))
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }

    func refreshData() {
        
    }
    
    func tapPhysiqueButton() {
        self.physiqueDelegate?.tapPhysiqueButton()
    }
}

extension EvaluationResultTableView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: scoreCellId, for: indexPath) as! EvaluationDetailScroeDescriptionCell
            cell.physiqueButton.addTarget(self, action: #selector(EvaluationResultTableView.tapPhysiqueButton), for: UIControlEvents.touchUpInside)
            
            // score
            cell.data = data
            cell.refreshData()
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: detailCellId, for: indexPath) as! EvaluationDetailExtendCell
            
            var info = list[(indexPath as NSIndexPath).row]
            info.data = self.data
            cell.setViewModel(info)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return EvaluationDetailScroeDescriptionCell.normalHeight
        }
        else {
            if (indexPath as NSIndexPath).row == selectedIndexRow {
                return EvaluationDetailExtendCell.extendHeight
            } else {
                return EvaluationDetailExtendCell.normalHeight
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            if let disCell = cell as? EvaluationDetailScroeDescriptionCell {
                disCell.physiqueButton.removeTarget(self, action: #selector(EvaluationResultTableView.tapPhysiqueButton), for: UIControlEvents.touchUpInside)
            }
        }
        else {
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 1 {
            let info = list[(indexPath as NSIndexPath).row]
            if data != nil {
                let canExtend = info.type.canExtend(data!)
                if canExtend {
                    if selectedIndexRow == (indexPath as NSIndexPath).row {
                        selectedIndexRow = -1
                    }
                    else {
                        selectedIndexRow = (indexPath as NSIndexPath).row
                    }
                    tableView.reloadData()
                    
                    self.physiqueDelegate?.viewHeightChanged()
                }
            }
           
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
