//
//  DoubleYAxisLineChart.swift
//  Chart
//
//  Created by Yalin on 15/9/12.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

protocol DoubleYAxisLineChartDataSource {
    func numberOfDatas(_ chart: DoubleYAxisLineChart) -> Int
    func chart(_ chart: DoubleYAxisLineChart, minAndMaxLabelDatasOfYAxis isLeftYAxis: Bool) -> (minValue: Double, maxValue: Double)?
    // 注意这里返回的值不能超出Y轴Label范围,(左边Y轴对应值，右边Y轴对应值，X轴对应值)
    func chart(_ chart: DoubleYAxisLineChart, valueOfIndex: Int) -> (Double?, Double?, String)
    func chart(_ chart: DoubleYAxisLineChart, colorOfChart isLeftYAxis: Bool) -> UIColor
}

class DoubleYAxisLineChart: UIView {

    fileprivate var collectionLayout: UICollectionViewFlowLayout
    
    var dataSource: DoubleYAxisLineChartDataSource?
    fileprivate var leftRangeValues: (Double, Double)?
    fileprivate var rightRangeValues: (Double, Double)?
    fileprivate var leftLabelColor: UIColor?
    fileprivate var rightLabelColor: UIColor?
    fileprivate let YLabelWidth: CGFloat = 44
    
    fileprivate var collectionView: UICollectionView
    fileprivate let cellId = "DoubleYLineChartCell"
    
    required init?(coder aDecoder: NSCoder) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumLineSpacing = 0
        
        collectionLayout = flowLayout
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 120, height: 120), collectionViewLayout: collectionLayout)
        super.init(coder: aDecoder)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.collectionViewLayout = collectionLayout
        
        registerCell()
    }
    
    func reloadDatas() {
        // 清除视图
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        self.setNeedsDisplay()
    }
    
//    override init(frame: CGRect) {
//        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionLayout)
//        super.init(frame: frame)
//        collectionView.frame = self.bounds
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.collectionViewLayout = collectionLayout
//        self.addSubview(collectionView)
//        registerCell()
//    }
    
    fileprivate func registerCell() {
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        collectionView.frame = CGRect(x: YLabelWidth, y: 0, width: self.bounds.size.width - (2 * YLabelWidth), height: self.bounds.size.height)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.addSubview(collectionView)
        
        drawLeftYLabels()
        drawRightYLabels()
        collectionView.reloadData()
        
//        let count = dataSource!.numberOfDatas(self)
//        if count > 8 {
//            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: dataSource!.numberOfDatas(self) - 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Right, animated: false)
//        }
    }
    
    func clearYLabels() {
        for view in self.subviews {
            if view != collectionView {
                view.removeFromSuperview()
            }
        }
    }
    
    func drawLeftYLabels() {
        leftRangeValues = dataSource?.chart(self, minAndMaxLabelDatasOfYAxis: true)
        leftLabelColor = dataSource?.chart(self, colorOfChart: true)
        
        if leftRangeValues != nil {
            var values = dealYAxisDatas(leftRangeValues!.0, max: leftRangeValues!.1)
            let space = (self.frame.size.height - 57) / 6
            
            var frame = CGRect(x: 0, y: 0, width: YLabelWidth, height: 24)
            for i in 0...5 {
                frame.origin = CGPoint(x: frame.origin.x, y: self.frame.size.height - 57 - (CGFloat(i) * space) - (frame.size.height / 2))
                let YLabel = UILabel(frame: frame)
                YLabel.text = String(format: "%.1f", arguments: [values[i]])
                YLabel.font = UIFont.systemFont(ofSize: 12)
                YLabel.textAlignment = NSTextAlignment.center
                if leftLabelColor != nil {
                    YLabel.textColor = leftLabelColor!
                }
                self.addSubview(YLabel)
            }
        }
    }
    
    func drawRightYLabels() {
        rightRangeValues = dataSource?.chart(self, minAndMaxLabelDatasOfYAxis: false)
        rightLabelColor = dataSource?.chart(self, colorOfChart: false)
        
        if rightRangeValues != nil {
            var values = dealYAxisDatas(rightRangeValues!.0, max: rightRangeValues!.1)
            let space = (self.frame.size.height - 57) / 6
            
            var frame = CGRect(x: self.bounds.size.width - YLabelWidth, y: 0, width: YLabelWidth, height: 24)
            for i in 0...5 {
                frame.origin = CGPoint(x: frame.origin.x, y: self.frame.size.height - 57 - (CGFloat(i) * space) - (frame.size.height / 2))
                let YLabel = UILabel(frame: frame)
                YLabel.text = String(format: "%.1f", arguments: [values[i]])
                YLabel.font = UIFont.systemFont(ofSize: 12)
                YLabel.textAlignment = NSTextAlignment.center
                if rightLabelColor != nil {
                    YLabel.textColor = rightLabelColor!
                }
                self.addSubview(YLabel)
            }
        }
    }
    
    func dealYAxisDatas(_ min: Double, max: Double) -> [Double] {
        let length = (max - min) / 5
        var datas: [Double] = [min]
        
        for i in 1...4 {
            datas.append(min + Double(i) * length)
        }
        
        datas.append(max)
        
        return datas
    }
}


extension DoubleYAxisLineChart: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dataSource != nil {
            return dataSource!.numberOfDatas(self)
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DoubleYLineChartCell
        
        
        cell.resetCell()
        cell.leftValues = nil
        cell.rightValues = nil
        cell.leftYValueRange = leftRangeValues
        cell.rightYValueRange = rightRangeValues
        
        let currentIndexValues = dataSource?.chart(self, valueOfIndex: (indexPath as NSIndexPath).row)
        if currentIndexValues != nil {
            if (indexPath as NSIndexPath).row == 0 && (indexPath as NSIndexPath).row+1 < collectionView.numberOfItems(inSection: 0) {
                let nextIndexValues = dataSource?.chart(self, valueOfIndex: (indexPath as NSIndexPath).row + 1)
                
                if currentIndexValues!.0 != nil {
                    cell.setLeftValues(nil, value: currentIndexValues!.0, maxValue: nextIndexValues!.0, XAxisString: currentIndexValues!.2, color: leftLabelColor)
                }
                
                if currentIndexValues!.1 != nil {
                    cell.setRightValues(nil, value: currentIndexValues!.1, maxValue: nextIndexValues!.1, XAxisString: currentIndexValues!.2, color: rightLabelColor)
                }
            }
            else if (indexPath as NSIndexPath).row == collectionView.numberOfItems(inSection: 0)-1 && (indexPath as NSIndexPath).row > 0 {
                let frontIndexValues = dataSource?.chart(self, valueOfIndex: (indexPath as NSIndexPath).row - 1)
                
                if currentIndexValues!.0 != nil {
                    cell.setLeftValues(frontIndexValues!.0, value: currentIndexValues!.0, maxValue: nil, XAxisString: currentIndexValues!.2, color: leftLabelColor)
                }
                
                if currentIndexValues!.1 != nil {
                    cell.setRightValues(frontIndexValues!.1, value: currentIndexValues!.1, maxValue: nil, XAxisString: currentIndexValues!.2, color: rightLabelColor)
                }
            }
            else {
                let nextIndexValues = dataSource?.chart(self, valueOfIndex: (indexPath as NSIndexPath).row + 1)
                let frontIndexValues = dataSource?.chart(self, valueOfIndex: (indexPath as NSIndexPath).row - 1)
                
                if currentIndexValues!.0 != nil {
                    cell.setLeftValues(frontIndexValues!.0, value: currentIndexValues!.0, maxValue: nextIndexValues!.0, XAxisString: currentIndexValues!.2, color: leftLabelColor)
                }
                
                if currentIndexValues!.1 != nil {
                    cell.setRightValues(frontIndexValues!.1, value: currentIndexValues!.1, maxValue: nextIndexValues!.1, XAxisString: currentIndexValues!.2, color: rightLabelColor)
                }
            }
            
            cell.setNeedsDisplay()
        }
        
        
        
        return cell
    }
}

extension DoubleYAxisLineChart: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.frame.size.width  - (2 * YLabelWidth)) / 8, height: collectionView.frame.size.height)
    }
}
