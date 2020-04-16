//
//  PayloadView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/16.
//  Copyright © 2020 Arror. All rights reserved.
//

import SwiftUI

struct PayloadView: NSViewControllerRepresentable {
    
    typealias NSViewControllerType = PayloadViewController
    
    func makeNSViewController(context: Context) -> PayloadViewController {
        return PayloadViewController.makeViewController()
    }
    
    func updateNSViewController(_ nsViewController: PayloadViewController, context: Context) {
        nsViewController.textView.isAutomaticQuoteSubstitutionEnabled   = false
        nsViewController.textView.isAutomaticLinkDetectionEnabled       = false
        nsViewController.textView.isAutomaticSpellingCorrectionEnabled  = false
        nsViewController.textView.isAutomaticDataDetectionEnabled       = false
        nsViewController.textView.isAutomaticTextCompletionEnabled      = false
        nsViewController.textView.isAutomaticTextReplacementEnabled     = false
        nsViewController.textView.isAutomaticDashSubstitutionEnabled    = false
    }
}

extension Color {
    
    static let textColor = Color("text_color")
    
    static let textBackgroundColor = Color("text_input_background_color")
}

struct PayloadView_Previews: PreviewProvider {
    static var previews: some View {
        PayloadView()
    }
}
