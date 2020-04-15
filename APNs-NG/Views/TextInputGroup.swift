//
//  TextInputGroup.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/16.
//  Copyright © 2020 Arror. All rights reserved.
//

import SwiftUI

struct TextInputGroup: View {
    
    let title: String
    let value: Binding<String>
    
    init(title: String, value: Binding<String>) {
        self.title = title
        self.value = value
    }
    
    var body: some View {
        GroupBox(label: Text(self.title)) {
            TextField("", text: self.value)
        }
    }
}

struct TextInputGroup_Previews: PreviewProvider {
    
    @State static var text: String = ""
    
    static var previews: some View {
        TextInputGroup(title: "", value: $text)
    }
}
