//
//  UIView_ConvertToImage.swift
//  Health
//
//  Created by Yalin on 15/10/9.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation
import QuartzCore

extension UIView {
    func convertToImage() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}