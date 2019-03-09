//
//  TokenListView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class TokenListView: NSView, NSTableViewDelegate, NSTableViewDataSource {
    
    private var server: APNs.Server = .sandbox
    
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    @IBOutlet weak var tableView: NSTableView!
    
    public var tokenInfo: ([String], APNs.Server) {
        if self.server == .sandbox {
            return (self.sandboxTokens, .sandbox)
        } else {
            return (self.productionTokens, .production)
        }
    }
    
    private var sandboxTokens: [String] = []
    private var productionTokens: [String] = []
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.segmentedControl.selectedSegment = 0
        self.updateServer()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.segmentedControl.action = #selector(segmentedControlValueChanged(_:))
        self.tableView.reloadData()
    }
    
    private func updateServer() {
        self.server = {
            if self.segmentedControl.selectedSegment == 0 {
                return .sandbox
            } else {
                return .production
            }
        }()
    }
    
    @objc private func segmentedControlValueChanged(_ sender: NSSegmentedControl) {
        self.tableView.scrollColumnToVisible(0)
        self.tableView.scrollRowToVisible(0)
        self.updateServer()
        self.tableView.reloadData()
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        switch self.server {
        case .sandbox:
            return self.sandboxTokens.count
        case .production:
            return self.productionTokens.count
        }
    }
    
    private enum Identifier: String {
        case token
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard
            let columnID = tableColumn?.identifier,
            let identifier = Identifier(rawValue: columnID.rawValue) else {
                return nil
        }
        let token: String = {
            switch self.server {
            case .sandbox:
                return self.sandboxTokens[row]
            case .production:
                return self.productionTokens[row]
            }
        }()
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(identifier.rawValue), owner: nil) as? NSTableCellView
        switch identifier {
        case .token:
            view?.textField?.stringValue = token
        }
        return view
    }
    
    @IBAction func addButtonTapped(_ sender: NSButton) {
        let vc = InputSheetViewController.makeViewController(title: "Token") { result in
            switch result {
            case .some(let value):
                switch self.server {
                case .sandbox:
                    if !self.sandboxTokens.contains(value) {
                        self.sandboxTokens.append(value)
                        self.tableView.reloadData()
                    }
                case .production:
                    if !self.productionTokens.contains(value) {
                        self.productionTokens.append(value)
                        self.tableView.reloadData()
                    }
                }
            case .none:
                break
            }
        }
        self.window?.contentViewController?.presentAsSheet(vc)
    }
    
    @IBAction func deleteButtonTapped(_ sender: NSButton) {
        let selectedRow = self.tableView.selectedRow
        guard
            selectedRow >= 0,
            let row = self.tableView.rowView(atRow: selectedRow, makeIfNecessary: false),
            let tokenRow = row.view(atColumn: 0) as? NSTableCellView,
            let token = tokenRow.textField?.stringValue else {
                return
        }
        
        switch self.server {
        case .sandbox:
            if let idx = self.sandboxTokens.firstIndex(of: token) {
                self.sandboxTokens.remove(at: idx)
            }
        case .production:
            if let idx = self.productionTokens.firstIndex(of: token) {
                self.productionTokens.remove(at: idx)
            }
        }
        self.tableView.reloadData()
    }
}
