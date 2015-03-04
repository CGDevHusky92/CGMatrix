//
//  ViewController.swift
//  AutoTest
//
//  Created by Chase Gorectke on 11/7/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CGDataMatrixDelegate, CGDataMatrixDataSource {
    
    @IBOutlet var testView: CGDataMatrixView!
    
    var columnNames: [String]!
    var rowNames: [String]!
    var matrix: CGMatrix<String>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        testView.delegate = self
        testView.dataSource = self
        
        self.setupArrays()
        
        var nib: UINib = UINib(nibName: "TestCollectionViewCell", bundle: nil)
        testView.registerNib(nib, forSingleHeaderCellWithReuseIdentifier: "SingleIdentifier")
        testView.registerNib(nib, forColumnCellWithReuseIdentifier: "ColumnIdentifier")
        testView.registerNib(nib, forRowCellWithReuseIdentifier: "RowIdentifier")
        testView.registerNib(nib, forMatrixCellWithReuseIdentifier: "MatrixIdentifier")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        testView.reloadData()
    }
    
    func setupArrays() {
        columnNames = [ "Alyssa", "Chase", "Darcy", "Marvin", "Nathan", "Robert" ]
        rowNames = testView.generateArrayWithStartingTime(9, andEndTime: 16.5, withInterval: 0.75)
        
        matrix = CGMatrix(rows: rowNames.count, columns: columnNames.count)
        
        for row in 0...rowNames.count {
            for col in 0...columnNames.count {
                matrix[row, col] = "\(row), \(col)"
            }
        }
    }

    /* CGDataMatrix Delegate */
    
    func dataMatrix(matrixView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Matrix Object Selected...")
    }

    func dataMatrixSeparatorSize() -> Float {
        return 10.0
    }
    
    /* CGDataMatrix Data Source */
    
    func numberOfRowsInDataMatrix(dataMatrixView: CGDataMatrixView) -> Int {
        return rowNames.count
    }
    
    func numberOfColumnsInDataMatrix(dataMatrixView: CGDataMatrixView) -> Int {
        return columnNames.count
    }
    
    func dataMatrixCellForSingleHeader(singleCollectionView: UICollectionView) -> UICollectionViewCell {
        let indexPath: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        var cell: TestCollectionViewCell = singleCollectionView.dequeueReusableCellWithReuseIdentifier("SingleIdentifier", forIndexPath: indexPath) as! TestCollectionViewCell
        
        cell.textLabel.text = "";
        
        return cell
    }
    
    func dataMatrix(columnCollectionView: UICollectionView, cellForColumnAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: TestCollectionViewCell = columnCollectionView.dequeueReusableCellWithReuseIdentifier("ColumnIdentifier", forIndexPath: indexPath) as! TestCollectionViewCell
        
        cell.textLabel.text = columnNames[indexPath.row];
        
        return cell
    }
    
    func dataMatrix(rowCollectionView: UICollectionView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: TestCollectionViewCell = rowCollectionView.dequeueReusableCellWithReuseIdentifier("RowIdentifier", forIndexPath: indexPath) as! TestCollectionViewCell
        
        cell.textLabel.text = rowNames[indexPath.row];
        
        return cell
    }
    
    func dataMatrix(matrixCollectionView: UICollectionView, cellForMatrixItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: TestCollectionViewCell = matrixCollectionView.dequeueReusableCellWithReuseIdentifier("MatrixIdentifier", forIndexPath: indexPath) as! TestCollectionViewCell
        
        let coord: (Int, Int) = testView.coordinateForIndexPath(indexPath)
        let text = matrix[coord.0, coord.1]
        cell.textLabel.text = text
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

