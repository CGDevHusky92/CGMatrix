//
//  CGMatrix.swift
//  AutoTest
//
//  Created by Chase Gorectke on 11/9/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

import UIKit

public class CGMatrix<T where T: Equatable, T: Hashable>: NSObject {
    /* Class Variables and Properties */
    
    private var matrix = [ String : T ]()
    
    private var _numberOfRows: Int = 0
    var numberOfRows: Int { get { return _numberOfRows } }
    
    // Solution Needed for removal... Two stack game... can get pretty memory intensive...
    private var _secondLargestRow: Int = 0
    
    private var _numberOfColumns: Int = 0
    var numberOfColumns: Int { get { return _numberOfColumns } }
    
    var numberOfPositions: Int {
        return numberOfRows * numberOfColumns
    }
    
    var count: Int {
        return matrix.count
    }
    
    var dimensions: CGSize {
        if fixedRows {
            if let numRows = numFixedRows {
                if let numColumns = numFixedColumns {
                    return CGSizeMake(CGFloat(numRows), CGFloat(numColumns))
                }
            }
            return CGSizeZero
        } else {
            return CGSizeMake(CGFloat(numberOfColumns), CGFloat(numberOfRows))
        }
    }
    
    // Mutable row, col count arrays only used for Floats and Ints?
    
    var numberInRow = [Int]()
    var numberInCol = [Int]()
    
    // Num open spaces? Fixed rows/cols?
    
    private let fixedRows: Bool
    private let numFixedRows: Int?
    private let numFixedColumns: Int?
    
    override init() {
        fixedRows = false
        super.init()
    }
    
    init(rows: Int, columns: Int) {
        fixedRows = true
        numFixedRows = rows
        _numberOfRows = rows
        numFixedColumns = columns
        _numberOfColumns = columns
        super.init()
    }
    
    /* Helper Methods */
    
    func isEmpty() -> Bool {
        if count == 0 {
            return true
        } else {
            return false
        }
    }
    
    func isAvailable(row: Int, col: Int) -> Bool {
        if fixedRows && (row > numFixedRows || col > numFixedColumns) {
            return false
        }
        
        if let item = matrix["\(row):\(col)"] {
            return false
        } else {
            return true
        }
    }
    
    func insertObject(object: T, atRow row: Int, andColumn col: Int) -> Bool {
        if fixedRows {
            if (row > numFixedRows || col > numFixedColumns) {
                assert(true, "Index Out Of Bounds Assertion")
                return false
            }
        } else {
            if row > _numberOfRows {
                _numberOfRows = row
            }
            if col > _numberOfColumns {
                _numberOfColumns = col
            }
        }
        
        //numberInRow[row] += 1
        //numberInCol[col] += 1
        matrix["\(row):\(col)"] = object
        return true
    }
    
    func getObjectAtRow(row: Int, andColumn col: Int) -> T? {
        if fixedRows && (row > numFixedRows || col > numFixedColumns) {
            assert(true, "Index Out Of Bounds Assertion")
        }
        return matrix["\(row):\(col)"]
    }
    
    func removeObjectAtRow(row: Int, andColumn col: Int) -> T? {
        if fixedRows && (row > numFixedRows || col > numFixedColumns) {
            assert(true, "Index Out Of Bounds Assertion")
        }
        
        //numberInRow[row] -= 1
        //numberInCol[col] -= 1
        return matrix.removeValueForKey("\(row):\(col)")
    }
    
    subscript(row: Int, col: Int) -> T? {
        get {
            return getObjectAtRow(row, andColumn: col)
        }
        set {
            self.insertObject(newValue!, atRow: row, andColumn: col)
        }
    }
}
