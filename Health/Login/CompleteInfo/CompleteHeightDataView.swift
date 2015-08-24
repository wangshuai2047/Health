//
//  CompleteHeightDataView.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class CompleteHeightDataView: UIView, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightLabel: UILabel!
    
    var height: Double = 200
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        scrollView.contentSize = CGSizeMake(101, 608 + 214);
    }
    

    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let maxHeight = 200.0
        let minHeight = 20.0
        
        let maxScroll = 596.0
        
        let unit = (maxHeight - minHeight) / maxScroll
        
        height = maxHeight - (unit * Double(scrollView.contentOffset.y))
        
        heightLabel.text = "\(Int(height))"
    }
}
