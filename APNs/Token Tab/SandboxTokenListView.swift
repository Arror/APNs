//
//  SandboxTokenListView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class SandboxTokenListView: TokenListView, NSTableViewDelegate, NSTableViewDataSource {
    
    public override var controller: TokenListController {
        return self._controller
    }
    
    private let _controller = TokenListController(server: .sandbox)
    
    @IBOutlet weak var tableView: NSTableView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.controller.tokens.count
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("reuse"), owner: nil) as? NSTableCellView
        view?.textField?.stringValue = self.controller.tokens[row]
        return view
    }
    
    @IBAction func addButtonTapped(_ sender: NSButton) {
        self.addToken {
            self.tableView.reloadData()
        }
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
        self.delete(token: token)
        self.tableView.reloadData()
    }
}
