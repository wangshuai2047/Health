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
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let layer = headIconButton.layer
        layer.masksToBounds = true
        layer.cornerRadius = headIconButton.frame.size.height / 2.0
        layer.borderWidth = 0.1
        layer.borderColor = UIColor.blackColor().CGColor
//        CALayer * layer = [self.headImageView layer];
//        [layer setMasksToBounds:YES];
//        [layer setCornerRadius:self.headImageView.frame.size.height/2.0];
//        
//        [layer setBorderWidth:0.1];
//        [layer setBorderColor:[[UIColor clearColor] CGColor]];
    }
    

}
