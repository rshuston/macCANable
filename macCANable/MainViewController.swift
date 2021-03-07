//
//  MainViewController.swift
//  macCANable
//
//  Created by Robert Huston on 3/6/21.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet weak var o_AvailableSerialPorts: NSPopUpButton!
    @IBOutlet weak var o_OpenCloseButton: NSButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logic = MainViewControllerLogic(hostViewController: self)
        logic.viewDidLoad()
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
