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
    
    fileprivate let minHeight: Double = 80.0
    fileprivate let maxHeight: Double = 240.0
    fileprivate let maxScroll = 1141.0
    
    fileprivate var unit: Double {
        return (maxHeight - minHeight) / maxScroll
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        scrollView.contentSize = CGSize(width: 0, height: CGFloat(maxScroll) + scrollView.frame.size.height);
        
        scrollView.contentOffset = CGPoint(x: 0, y: (maxHeight - height) / unit)
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        height = maxHeight - (unit * Double(scrollView.contentOffset.y))
        
        heightLabel.text = "\(Int(height))"
    }
}
