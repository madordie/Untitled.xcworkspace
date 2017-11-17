//
//  ViewController.swift
//  macOS
//
//  Created by 孙继刚 on 2017/11/3.
//  Copyright © 2017年 madordie.github.io. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class ViewController: NSViewController {
    let bag = DisposeBag()

    let inputFlow = InputFlow([.user,
                               .user,
                               .user,
                               .choice_single,
                               .choice_single,
                               .choice_single,
                               .choice_single,
                               .choice_single,
                               .choice_single,
                               .choice_single,
                               .choice_single,
                               .choice_single,
                               .choice_single,
                               .choice_single,
                               .choice_single,
                               .sort(4),
                               .choice_multiple(7),
                               .choice_multiple(6),
                               .choice_multiple(4),
                               .choice_single,
                               .sort(7),
                               .sort(4),
                               .choice_single,
                               .choice_single,
                               .choice_single,
                               ])
    @IBOutlet var input: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        inputFlow.log
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (v) in
                guard let _self = self else { return }
                _self.input.string += v
                if _self.input.string.count > 500 {
                    _self.input.string = _self.input.string[100..<Int.max]
                }
                _self.input.scrollToEndOfDocument(nil)
            })
            .disposed(by: bag)
    }
    override func awakeFromNib() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] (event) -> NSEvent? in
            self?.inputFlow.input
                .onNext(InputFlow.KeyCode.new(event.keyCode))
            return nil
        }
    }
}

// MARK: - 沿用OC的方法
extension String {

    /// 取出子串
    ///
    ///    let string = "123😂🐶456"
    ///    print(string[-3..<5])
    ///         -> 123😂🐶
    ///
    /// - Parameter r: 范围
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
