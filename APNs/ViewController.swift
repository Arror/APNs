//
//  ViewController.swift
//  APNs
//
//  Created by Arror on 2019/3/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let teamID = "A8XWAF2UFT"
    
    let keyID = "4K27WN82S4"
    
    let keyString = """
    -----BEGIN PRIVATE KEY-----
    MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQguHXpSjgmVG5Dlmlw
    GYPoQf9o25wOmV4qM3Bdgn9zyB2gCgYIKoZIzj0DAQehRANCAAR4i040hgidBWnS
    in+kEyXLYddBAn9cOOjOJaZVGwboVTDiYMfe8iLma38xgm7qJlr9yYut3QKEkSo1
    QJeMdFyY
    -----END PRIVATE KEY-----
    """
    
    var provider: APNs.Provider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        let dict: Any = {
//            var dict: [String: Any] = [:]
//            dict["aps"] = [
//                "alert": "Message..."
//            ]
//            return dict
//        }()
//
//        let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
//
//        let provider = try! APNs.makeProvider(based: .certificate(.p12(filePath: Bundle.main.path(forResource: "push", ofType: "p12")!, passphrase: "")))
//
//        provider.send(server: .development, tokens: ["f529c925a13a302d6082071588dbf7ededa28cf07afea8898fd2e56d0c77ac4c"], payload: data) { response in
//            switch response {
//            case .success:
//                print("OK")
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
        
        self.provider = nil
    }

    override var representedObject: Any? {
        didSet {
        }
    }
}
