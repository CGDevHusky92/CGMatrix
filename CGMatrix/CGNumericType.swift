//
//  CGNumericType.swift
//  AutoTest
//
//  Created by Chase Gorectke on 11/10/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

import Foundation

protocol CGNumeric: Equatable {
    func +(lhs: Self, rhs: Self) -> Self
    func +=(inout lhs: Self, rhs: Self)
    func *(lhs: Self, rhs: Self) -> Self
    func *=(inout lhs: Self, rhs: Self)
    func -(lhs: Self, rhs: Self) -> Self
    func -=(inout lhs: Self, rhs: Self)
    func /(lhs: Self, rhs: Self) -> Self
    func /=(inout lhs: Self, rhs: Self)
}

extension Int: CGNumeric {}
extension Float: CGNumeric {}
extension Double: CGNumeric {}
