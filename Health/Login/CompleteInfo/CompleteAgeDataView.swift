//
//  CompleteAgeDataView.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class CompleteAgeDataView: UIView {

    @IBOutlet weak var agePicker: UIPickerView!
    var selectedRow: Int = 25
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        agePicker.selectRow(selectedRow, inComponent: 0, animated: true)
    }


    var age: UInt8 {
        get {
            return UInt8(agePicker.selectedRow(inComponent: 0))
        }
    }
}

extension CompleteAgeDataView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
}
