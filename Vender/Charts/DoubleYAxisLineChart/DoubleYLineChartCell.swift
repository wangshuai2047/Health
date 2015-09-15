//
//  DoubleYLineChartCell.swift
//  Chart
//
//  Created by Yalin on 15/9/12.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class DoubleYLineChartCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var linePoint: UIImageView!
    @IBOutlet weak var lineDrawView: LineView!
    @IBOutlet weak var barViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var linePointTopConstraint: NSLayoutConstraint!
    
    var leftYValueRange: (Double, Double)?
    var rightYValueRange: (Double, Double)?
    private var drawTotalHeight: CGFloat?
    private var leftValues: (minValue: Double?, value: Double?, maxValue: Double?, XAxisString: String, color: UIColor?)?
    private var rightValues: (minValue: Double?, value: Double?, maxValue: Double?, XAxisString: String, color: UIColor?)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("cell Init")
        
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
    }
    
    func resetCell() {
        timeLabel.text = ""
        
        drawTotalHeight = barView.frame.origin.y + barView.frame.size.height
        print("barView.frame: \(barView.frame)")
        barViewTopConstraint.constant = drawTotalHeight!
        linePointTopConstraint.constant = drawTotalHeight!
        linePoint.alpha = 0
        
        lineDrawView.firstPoint = nil
        lineDrawView.secondPoint = nil
        lineDrawView.height = nil
        lineDrawView.color = nil
    }
    
    func setLeftValues(minValue: Double?, value: Double?, maxValue: Double?, XAxisString: String, color: UIColor?) {
        leftValues = (minValue, value, maxValue, XAxisString, color)
    }
    
    func setRightValues(minValue: Double?, value: Double?, maxValue: Double?, XAxisString: String, color: UIColor?) {
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
                    firstPoint = CGPoint(x: 0, y: topHeight((value! - minValue!)/2 + minValue!, minAndMax: rightYValueRange!))
                }
                
                if maxValue != nil {
                    secondPoint = CGPoint(x: self.frame.size.width, y:topHeight((maxValue! - value!)/2 + value!, minAndMax: rightYValueRange!))
                }
                lineDrawView.firstPoint = firstPoint
                lineDrawView.middlePoint = CGPoint(x: self.frame.size.width/2, y:topHeight(value!, minAndMax: rightYValueRange!))
                lineDrawView.secondPoint = secondPoint
                lineDrawView.height = drawTotalHeight
                lineDrawView.color = color
                lineDrawView.setNeedsDisplay()
            }
            else {
                lineDrawView.firstPoint = CGPoint(x: 0, y: 0)
                lineDrawView.middlePoint = CGPoint(x: 0, y: 0)
                lineDrawView.secondPoint = CGPoint(x: 0, y: 0)
                lineDrawView.height = 0
                lineDrawView.color = UIColor.clearColor()
                lineDrawView.setNeedsDisplay()
            }
        }
    }
    
    func topHeight(value: Double, minAndMax:(Double, Double)) -> CGFloat {
        return drawTotalHeight! -  CGFloat((value - minAndMax.0) / (minAndMax.1 - minAndMax.0)) * drawTotalHeight! * 5 / 6
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
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
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if middlePoint == nil || height == nil || color == nil {
            return
        }
        
        let context = UIGraphicsGetCurrentContext()
        if firstPoint != nil {
            
            // 画线
            CGContextSetStrokeColorWithColor(context, color!.CGColor)
            CGContextSetLineWidth(context, 1)
            CGContextAddLines(context, [firstPoint!, middlePoint!], 2)
            CGContextDrawPath(context, CGPathDrawingMode.Stroke)
            
            // 画多边形
            CGContextSetStrokeColorWithColor(context, UIColor.clearColor().CGColor)
            CGContextSetLineWidth(context, 0)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            color!.getRed(&red, green: &green, blue: &blue, alpha: nil)
            CGContextSetFillColor(context, [red, green, blue, 0.5])
            CGContextMoveToPoint(context, firstPoint!.x, firstPoint!.y)
            CGContextAddLineToPoint(context, middlePoint!.x, middlePoint!.y)
            CGContextAddLineToPoint(context, middlePoint!.x, height!)
            CGContextAddLineToPoint(context, firstPoint!.x, height!)
            CGContextClosePath(context)
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke); //根据坐标绘制路径
        }
        
        if secondPoint != nil {
            // 画线
            CGContextSetStrokeColorWithColor(context, color!.CGColor)
            CGContextSetLineWidth(context, 1)
            CGContextAddLines(context, [middlePoint!, secondPoint!], 2)
            CGContextDrawPath(context, CGPathDrawingMode.Stroke)
            
            // 画多边形
            CGContextSetStrokeColorWithColor(context, UIColor.clearColor().CGColor)
            CGContextSetLineWidth(context, 0)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            color!.getRed(&red, green: &green, blue: &blue, alpha: nil)
            CGContextSetFillColor(context, [red, green, blue, 0.5])
            CGContextMoveToPoint(context, middlePoint!.x, middlePoint!.y)
            CGContextAddLineToPoint(context, secondPoint!.x, secondPoint!.y)
            CGContextAddLineToPoint(context, secondPoint!.x, height!)
            CGContextAddLineToPoint(context, middlePoint!.x, height!)
            CGContextClosePath(context)
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke); //根据坐标绘制路径
        }
    }
}


