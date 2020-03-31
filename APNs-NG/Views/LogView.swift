//
//  LogView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import Combine

class LogView: NSBox {
    
    @IBOutlet private weak var textView: NSTextView!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.string = AppService.current.logObject.value
        self.cancellables.insert(
            AppService.current.logObject.$value.sink(receiveValue: { [weak self] log in
                guard let self = self else {
                    return
                }
                self.textView.string = log
                self.textView.scrollRangeToVisible(NSRange(location: log.utf16.count, length: 0))
            })
        )
    }
}
