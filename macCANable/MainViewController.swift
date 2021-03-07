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
    @objc let availableDlcValues = [ 1, 2, 3, 4, 5, 6, 7 ]
    
    // This property is Cocoa-bound to getting the DLC NSPopUpButton value
    @objc dynamic var dlcValue: Int = 8 {
        didSet {
            print("new DLC value = \(dlcValue)")
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
        
        logic = MainViewControllerLogic(hostViewController: self)
        logic.viewDidLoad()
        
        // Temporary
        let rxTextView = o_RxScrollView.documentView! as! NSTextView
        rxTextView.string = "You are likely to be eaten by a grue."

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func doSelectedSerialPort(_ sender: Any) {
        print("new port value = \(o_AvailableSerialPorts.titleOfSelectedItem!)")
    }
    
    @IBAction func doOpenClose(_ sender: Any) {
        if (o_OpenCloseButton.title == "Open") {
            print("port opened")
            o_OpenCloseButton.title = "Close"
        } else {
            print("port closed")
            o_OpenCloseButton.title = "Open"
        }
    }
    
    @IBAction func doSend(_ sender: Any) {
        print("message sent")
    }
    
    @IBAction func doClearRx(_ sender: Any) {
        print("rx buffer cleared")
    }

}


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
                        alert.messageText = "Value too large!"
                        alert.informativeText = "\"\(stringValue)\" exceeds 11 bits. The value will be truncated to \"\(newValue).\" Have a great day."
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
