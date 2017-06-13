//
//  CompleteGenderInfoView.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class CompleteGenderDataView: UIView {

    
    @IBOutlet weak var womanButton: UIButton!
    @IBOutlet weak var menButton: UIButton!
    
    
    var gender: Bool {
        get {
            return womanButton.isSelected ? false : true
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func genderButtonPressed(_ sender: UIButton) {
        
        if sender == womanButton {
            womanButton.isSelected = true
            menButton.isSelected = false
        }
        else {
            menButton.isSelected = true
            womanButton.isSelected = false
        }
        
    }
    
}
