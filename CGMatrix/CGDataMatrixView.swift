//
//  AutoView.swift
//  AutoTest
//
//  Created by Chase Gorectke on 11/7/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

import UIKit
import CGSubExtender

@objc public protocol CGDataMatrixDelegate {
    
    /* Selection */
    
    func dataMatrix(matrixView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    
    /* Cell Size */
    
    optional func dataMatrixCellSize() -> CGSize
    
    /* Separator Properties */
    
    optional func dataMatrixSeparatorSize() -> Float
    optional func dataMatrixSeparatorColor() -> UIColor
    
}

@objc public protocol CGDataMatrixDataSource {
    
    /* Number Of Items In Views */
    
    func numberOfRowsInDataMatrix(dataMatrixView: CGDataMatrixView) -> Int
    func numberOfColumnsInDataMatrix(dataMatrixView: CGDataMatrixView) -> Int
    
    /* Item For Specific Part Of Matrix */
    
    func dataMatrixCellForSingleHeader(singleCollectionView: UICollectionView) -> UICollectionViewCell
    func dataMatrix(columnCollectionView: UICollectionView, cellForColumnAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    func dataMatrix(rowCollectionView: UICollectionView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    func dataMatrix(matrixCollectionView: UICollectionView, cellForMatrixItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    
}

public class CGDataMatrixView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public var cellSize: CGSize {
        if let del = delegate {
            if let size = del.dataMatrixCellSize?() {
                return size
            } else {
                return CGSizeMake(140.0, 80.0)
            }
        } else {
            return CGSizeMake(140.0, 80.0)
        }
    }
    
    public var separatorColor: UIColor {
        if let del = delegate {
            if let color = del.dataMatrixSeparatorColor?() {
                return color
            } else {
                return UIColor.darkGrayColor()
            }
        } else {
            return UIColor.darkGrayColor()
        }
    }
    
    public var separatorWidth: CGFloat {
        if let del = delegate {
            if let num = del.dataMatrixSeparatorSize?() {
                return CGFloat(num)
            } else {
                return 5.0
            }
        } else {
            return 5.0
        }
    }
    
    /* Left View and Subviews */
    
    var leftView: UIView!
    var headerCollectionView: UICollectionView!
    var leftSeparatorView: UIView!
    var rowNameCollectionView: UICollectionView!
    
    /* Vertical View and Subviews */
    
    var verticalSeparatorView: UIView!
    
    /* Right View and Subviews */
    
    var rightView: UIScrollView!
    var intrinsicSizeView: UIView!
    var columnNameCollectionView: UICollectionView!
    var rightSeparatorView: UIView!
    var matrixCollectionView: UICollectionView!
    
    var intrinsicConstraint: NSLayoutConstraint!
    var rightSeparatorConstraint: NSLayoutConstraint!
    var matrixHeightConstraint: NSLayoutConstraint!
    
    /* Data Items */
    
    public var delegate: CGDataMatrixDelegate?
    public var dataSource: CGDataMatrixDataSource?
    
    public init() {
        super.init(frame: CGRectZero)
        self.setupView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    /* Convenience Methods */
    
    public func reloadData() {
        self.headerCollectionView.reloadData()
        self.rowNameCollectionView.reloadData()
        self.columnNameCollectionView.reloadData()
        self.matrixCollectionView.reloadData()
    }
    
    /**
    * Generate Array with times is a convenience method for schedulers
    *
    * @parameter startTime : 0.0 - 23.999 based on military time
    * @parameter endTime   : 0 - 23.999 based on military time
    * @parameter interval  : 0.0 - 8.0 based on minutes per hour so 45 min intervals is 0.75 or 3/4 of an hour
    */
    public func generateArrayWithStartingDate(startDate: NSDate, andEndDate endDate: NSDate, withMinuteInterval minutes: Int) -> [String] {
        let interval: Float = Float(minutes) / 60.0
        assert(interval <= 8.0 && interval >= 0.0)
        
        let startHour = Float(startDate.hour())
        let startTime = startHour + Float(startDate.minutes()) / 60.0
        
        let endHour = Float(endDate.hour())
        let endTime = endHour + Float(endDate.minutes()) / 60.0
        
        return generateArrayWithStartingTime(startTime, andEndTime: endTime, withInterval: interval)
    }
    
    /**
     * Generate Array with times is a convenience method for schedulers
     *
     * @parameter startTime : 0.0 - 23.999 based on military time
     * @parameter endTime   : 0 - 23.999 based on military time
     * @parameter interval  : 0.0 - 8.0 based on minutes per hour so 45 min intervals is 0.75 or 3/4 of an hour
     */
    public func generateArrayWithStartingTime(startTime: Float, andEndTime endTime: Float, withInterval interval: Float) -> [String] {
        // Calculate all as a function of minutes...
        assert(startTime < 24.0 && startTime >= 0.0)
        assert(endTime < 24.0 && endTime >= 0.0)
        assert(interval <= 8.0 && interval >= 0.0)
        
        var currentMins = Int(startTime * 60.0)
        let endMins = Int(endTime * 60.0)
        var array = [String]()
        
        while currentMins <= endMins {
            let hour = (currentMins / 60) % 12 == 0 ? 12 : (currentMins / 60) % 12
            let minutes = currentMins - ((currentMins / 60) * 60)
            
            if minutes < 10 {
                array += [ "\(hour):0\(minutes)" ]
            } else {
                array += [ "\(hour):\(minutes)" ]
            }
            
            currentMins += Int(60.0 * interval)
        }
        
        return array
    }
    
    func coordinateForIndexPath(indexPath: NSIndexPath) -> CGPoint {
        let point: (Int, Int) = self.coordinateForIndexPath(indexPath)
        return CGPointMake(CGFloat(point.0), CGFloat(point.1))
    }
    
    func coordinateForIndexPath(indexPath: NSIndexPath) -> (Int, Int) {
        let index: Int = indexPath.row
        if let dataSrc = dataSource {
            let width: Int = dataSrc.numberOfColumnsInDataMatrix(self)
            let y = index % width
            let x = (index - y) / width
            return (x, y)
        }
        return (-1, -1)
    }
    
    /* UICollectionView Data Source */
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataSrc = dataSource {
            if collectionView == headerCollectionView {
                return 1
            } else if collectionView == rowNameCollectionView {
                return dataSrc.numberOfRowsInDataMatrix(self)
            } else if collectionView == columnNameCollectionView {
                return dataSrc.numberOfColumnsInDataMatrix(self)
            } else {
                return (dataSrc.numberOfRowsInDataMatrix(self) * dataSrc.numberOfColumnsInDataMatrix(self))
            }
        } else {
            return 0
        }
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if let dataSrc = dataSource {
            if collectionView == headerCollectionView {
                cell = dataSrc.dataMatrixCellForSingleHeader(collectionView)
            } else if collectionView == rowNameCollectionView {
                cell = dataSrc.dataMatrix(collectionView, cellForRowAtIndexPath: indexPath)
            } else if collectionView == columnNameCollectionView {
                cell = dataSrc.dataMatrix(collectionView, cellForColumnAtIndexPath: indexPath)
            } else {
                cell = dataSrc.dataMatrix(collectionView, cellForMatrixItemAtIndexPath: indexPath)
            }
        } else {
            return UICollectionViewCell()
        }
        
        return cell
    }
    
    /* UICollectionView Delegate */
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == matrixCollectionView {
            if let del = delegate {
                del.dataMatrix(collectionView, didSelectItemAtIndexPath: indexPath)
            }
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == matrixCollectionView {
            if let del = delegate {
                
            }
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    /* Nib Registration */
    
    public func registerNib(cellNib: UINib?, forSingleHeaderCellWithReuseIdentifier reuseIdentifier: String) {
        headerCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    public func registerNib(cellNib: UINib?, forColumnCellWithReuseIdentifier reuseIdentifier: String) {
        columnNameCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    public func registerNib(cellNib: UINib?, forRowCellWithReuseIdentifier reuseIdentifier: String) {
        rowNameCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    public func registerNib(cellNib: UINib?, forMatrixCellWithReuseIdentifier reuseIdentifier: String) {
        matrixCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    /* Class Registration */
    
    public func registerClass(cellClass: AnyClass?, forSingleHeaderCellWithReuseIdentifier reuseIdentifier: String) {
        headerCollectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    public func registerClass(cellClass: AnyClass?, forColumnCellWithReuseIdentifier reuseIdentifier: String) {
        columnNameCollectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    public func registerClass(cellClass: AnyClass?, forRowCellWithReuseIdentifier reuseIdentifier: String) {
        rowNameCollectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    public func registerClass(cellClass: AnyClass?, forMatrixCellWithReuseIdentifier reuseIdentifier: String) {
        matrixCollectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    /* Hack To Have Two CollectionViews Scroll Together */
    
    var tempScrollView: UIScrollView?
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if let setScrollView = tempScrollView {
            if scrollView == rowNameCollectionView && setScrollView == rowNameCollectionView {
                matrixCollectionView.setContentOffset(scrollView.contentOffset, animated: false)
            } else if scrollView == matrixCollectionView && setScrollView == matrixCollectionView {
                rowNameCollectionView.setContentOffset(scrollView.contentOffset, animated: false)
            }
        }
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.tempScrollView = scrollView
    }
    
    /* View and Autolayout Constraints Programmatically */
    
    private func setupView() {
        self.initViews()
        
        /* Super View Constraints */
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[leftView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: [ "leftView" : self.leftView ]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[verticalSeparatorView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: [ "verticalSeparatorView" : self.verticalSeparatorView ]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[rightView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: [ "rightView" : self.rightView ]))
        
        let horizontalVFL: String = String(format: "H:|[leftView(\(self.cellSize.width))]-0-[verticalSeparatorView(\(self.separatorWidth))]-0-[rightView]|")
        let horizontalViews = [ "leftView" : self.leftView, "verticalSeparatorView" : self.verticalSeparatorView, "rightView" : self.rightView ]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(horizontalVFL, options: NSLayoutFormatOptions(0), metrics: nil, views: horizontalViews))
        
        /* Left View Constraints */
        
        leftView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[headerCollectionView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: [ "headerCollectionView" : self.headerCollectionView ]))
        leftView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[leftSeparatorView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: [ "leftSeparatorView" : self.leftSeparatorView ]))
        leftView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[rowNameCollectionView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: [ "rowNameCollectionView" : self.rowNameCollectionView ]))
        
        let leftVerticalVFL: String = String(format: "V:|[headerCollectionView(\(self.cellSize.height))]-0-[leftSeparatorView(\(self.separatorWidth))]-0-[rowNameCollectionView]|")
        let leftViews = [ "headerCollectionView" : self.headerCollectionView, "leftSeparatorView" : self.leftSeparatorView, "rowNameCollectionView" : self.rowNameCollectionView ]
        leftView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(leftVerticalVFL, options: NSLayoutFormatOptions(0), metrics: nil, views: leftViews))
        
        /* Right View Constraints */
        
        rightView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[intrinsicSizeView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: [ "intrinsicSizeView" : self.intrinsicSizeView ]))
        rightView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[intrinsicSizeView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: [ "intrinsicSizeView" : self.intrinsicSizeView ]))
        
        intrinsicSizeView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[columnNameCollectionView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: [ "columnNameCollectionView" : self.columnNameCollectionView ]))
        intrinsicSizeView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[matrixCollectionView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: [ "matrixCollectionView" : self.matrixCollectionView ]))
        
        let rightVerticalVFL: String = String(format: "V:|[columnNameCollectionView(\(self.cellSize.height))]-0-[rightSeparatorView(\(self.separatorWidth))]-0-[matrixCollectionView]|")
        let rightViews = [ "columnNameCollectionView" : self.columnNameCollectionView, "rightSeparatorView" : self.rightSeparatorView, "matrixCollectionView" : self.matrixCollectionView ]
        intrinsicSizeView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(rightVerticalVFL, options: NSLayoutFormatOptions(0), metrics: nil, views: rightViews))
        
        intrinsicConstraint = NSLayoutConstraint(item: intrinsicSizeView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 450)
        intrinsicSizeView.addConstraint(intrinsicConstraint)
        
        rightSeparatorConstraint = NSLayoutConstraint(item: rightSeparatorView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 450)
        rightSeparatorView.addConstraint(rightSeparatorConstraint)
        
        matrixHeightConstraint = NSLayoutConstraint(item: matrixCollectionView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 450)
        matrixCollectionView.addConstraint(matrixHeightConstraint)
    }
    
    private func initViews() {
        /* Left View Initialization */
        
        leftView = UIView()
        let headerLayout = UICollectionViewFlowLayout()
        headerLayout.itemSize = cellSize
        headerCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: headerLayout)
        leftSeparatorView = UIView()
        let rowNameLayout = UICollectionViewFlowLayout()
        rowNameLayout.itemSize = cellSize
        rowNameCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: rowNameLayout)
        
        /* Separator View Initialization */
        
        verticalSeparatorView = UIView()
        
        /* Right View Initialization */
        
        rightView = UIScrollView()
        intrinsicSizeView = UIView()
        let columnNameLayout = UICollectionViewFlowLayout()
        columnNameLayout.itemSize = cellSize
        columnNameCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: columnNameLayout)
        rightSeparatorView = UIView()
        let matrixLayout = UICollectionViewFlowLayout()
        matrixLayout.itemSize = cellSize
        matrixCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: matrixLayout)
        
        /* Left View Mask, Delegate, and Data Set */
        
        leftView.setTranslatesAutoresizingMaskIntoConstraints(false)
        headerCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        leftSeparatorView.setTranslatesAutoresizingMaskIntoConstraints(false)
        rowNameCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        rowNameCollectionView.delegate = self
        rowNameCollectionView.dataSource = self
        rowNameCollectionView.bounces = false
        rowNameCollectionView.showsVerticalScrollIndicator = false
        headerCollectionView.backgroundColor = UIColor.darkGrayColor()
        rowNameCollectionView.backgroundColor = UIColor.darkGrayColor()
        leftSeparatorView.backgroundColor = self.separatorColor
        
        leftView.addSubview(headerCollectionView)
        leftView.addSubview(leftSeparatorView)
        leftView.addSubview(rowNameCollectionView)
        
        /* Left View Mask and Data Set */
        
        verticalSeparatorView.setTranslatesAutoresizingMaskIntoConstraints(false)
        verticalSeparatorView.backgroundColor = self.separatorColor
        
        /* Right View Mask, Delegate, and Data Set */
        
        rightView.setTranslatesAutoresizingMaskIntoConstraints(false)
        intrinsicSizeView.setTranslatesAutoresizingMaskIntoConstraints(false)
        columnNameCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        rightSeparatorView.setTranslatesAutoresizingMaskIntoConstraints(false)
        matrixCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        rightView.showsVerticalScrollIndicator = false
        rightView.bounces = false
        columnNameCollectionView.delegate = self
        columnNameCollectionView.dataSource = self
        matrixCollectionView.delegate = self
        matrixCollectionView.dataSource = self
        matrixCollectionView.bounces = false
        columnNameCollectionView.showsHorizontalScrollIndicator = false
        intrinsicSizeView.backgroundColor = separatorColor
        columnNameCollectionView.backgroundColor = UIColor.darkGrayColor()
        matrixCollectionView.backgroundColor = UIColor.darkGrayColor()
        rightSeparatorView.backgroundColor = self.separatorColor
        
        intrinsicSizeView.addSubview(columnNameCollectionView)
        intrinsicSizeView.addSubview(rightSeparatorView)
        intrinsicSizeView.addSubview(matrixCollectionView)
        rightView.addSubview(intrinsicSizeView)
        
        self.addSubview(leftView)
        self.addSubview(verticalSeparatorView)
        self.addSubview(rightView)
    }
    
    public override func layoutSubviews() {
        if let dataSrc = dataSource {
            if let windowFrame = UIApplication.sharedApplication().keyWindow?.frame {
                let offset: CGFloat = 1.0
                let scrollWidth: CGFloat = windowFrame.width - (self.separatorWidth + self.cellSize.width)
                let columnNameCount = CGFloat(dataSrc.numberOfColumnsInDataMatrix(self))
                let cellWidths: CGFloat = (columnNameCount * self.cellSize.width) + (columnNameCount * offset)
                let barWidth: CGFloat = max(scrollWidth, cellWidths)
                let matrixHeight: CGFloat = windowFrame.height - (cellSize.height + separatorWidth)
                
                self.intrinsicConstraint.constant = cellWidths
                self.rightSeparatorConstraint.constant = barWidth
                self.matrixHeightConstraint.constant = matrixHeight
            }
        }
    }
}
