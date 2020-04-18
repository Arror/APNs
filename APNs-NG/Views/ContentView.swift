//
//  ContentView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/15.
//  Copyright © 2020 Arror. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @EnvironmentObject var appService: AppService
    
    private var cancellable: AnyCancellable? = nil
    
    var body: some View {
        VStack {
            
            CertificateView()
                .padding(.bottom, 10.0)
            
            if self.appService.apnsCertificate?.certificateType == .p8 {
                TitleValueView(
                    title: "组织",
                    value: self.$appService.teamID
                )
                TitleValueView(
                    title: "钥匙",
                    value: self.$appService.keyID
                )
            }
            TitleValueView(
                title: "套装",
                value: self.$appService.bundleID
            )
            TitleValueView(
                title: "令牌",
                value: self.$appService.token
            )
            
            Form {
                Picker("环境", selection: self.$appService.apnsService) {
                    ForEach(APNsService.allCases, id: \.self) { Text($0.name) }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("优先级", selection: self.$appService.priority) {
                    ForEach(1...10, id: \.self) { Text("\($0)") }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding([.top, .bottom], 10.0)
            
            GroupBox {
                PayloadView(text: self.$appService.payload)
                    .background(Color.textBackgroundColor)
                    .frame(maxWidth: .infinity, minHeight: 200.0, idealHeight: 200.0, maxHeight: 200.0)
            }
            .padding([.top, .bottom], 10.0)
            
            HStack {
                Spacer()
                Button(action: {
                    self.appService.pushSubject.send(())
                }, label: {
                    Text(self.appService.isInPushProcessing ? "正在发送" : "发送通知")
                })
                .disabled(self.appService.isInPushProcessing)
            }
        }
        .padding()
        .frame(width: 500.0)
    }
    
    @State var x: Bool = false
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
