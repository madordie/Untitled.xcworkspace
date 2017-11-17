//
//  Extension.swift
//  Command Tool
//
//  Created by 孙继刚 on 2017/11/15.
//  Copyright © 2017年 madordie.github.io. All rights reserved.
//
import Foundation

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let r = Range(uncheckedBounds: (lower: max(0, r.lowerBound),
                                            upper: min(count, r.upperBound)))
            let start = index(startIndex, offsetBy: r.lowerBound)
            let end = index(startIndex, offsetBy: r.upperBound)
            return String(self[start..<end])
        }
    }
}


