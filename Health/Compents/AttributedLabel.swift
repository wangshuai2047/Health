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
    
    func stringSize() -> CGSize {
        return attributedString.boundingRectWithSize(self.bounds.size, options: NSStringDrawingOptions.UsesFontLeading, context: nil).size
    }
    
    func append(text: String, font: UIFont?, color: UIColor?) {
        
        let range = NSRange(location: attributedString.length, length: NSString(string: text).length)
        attributedString.appendAttributedString(NSAttributedString(string: text))
        
        if font != nil {
            attributedString.addAttribute(String(kCTFontAttributeName), value: font!, range: range)
        }
        else {
            attributedString.addAttribute(String(kCTFontAttributeName), value: UIFont.systemFontOfSize(15), range: range)
        }
        
        if color != nil {
            attributedString.addAttribute(String(kCTForegroundColorAttributeName), value: color!, range: range)
        }
        
        self.setNeedsDisplay()
    }
    
    func clear() {
        attributedString.deleteCharactersInRange(NSRange(location: 0, length: attributedString.length))
        self.setNeedsDisplay()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        setting()
        
        let ctx = UIGraphicsGetCurrentContext()
        CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, rect.size.height), 1.0, -1.0))
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, rect)
        
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        
        CTFrameDraw(frame, ctx!)
    }
    
    func setting() {
        
        
        // line break
        var lineBreak: CTLineBreakMode = .ByCharWrapping
        let lineBreakModel: CTParagraphStyleSetting = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.LineBreakMode, valueSize: sizeof(CTLineBreakMode), value: &lineBreak)
        
        // 行间距
        var spacing: CGFloat = 4.0
        let lineSpacing = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.LineSpacingAdjustment, valueSize: sizeof(CGFloat), value: &spacing)
        
        // 居中
//        var alignmentValue = CTRubyAlignment.Center
//        var alignment = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.Alignment, valueSize: sizeof(CTRubyAlignment), value: &alignmentValue)
        
        
        attributedString.addAttribute(String(kCTParagraphStyleAttributeName), value: CTParagraphStyleCreate([lineBreakModel, lineSpacing], 2), range: NSRange(location: 0, length: attributedString.length))
        
    }

}
