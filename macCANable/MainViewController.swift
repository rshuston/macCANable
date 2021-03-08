//
//  MainViewController.swift
//  macCANable
//
//  Created by Robert Huston on 3/6/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet weak var o_OpenCloseButton: NSButton!
    @IBOutlet weak var o_AvailableSerialPorts: NSPopUpButton!
    @IBOutlet weak var o_BitRate: NSPopUpButton!

    @IBOutlet weak var o_SendButton: NSButton!
    
    @IBOutlet weak var o_ID: NSTextField!
    @IBOutlet weak var o_D0: NSTextField!
    @IBOutlet weak var o_D1: NSTextField!
    @IBOutlet weak var o_D2: NSTextField!
    @IBOutlet weak var o_D3: NSTextField!
    @IBOutlet weak var o_D4: NSTextField!
    @IBOutlet weak var o_D5: NSTextField!
    @IBOutlet weak var o_D6: NSTextField!
    @IBOutlet weak var o_D7: NSTextField!
    
    @IBOutlet weak var o_RxScrollView: NSScrollView!

    // This property is Cocoa-bound to setting the bit rate NSPopUpButton value
    @objc let availableBitRates = [
        "10 kbps",
        "20 kbps",
        "50 kbps",
        "100 kbps",
        "125 kbps",
        "250 kbps",
        "500 kbps",
        "750 kbps",
        "1 Mbps"
    ]
    
    // This property is Cocoa-bound to getting the bit rate NSPopUpButton value
    @objc dynamic var bitRate: String = "500 kbps" {
        didSet {
            print("new bit rate = \(bitRate)")
        }
    }
    
    // This property is Cocoa-bound to setting the DLC NSPopUpButton value
    @objc let availableDlcValues = [ "1", "2", "3", "4", "5", "6", "7", "8" ]
    
    // This property is Cocoa-bound to getting the DLC NSPopUpButton value
    @objc dynamic var dlcValue: String = "8" {
        didSet {
            print("new DLC value = \(dlcValue)")
            enableActiveDataByteFields()
        }
    }
    
    var logic: MainViewControllerLogic!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        o_ID.formatter = HexadecimalFormatter(3)
        
        o_D0.formatter = HexadecimalFormatter(2)
        o_D1.formatter = HexadecimalFormatter(2)
        o_D2.formatter = HexadecimalFormatter(2)
        o_D3.formatter = HexadecimalFormatter(2)
        o_D4.formatter = HexadecimalFormatter(2)
        o_D5.formatter = HexadecimalFormatter(2)
        o_D6.formatter = HexadecimalFormatter(2)
        o_D7.formatter = HexadecimalFormatter(2)
        
        o_ID.stringValue = "0"
        o_D0.stringValue = "0"
        o_D1.stringValue = "0"
        o_D2.stringValue = "0"
        o_D3.stringValue = "0"
        o_D4.stringValue = "0"
        o_D5.stringValue = "0"
        o_D6.stringValue = "0"
        o_D7.stringValue = "0"
        
        let textView = o_RxScrollView.contentView.documentView as! NSTextView
        textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        
        logic = MainViewControllerLogic(hostController: self)
        logic.viewDidLoad()
    }

    override func viewWillAppear() {
        o_OpenCloseButton.isEnabled = false
        
        populatePortMenu()
        
        logic.viewWillAppear()
        
        super.viewWillAppear()
    }
    
    override func viewWillDisappear() {
        logic.viewWillDisappear()
        
        super.viewWillDisappear()
    }
    
    override func viewDidDisappear() {
        logic.viewDidDisappear()
        
        super.viewDidDisappear()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func doSelectedSerialPort(_ sender: Any) {
        logic.handleNewPortSelection(selectedPortName: o_AvailableSerialPorts.titleOfSelectedItem!)
    }
    
    @IBAction func doOpenClose(_ sender: Any) {
        logic.handleOpenCloseCommand()
    }
    
    @IBAction func doSend(_ sender: Any) {
        logic.handleSendMessageCommand()
    }
    
    @IBAction func doClearRx(_ sender: Any) {
        clearRxMessages()
    }
    
    // MARK: - View Control State
    
    func setOpenCloseButtonEnableState(enabled: Bool) {
        o_OpenCloseButton?.isEnabled = enabled
    }
    
    func setControlStatesForOpenPortState(isOpen: Bool) {
        if isOpen {
            o_OpenCloseButton?.title = "Close"
            o_AvailableSerialPorts?.isEnabled = false
            o_BitRate?.isEnabled = false
            o_SendButton?.isEnabled = true
        } else {
            o_OpenCloseButton?.title = "Open"
            o_AvailableSerialPorts?.isEnabled = true
            o_BitRate?.isEnabled = true
            o_SendButton?.isEnabled = false
        }
    }
    
    // MARK: - Data Interaction
    
    func populatePortMenu() {
        o_AvailableSerialPorts.removeAllItems()
        
        o_AvailableSerialPorts.addItem(withTitle: "None")
        o_AvailableSerialPorts.menu!.addItem(NSMenuItem.separator())
        
        for availablePort in logic.getAvailablePortList() {
            o_AvailableSerialPorts.addItem(withTitle: availablePort.name)
            if availablePort.inUse {
                o_AvailableSerialPorts.item(at: o_AvailableSerialPorts.numberOfItems - 1)?.isEnabled = false
            }
        }
        
        let portName = logic.getActivePortName() ?? "None"
        let itemToSelect = o_AvailableSerialPorts.itemArray.first(where: {$0.title == portName})
        o_AvailableSerialPorts.select(itemToSelect)
        doSelectedSerialPort(self)
    }
    
    func enableActiveDataByteFields() {
        if let dlc = Int(dlcValue) {
            // Note: o_D0 is always enabled!
            o_D1.isEnabled = dlc > 1
            o_D2.isEnabled = dlc > 2
            o_D3.isEnabled = dlc > 3
            o_D4.isEnabled = dlc > 4
            o_D5.isEnabled = dlc > 5
            o_D6.isEnabled = dlc > 6
            o_D7.isEnabled = dlc > 7
        }
    }
    
    func getSelectedBitRate() -> String {
        return bitRate
    }
    
    func getTxID() -> String {
        return o_ID.stringValue
    }
    
    func getTxDLC() -> String {
        return dlcValue
    }
    
    func getTxDataBytes() -> [String] {
        var data: [String] = []
        data.append(o_D0.stringValue)
        data.append(o_D1.stringValue)
        data.append(o_D2.stringValue)
        data.append(o_D3.stringValue)
        data.append(o_D4.stringValue)
        data.append(o_D5.stringValue)
        data.append(o_D6.stringValue)
        data.append(o_D7.stringValue)
        return data
    }
    
    func postRxMessage(_ message: String) {
        let rxTextView = o_RxScrollView.documentView! as! NSTextView
        let newStringValue: String
        if rxTextView.string == "" {
            newStringValue = message
        } else {
            newStringValue = rxTextView.string + "\n" + message
        }
        rxTextView.string = newStringValue
        
        rxTextView.scrollToEndOfDocument(self)
    }
    
    func clearRxMessages() {
        let rxTextView = o_RxScrollView.documentView! as! NSTextView
        rxTextView.string = ""
    }

}

// MARK: - NSTextFieldDelegate

extension MainViewController: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            // We only need to check the ID field because we need to restrict ID values to 11 bits
            if textField == o_ID {
                let stringValue = textField.stringValue
                if let n = Int(stringValue, radix: 16) {
                    if n > 0x7FF {
                        let n11 = n & 0x7FF
                        let newValue = (textField.formatter?.string(for: n11))!
                        let alert = NSAlert()
                        alert.messageText = "Value is too large!"
                        alert.informativeText = "\"\(stringValue)\" exceeds 11 bits;  truncating to \"\(newValue).\"  Have a wonderful day."
                        alert.beginSheetModal(for: view.window!) { (response) in
                            textField.stringValue = newValue
                            textField.becomeFirstResponder()
                        }
                    }
                }
            }
        }
    }
    
}
