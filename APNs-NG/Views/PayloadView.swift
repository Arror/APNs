//
//  PayloadView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/16.
//  Copyright © 2020 Arror. All rights reserved.
//

import SwiftUI

struct PayloadView: NSViewRepresentable {
    
    @Binding private var text: String

    init(text: Binding<String>) {
        _text = text
    }

    init(text: String) {
        self.init(text: Binding<String>.constant(text))
    }

    func makeNSView(context: Context) -> NSScrollView {
        let text = NSTextView()
        text.backgroundColor = NSColor(named: "text_input_background_color") ?? .black
        text.delegate = context.coordinator
        text.isRichText = false
        text.autoresizingMask = [.width]
        text.translatesAutoresizingMaskIntoConstraints = true
        text.isVerticallyResizable = true
        text.isHorizontallyResizable = false
        text.isAutomaticQuoteSubstitutionEnabled   = false
        text.isAutomaticLinkDetectionEnabled       = false
        text.isAutomaticSpellingCorrectionEnabled  = false
        text.isAutomaticDataDetectionEnabled       = false
        text.isAutomaticTextCompletionEnabled      = false
        text.isAutomaticTextReplacementEnabled     = false
        text.isAutomaticDashSubstitutionEnabled    = false
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.documentView = text
        scroll.drawsBackground = false

        return scroll
    }

    func updateNSView(_ view: NSScrollView, context: Context) {
        let text = view.documentView as? NSTextView
        text?.string = self.text
        guard context.coordinator.selectedRanges.count > 0 else {
            return
        }
        text?.selectedRanges = context.coordinator.selectedRanges
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        
        var parent: PayloadView
        var selectedRanges = [NSValue]()

        init(_ parent: PayloadView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
    }
}

struct PayloadView_Previews: PreviewProvider {
    
    @State static var text: String = ""
    
    static var previews: some View {
        PayloadView(text: $text)
    }
}
