//
//  main.swift
//  Command Tool
//
//  Created by 孙继刚 on 2017/11/15.
//  Copyright © 2017年 madordie.github.io. All rights reserved.
//

import Foundation

let pages = try! NSString(contentsOf: URL(fileURLWithPath: "/Users/Madordie/Desktop/Untitled.txt"), encoding: String.Encoding.utf8.rawValue).components(separatedBy: "\n")
var end = "a1,a2,a3,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13A,b13B,b13C,b13D,b14A,b14B,b14C,b14D,b14E,b14F,b14G,b15A,b15B,b15C,b15D,b15E,b15F,b16A,b16B,b16C,b16D,b17,b18A,b18B,b18C,b18D,b18E,b18F,b18G,b19A,b19B,b19C,b19D,b20,b21,b22\n"

func format() {
    var idx = 0
    @discardableResult
    func input_err(_ info: String = "\(#line)") -> String {
        let err = "Line \(idx),Column  开始错误，请核实\(info)"
        print(err)
        return err
    }
    end = end + pages.map { (p) -> String in
        idx += 1
        var row_i = 0
        var line = [String]()
        guard p.count > 0 else { return "" }

        let infos = p.components(separatedBy: "+")
        guard infos.count == 2 else { return "" }

        // 提取 用户数据
        guard let usr = infos.first else { return input_err("用户信息") }
        guard usr.count == 3 else { return input_err("用户数据不完善") }
        for i in usr {
            line.append(String(i))
        }

        guard let last = infos.last else { return input_err() }


        /// 单选
        ///
        /// - Parameter count: 共有几题
        func choice(single count: Int) {
            for i in last[row_i..<(row_i+count)] {
                line.append(String(i))
            }
            row_i += count
        }
        /// 多选
        ///
        /// - Parameter count: 共有几个选项
        func choice(multiple count: Int) {
            row_i += 1
            let p = (last[row_i..<Int.max].components(separatedBy: "0").first ?? "")
                .map({ Int(String($0)) ?? 0 })
            for i in 1...count {
                line.append(String(p.contains(i) ? 1 : 0))
            }
            row_i += p.count + 1
        }
        /// 排序
        ///
        /// - Parameter count: 共有几个选项
        func sort(option count: Int, _line: Int = #line) {
            let all = last[row_i..<(row_i+count)].flatMap({ (c) -> String? in
                guard c != "." else { return nil }
                return String(c)
            })
            if all.count == count {
                for i in 1...count {
                    if let idx = all.index(of: i.description) {
                        line.append(idx.description)
                    } else {
                        input_err("排序数据有误(#\(_line))")
                    }
                }
            } else {
                for _ in 1...count {
                    line.append("")
                }
            }
            row_i += count
        }

        // 提取 1-12题 全部单选
        choice(single: 12)

        // 提取 13 题 4个排序
        sort(option: 4)

        // 提取 14  多选 7个答案
        choice(multiple: 7)

        // 提取 15 多选  6个答案
        choice(multiple: 6)

        // 提取 16 多选  4个答案
        choice(multiple: 4)

        // 提取 17 单选
        choice(single: 1)

        // 提取 18 排序 7
        sort(option: 7)

        // 提取 19 排序 4
        sort(option: 4)

        // 提取 20-22 单选
        choice(single: 3)

        // 过滤 作废数据
        line = line.map({ (v) -> String in
            guard v != "." else { return "" }
            return v
        })
        // 打包返回
        if line.count != 51 {
            print(input_err() + "个数不对。。")
        }
        return line.joined(separator: ",")
    }
    .joined(separator: "\n")

    try! end.write(to: URL.init(fileURLWithPath: "/Users/Madordie/Desktop/未命名.csv"), atomically: true, encoding: String.Encoding.utf8)
}

format()

