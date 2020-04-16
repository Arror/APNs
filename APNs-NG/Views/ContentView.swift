//
//  ContentView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/15.
//  Copyright © 2020 Arror. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var text: String = ""
    @State var environment: Environment = .sandbox
    @State var priority: Int = 5
    
    var body: some View {
        VStack {
            
            GroupBox {
                Text("")
                    .frame(maxWidth: .infinity, minHeight: 60.0, idealHeight: 60.0, maxHeight: 60.0)
                    .background(Color.textBackgroundColor)
            }
            .padding(.bottom, 10.0)
            
            TextInputGroup(title: "Team ID", value: $text)
            TextInputGroup(title: "Key ID", value: $text)
            TextInputGroup(title: "Bundle ID", value: $text)
            TextInputGroup(title: "Token", value: $text)
            
            Form {
                Picker("Environment", selection: $environment) {
                    ForEach(Environment.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(SegmentedPickerStyle())
                Picker("Priority", selection: $priority) {
                    ForEach(1...10, id: \.self) { Text("\($0)") }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding([.top, .bottom], 10.0)
            
            GroupBox {
                PayloadView()
                    .background(Color.textBackgroundColor)
                    .frame(maxWidth: .infinity, minHeight: 200.0, idealHeight: 200.0, maxHeight: 200.0)
            }
            .padding([.top, .bottom], 10.0)
            
            HStack {
                Spacer()
                Button(action: {
                    
                }, label: {
                    Text("Send Push Notification")
                })
            }
        }
        .padding()
        .frame(width: 500.0)
    }
}

enum Environment: String, CaseIterable {
    case sandbox = "Sandbox"
    case product = "Product"
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
