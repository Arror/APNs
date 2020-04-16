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
        VStack(alignment: .leading, spacing: 4.0) {
            Text(self.title)
                .font(.caption)
            TextField("", text: self.value)
                .foregroundColor(Color.textColor)
                .background(Color.textBackgroundColor)
                .lineLimit(1)
                .textFieldStyle(SquareBorderTextFieldStyle())
        }
    }
}

struct TextInputGroup_Previews: PreviewProvider {
    
    @State static var text: String = ""
    
    static var previews: some View {
        TextInputGroup(title: "", value: $text)
    }
}
