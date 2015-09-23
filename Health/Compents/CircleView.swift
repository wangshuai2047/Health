//
//  CircleView.swift
//  Health
//
//  Created by Yalin on 15/8/25.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    var datas: [(Double, UIColor)] = []
    var progressWidth: CGFloat = 10
    
    func update(datas: [(Double, UIColor)], animated: Bool) {
        self.datas = datas
        draw()
    }
    
    func draw() {
        
        var total: Double = 0
        for (progress, _) in self.datas {
            total += progress
        }
        
        var startAngle: CGFloat = 0
        for var i = 0; i < self.datas.count; i++ {
            
            let (progress,color) = self.datas[i]
            
            let layer = CAShapeLayer()
            layer.bounds = self.bounds
            layer.fillColor = nil
            layer.lineWidth = self.progressWidth
            layer.lineCap = kCALineJoinRound
            layer.strokeColor = color.CGColor
            self.layer.addSublayer(layer)
            
            let path = UIBezierPath(arcCenter: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height), radius: CGFloat((self.bounds.size.width-progressWidth)/2), startAngle: startAngle, endAngle: startAngle + CGFloat(M_PI * 2 * progress / total), clockwise: true)
            layer.path = path.CGPath
            
            startAngle += CGFloat(M_PI * 2 * progress / total)
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
    }
    
}
