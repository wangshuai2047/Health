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
    
    var height: Double = 170
    
    private let minHeight: Double = 80.0
    private let maxHeight: Double = 240.0
    private let maxScroll = 1141.0
    
    private var unit: Double {
        return (maxHeight - minHeight) / maxScroll
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        scrollView.contentSize = CGSizeMake(0, CGFloat(maxScroll) + scrollView.frame.size.height);
        
        scrollView.contentOffset = CGPoint(x: 0, y: (maxHeight - height) / unit)
    }
    

    func scrollViewDidScroll(scrollView: UIScrollView) {
        height = maxHeight - (unit * Double(scrollView.contentOffset.y))
        
        heightLabel.text = "\(Int(height))"
    }
}
