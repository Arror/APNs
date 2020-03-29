//
//  PayloadBox.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import Combine

class PayloadBox: NSBox, NSTextViewDelegate {
    
    @IBOutlet private weak var sendButton: NSButton!
    @IBOutlet private weak var indicator: NSProgressIndicator!
    @IBOutlet private weak var textView: NSTextView!
    
    private var cancellables: Set<AnyCancellable> = []
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.isAutomaticQuoteSubstitutionEnabled = false
        self.textView.isAutomaticLinkDetectionEnabled = false
        self.textView.isAutomaticSpellingCorrectionEnabled = false
        self.textView.isAutomaticDataDetectionEnabled = false
        self.textView.isAutomaticTextCompletionEnabled = false
        self.textView.isAutomaticTextReplacementEnabled = false
        self.textView.isAutomaticDashSubstitutionEnabled = false
        self.textView.string = AppService.current.payloadObject.value
        self.textView.delegate = self
        if AppService.current.indicatorSubject.value {
            self.sendButton.isHidden = true
            self.indicator.startAnimation(nil)
        } else {
            self.sendButton.isHidden = false
            self.indicator.stopAnimation(nil)
        }
        self.cancellables.insert(
            AppService.current.indicatorSubject.sink(receiveValue: { [weak self] value in
                guard let self = self else {
                    return
                }
                self.updateViews(value: value)
            })
        )
    }
    
    private func updateViews(value: Bool) {
        self.sendButton.isHidden = value
        value ? self.indicator.startAnimation(nil) : self.indicator.stopAnimation(nil)
    }
    @IBAction private func sendButtonTapped(_ sender: NSButton) {
        AppService.current.pushTrigger.send()
    }
    
    func textDidChange(_ notification: Notification) {
        AppService.current.payloadObject.value = self.textView.string
    }
}
