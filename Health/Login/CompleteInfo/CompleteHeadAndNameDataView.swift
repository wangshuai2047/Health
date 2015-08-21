//
//  CompleteHeadAndNameView.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class CompleteHeadAndNameDataView: UIView {

    @IBOutlet weak var headIconButton: UIButton!
    @IBOutlet weak var nickNameTextField: UITextField!
    
    var name: String? {
        return nickNameTextField.text == nil ? "" : nickNameTextField.text
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
