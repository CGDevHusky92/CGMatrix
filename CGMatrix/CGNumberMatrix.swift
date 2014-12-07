//
//  CGNumberMatrix.swift
//  AutoTest
//
//  Created by Chase Gorectke on 11/10/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

import UIKit

func == <T> (lhs: CGNumberMatrix<T>, rhs: CGNumberMatrix<T>) -> Bool {
    
    return false
}

func != <T> (lhs: CGNumberMatrix<T>, rhs: CGNumberMatrix<T>) -> Bool {
    return !(lhs == rhs)
}

func + <T> (lhs: CGNumberMatrix<T>, rhs: CGNumberMatrix<T>) -> CGNumberMatrix<T> {
    return lhs
}

func += <T> (inout lhs: CGNumberMatrix<T>, rhs: CGNumberMatrix<T>) {
    lhs = lhs + rhs
}

func * <T> (lhs: CGNumberMatrix<T>, rhs: CGNumberMatrix<T>) -> CGNumberMatrix<T> {
    return lhs
}

func *= <T> (inout lhs: CGNumberMatrix<T>, rhs: CGNumberMatrix<T>) {
    lhs = lhs + rhs
}

func - <T> (lhs: CGNumberMatrix<T>, rhs: CGNumberMatrix<T>) -> CGNumberMatrix<T> {
    return lhs
}

func -= <T> (inout lhs: CGNumberMatrix<T>, rhs: CGNumberMatrix<T>) {
    lhs = lhs + rhs
}

func / <T> (lhs: CGNumberMatrix<T>, rhs: CGNumberMatrix<T>) -> CGNumberMatrix<T> {
    return lhs
}

func /= <T> (inout lhs: CGNumberMatrix<T>, rhs: CGNumberMatrix<T>) {
    lhs = lhs + rhs
}

class CGNumberMatrix<T where T: CGNumeric, T: Hashable>: CGMatrix<T> {
    var rowTotal = [T]()
    var colTotal = [T]()
    
    override func insertObject(object: T, atRow row: Int, andColumn col: Int) -> Bool {
        let ret = super.insertObject(object, atRow: row, andColumn: col)
        if ret {
            rowTotal[row] += object
            colTotal[col] += object
        }
        return ret
    }
    
    override func removeObjectAtRow(row: Int, andColumn col: Int) -> T? {
        let ret = super.removeObjectAtRow(row, andColumn: col)
        if let object = ret {
            rowTotal[row] -= object
            colTotal[col] -= object
        }
        return ret
    }
}
