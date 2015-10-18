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
    
    private let maxHeight: Double = 200.0
    
    private var unit: Double {
        let minHeight = 20.0
        let maxScroll = 596.0
        
        let unitN = (maxHeight - minHeight) / maxScroll
        return unitN
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        scrollView.contentSize = CGSizeMake(101, 608 + 214);
        
        scrollView.contentOffset = CGPoint(x: 0, y: (maxHeight - height) / unit)
    }
    

    func scrollViewDidScroll(scrollView: UIScrollView) {
        height = maxHeight - (unit * Double(scrollView.contentOffset.y))
        
        heightLabel.text = "\(Int(height))"
    }
}
