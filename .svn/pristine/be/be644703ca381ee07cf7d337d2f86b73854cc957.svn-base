//
//  AttributedLabel.swift
//  CoreText_TEST
//
//  Created by Yalin on 15/8/28.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class AttributedLabel: UIView {

    var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    var isCenterAlignment: Bool = true
    
    func stringSize() -> CGSize {
        return attributedString.boundingRect(with: self.bounds.size, options: NSStringDrawingOptions.usesFontLeading, context: nil).size
    }
    
    func append(_ text: String, font: UIFont?, color: UIColor?) {
        
        let range = NSRange(location: attributedString.length, length: NSString(string: text).length)
        attributedString.append(NSAttributedString(string: text))
        
        if font != nil {
            attributedString.addAttribute(String(kCTFontAttributeName), value: font!, range: range)
        }
        else {
            attributedString.addAttribute(String(kCTFontAttributeName), value: UIFont.systemFont(ofSize: 15), range: range)
        }
        
        if color != nil {
            attributedString.addAttribute(String(kCTForegroundColorAttributeName), value: color!, range: range)
        }
        
        self.setNeedsDisplay()
    }
    
    func clear() {
        attributedString.deleteCharacters(in: NSRange(location: 0, length: attributedString.length))
        self.setNeedsDisplay()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        setting()
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.concatenate(CGAffineTransform(translationX: 0, y: rect.size.height).scaledBy(x: 1.0, y: -1.0))
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let path = CGMutablePath()
        
        path.addRect(rect)
//        CGPathAddRect(path, nil, rect)
        
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        
        CTFrameDraw(frame, ctx!)
    }
    
    func setting() {
        
        
        // line break
        var lineBreak: CTLineBreakMode = .byCharWrapping
        let lineBreakModel: CTParagraphStyleSetting = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.lineBreakMode, valueSize: MemoryLayout<CTLineBreakMode>.size, value: &lineBreak)
        
        // 行间距
        var spacing: CGFloat = 4.0
        let lineSpacing = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.lineSpacingAdjustment, valueSize: MemoryLayout<CGFloat>.size, value: &spacing)
        
        
        if isCenterAlignment == false {
            return
        }
        
        // 居中
        if #available(iOS 8.0, *) {
            var alignmentValue = CTRubyAlignment.center
             let alignment = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.alignment, valueSize: MemoryLayout<CTRubyAlignment>.size, value: &alignmentValue)
            
            attributedString.addAttribute(String(kCTParagraphStyleAttributeName), value: CTParagraphStyleCreate([lineBreakModel, lineSpacing,alignment], 3), range: NSRange(location: 0, length: attributedString.length))
        } else {
            // Fallback on earlier versions
            
            attributedString.addAttribute(String(kCTParagraphStyleAttributeName), value: CTParagraphStyleCreate([lineBreakModel, lineSpacing], 2), range: NSRange(location: 0, length: attributedString.length))
        }
    }
}
