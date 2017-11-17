//
//  Extension.swift
//  macOS
//
//  Created by 孙继刚 on 2017/11/16.
//  Copyright © 2017年 madordie.github.io. All rights reserved.
//
extension Array {
    mutating func append(array newElements: [Element]?) {
        guard let newElements = newElements else { return }
        for item in newElements {
            append(item)
        }
    }
}

