//
//  DoubleYLineChartCell.swift
//  Chart
//
//  Created by Yalin on 15/9/12.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import CoreGraphics

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class DoubleYLineChartCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var linePoint: UIImageView!
    @IBOutlet weak var lineDrawView: LineView!
    @IBOutlet weak var barViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var linePointTopConstraint: NSLayoutConstraint!
    
//    @IBOutlet var gridTopContraints: [NSLayoutConstraint]!
    
    var leftYValueRange: (Double, Double)?
    var rightYValueRange: (Double, Double)?
    
    // 直接写在iphone4s 7.1.2上面会蹦  不知道为什么
    fileprivate var temp: CGFloat?
    fileprivate var drawTotalHeight: CGFloat? {
        get {
            return temp
        }
        set {
            temp = newValue
        }
    }
    var leftValues: (minValue: Double?, value: Double?, maxValue: Double?, XAxisString: String, color: UIColor?)?
    var rightValues: (minValue: Double?, value: Double?, maxValue: Double?, XAxisString: String, color: UIColor?)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("cell Init")
        
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    func resetCell() {
        timeLabel.text = ""
        
        drawTotalHeight = barView.frame.origin.y + barView.frame.size.height
//        print("barView.frame: \(barView.frame)")
        barViewTopConstraint.constant = drawTotalHeight!
        linePointTopConstraint.constant = drawTotalHeight!
        linePoint.alpha = 0
        
        lineDrawView.firstPoint = nil
        lineDrawView.secondPoint = nil
        lineDrawView.height = nil
        lineDrawView.color = nil
        
//        let margin = (drawTotalHeight! - 6) / 5;
//        for contraint in gridTopContraints {
//            contraint.constant = margin;
//        }
    }
    
    func setLeftValues(_ minValue: Double?, value: Double?, maxValue: Double?, XAxisString: String, color: UIColor?) {
        leftValues = (minValue, value, maxValue, XAxisString, color)
    }
    
    func setRightValues(_ minValue: Double?, value: Double?, maxValue: Double?, XAxisString: String, color: UIColor?) {
        rightValues = (minValue, value, maxValue, XAxisString, color)
    }
    
    func drawLeftValues() {
        
        if let (_, value, _, XAxisString, color): (Double?, Double?, Double?, String, UIColor?) = leftValues {
            if value != nil && leftYValueRange != nil && !(leftYValueRange!.0 == 0 && leftYValueRange!.1 == 0) {
                
                barViewTopConstraint.constant =  topHeight(value!, minAndMax: leftYValueRange!)
                barView.backgroundColor = color
                timeLabel.text = XAxisString
            }
            else {
                barViewTopConstraint.constant =  drawTotalHeight!
                barView.backgroundColor = color
                timeLabel.text = XAxisString
            }
        }
    }
    
    func drawRightValues() {
        
        // 先清空 在绘制
        lineDrawView.firstPoint = CGPoint(x: 0, y: 0)
        lineDrawView.middlePoint = CGPoint(x: 0, y: 0)
        lineDrawView.secondPoint = CGPoint(x: 0, y: 0)
        lineDrawView.height = 0
        lineDrawView.color = UIColor.clear
        lineDrawView.setNeedsDisplay()
        
        if let (minValue, value, maxValue, _, color): (Double?, Double?, Double?, String, UIColor?) = rightValues {
            if value != nil && rightYValueRange != nil && !(rightYValueRange!.0 == 0 && rightYValueRange!.1 == 0) {
                linePoint.alpha = 1
                linePointTopConstraint.constant = topHeight(value!, minAndMax: rightYValueRange!) - linePoint.frame.size.height/2
                
                if color == nil {
                    return
                }
                
                var firstPoint: CGPoint? = nil
                var secondPoint: CGPoint? = nil
                
                if minValue != nil {
                    
                    if minValue < rightYValueRange!.0 {
                        firstPoint = CGPoint(x: 0, y: drawTotalHeight!)
                    }
                    else {
                        firstPoint = CGPoint(x: 0, y: topHeight((value! - minValue!)/2 + minValue!, minAndMax: rightYValueRange!))
                    }
                    
                }
                
                if maxValue != nil {
                    
                    if maxValue < rightYValueRange!.0 {
                        secondPoint = CGPoint(x: self.frame.size.width, y:drawTotalHeight!)
                    }
                    else {
                        secondPoint = CGPoint(x: self.frame.size.width, y:topHeight((maxValue! - value!)/2 + value!, minAndMax: rightYValueRange!))
                    }
                    
                }
                lineDrawView.firstPoint = firstPoint
                lineDrawView.middlePoint = CGPoint(x: self.frame.size.width/2, y:topHeight(value!, minAndMax: rightYValueRange!))
                lineDrawView.secondPoint = secondPoint
                lineDrawView.height = drawTotalHeight
                lineDrawView.color = color
                lineDrawView.setNeedsDisplay()
            }
            else {
                
            }
        }
    }
    
    func topHeight(_ value: Double, minAndMax:(Double, Double)) -> CGFloat {
        
        if minAndMax.0 == minAndMax.1 {
            return drawTotalHeight! - CGFloat(value)
        }
        
        return drawTotalHeight! -  CGFloat((value - minAndMax.0) / (minAndMax.1 - minAndMax.0)) * drawTotalHeight! * 5 / 6
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        resetCell()
        drawLeftValues()
        drawRightValues()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
}

class LineView: UIView {
    
    var firstPoint: CGPoint?
    var middlePoint: CGPoint?
    var secondPoint: CGPoint?
    var height: CGFloat?
    var color: UIColor?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if middlePoint == nil || height == nil || color == nil {
            return
        }
        
        let context = UIGraphicsGetCurrentContext()
        if firstPoint != nil {
            
            // 画线
            context?.setStrokeColor(color!.cgColor)
            context?.setLineWidth(1)
            context?.addLines(between: [firstPoint!, middlePoint!])
//            CGContextAddLines(context, [firstPoint!, middlePoint!], 2)
            context?.drawPath(using: CGPathDrawingMode.stroke)
            
            // 画多边形
            context?.setStrokeColor(UIColor.clear.cgColor)
            context?.setLineWidth(0)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            color!.getRed(&red, green: &green, blue: &blue, alpha: nil)
            context?.setFillColor([red, green, blue, 0.5])
            context?.move(to: CGPoint(x: firstPoint!.x, y: firstPoint!.y))
            context?.addLine(to: CGPoint(x: middlePoint!.x, y: middlePoint!.y))
            context?.addLine(to: CGPoint(x: middlePoint!.x, y: height!))
            context?.addLine(to: CGPoint(x: firstPoint!.x, y: height!))
            context?.closePath()
            context?.drawPath(using: CGPathDrawingMode.fillStroke); //根据坐标绘制路径
        }
        
        if secondPoint != nil {
            // 画线
            context?.setStrokeColor(color!.cgColor)
            context?.setLineWidth(1)
            
            context?.addLines(between: [middlePoint!, secondPoint!])
//            CGContextAddLines(context, [middlePoint!, secondPoint!], 2)
            context?.drawPath(using: CGPathDrawingMode.stroke)
            
            // 画多边形
            context?.setStrokeColor(UIColor.clear.cgColor)
            context?.setLineWidth(0)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            color!.getRed(&red, green: &green, blue: &blue, alpha: nil)
            context?.setFillColor([red, green, blue, 0.5])
            context?.move(to: CGPoint(x: middlePoint!.x, y: middlePoint!.y))
            context?.addLine(to: CGPoint(x: secondPoint!.x, y: secondPoint!.y))
            context?.addLine(to: CGPoint(x: secondPoint!.x, y: height!))
            context?.addLine(to: CGPoint(x: middlePoint!.x, y: height!))
            context?.closePath()
            context?.drawPath(using: CGPathDrawingMode.fillStroke); //根据坐标绘制路径
        }
    }
}


