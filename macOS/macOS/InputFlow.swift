//
//  InputFlow.swift
//  macOS
//
//  Created by 孙继刚 on 2017/11/16.
//  Copyright © 2017年 madordie.github.io. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class InputFlow {

    let input = PublishSubject<KeyCode>()
    let log = ReplaySubject<String>.create(bufferSize: 10)

    /// 确认的纵列个数 用于校验数据是否完整和正确
    private let csv_column_count: Int
    /// 用于偏移提示的题号
    private let subjects_count_offset: Int
    private let bag = DisposeBag()
    fileprivate let formatScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: "com.madordie.format"))
    fileprivate let fileHandle: FileHandle
    /// 所有测试题
    private let subjects: [Type]
    /// 当前正在输入第几题
    private var subject_idx = 0 {
        didSet {
            if subject_idx < 0 {
                log.onNext("\n\n你已经把这个问卷删除完了，来吧，重新输入吧。。")
                reset()
            } else if subject_idx >= subjects.count {
                guard page_infos.count == csv_column_count else {
                    log.onNext("\n该问卷有毒，再来一次")
                    reset()
                    return
                }
                log.onNext("\n此问卷录入完毕!\n")
                let infos = "\n" + page_infos.joined(separator: ",")
                log.onNext(infos)
                fileHandle.seekToEndOfFile()
                if let str = infos.data(using: .utf8) {
                    fileHandle.write(str)
                }
                log.onNext("\n数据已插入\n")
                reset()
            } else {
                subject_infos.removeAll()
                log.onNext("\n第\(subject_idx+1-subjects_count_offset)题\t\(subjects[subject_idx].desc())：")
            }
        }
    }
    /// 这一页的每一题数据
    private var page_infos = [String]()
    /// 该题已经选择的选项
    private var subject_infos = [String]()

    init(_ subjects: [Type]) {
        self.subjects = subjects
        let path = "\(NSHomeDirectory())/Desktop/input.csv"
        let url = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: path) == false {
            let str = "a1,a2,a3,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13A,b13B,b13C,b13D,b14A,b14B,b14C,b14D,b14E,b14F,b14G,b15A,b15B,b15C,b15D,b15E,b15F,b16A,b16B,b16C,b16D,b17,b18A,b18B,b18C,b18D,b18E,b18F,b18G,b19A,b19B,b19C,b19D,b20,b21,b22"
            try! str.write(to: url, atomically: true, encoding: .utf8)
        }
        fileHandle = try! FileHandle(forUpdating: url)

        var column = 0
        for i in subjects {
            column += i.count()
        }
        csv_column_count = column

        subjects_count_offset = subjects.flatMap({ $0.is_subject() ? nil : $0 }).count

        setup()
    }

    func reset() {
        subject_idx = 0
        page_infos.removeAll()
    }

    func setup() {
        reset()
        input.asObserver()
            .observeOn(formatScheduler)
            .subscribe(onNext: { [weak self] (key) in
                guard let _self = self else { return }
                switch key {
                case .ctl_next_subject:
                    _self._key_next_subject()
                case .ctl_abandon:
                    _self._key_abandon()
                case .info(let str):
                     _self._key_info(str)
                case .ctl_delete:
                    _self._key_delete()
                default: break;
                }
            })
            .disposed(by: bag)
    }

    func _key_delete() {
        var idx = subject_idx
        if subject_infos.count == 0 {
            idx -= 1
            if idx > 0 {
                switch subjects[idx] {
                case .choice_single, .user:
                    page_infos.removeLast()
                case .choice_multiple(let c):
                    for _ in 1...c {
                        page_infos.removeLast()
                    }
                case .sort(let c):
                    for _ in 1...c {
                        page_infos.removeLast()
                    }
                }
            }
        }
        subject_idx = idx
    }

    /// 作废
    func _key_abandon() {
        switch subjects[subject_idx] {
        case .choice_single, .user:
            page_infos.append("")
            subject_idx += 1
        case .choice_multiple(let c):
            for _ in 1...c {
                page_infos.append("")
            }
            subject_idx += 1
        case .sort(let c):
            for _ in 1...c {
                page_infos.append("")
            }
            subject_idx += 1
        }
    }
    /// 回车
    func _key_next_subject() {
        switch subjects[subject_idx] {
        case .choice_multiple(let c):
            // 多选确认
            for i in 1...c {
                page_infos.append((subject_infos.index(of: "\(i)") ?? -1) >= 0 ? "1" : "0")
            }
            subject_idx += 1
        default:
            break
        }
    }
    /// 输入
    func _key_info(_ str: String) {
        log.onNext(String(Character(Unicode.Scalar(64+Int(str)!)!)))
        switch subjects[subject_idx] {
        case .choice_single, .user:
            // 单选确认
            page_infos.append(str)
            subject_idx += 1
        case .choice_multiple(_):
            subject_infos.append(str)
        case .sort(let c):
            subject_infos.append(str)
            if subject_infos.count == c {
                // 排序确认
                var idxs = [Int]()
                var nils = [String]()
                for i in 1...c {
                    nils.append("")
                    if let idx = subject_infos.index(of: "\(i)") {
                        idxs.append(idx+1)
                    }
                }
                // 确保没有漏选
                if idxs.count == c {
                    page_infos.append(array: idxs.map({ $0.description }))
                } else {
                    page_infos.append(array: nils)
                }
                subject_idx += 1
            }
        }
    }
}

extension InputFlow {
    enum KeyCode {
        case other(UInt16)
        // 输入信息 1-9
        case info(String)
        // 下一题 \n
        case ctl_next_subject
        // 作废 0
        case ctl_abandon
        // 删除 <-
        case ctl_delete

        static func new(_ v: UInt16) -> KeyCode {
            switch v {
            case 76, 36:
                return .ctl_next_subject
            case 82, 49:
                return .ctl_abandon
            case 83..<92:
                return .info("\(v - 82)")
            case 18..<26:
                return .info("\(v - 18)")
            case 51:
                return .ctl_delete
            default:
                return .other(v)
            }
        }
    }
}
extension InputFlow {
    enum `Type` {
        case choice_single
        case choice_multiple(Int)
        case sort(Int)
        case user

        func desc() -> String {
            switch self {
            case .user:
                return "用户信息"
            case .choice_single:
                return "单选"
            case .choice_multiple(let c):
                return "多选(共\(c)个)"
            case .sort(let c):
                return "排序(共\(c)个)"
            }
        }
        /// 所占据的格子数量
        func count() -> Int {
            switch self {
            case .user,
                 .choice_single:
                return 1
            case .choice_multiple(let c):
                return c
            case .sort(let c):
                return c
            }
        }
        /// 是否记录题号
        func is_subject() -> Bool {
            switch self {
            case .user:
                return false
            default:
                return true
            }
        }
    }
}
