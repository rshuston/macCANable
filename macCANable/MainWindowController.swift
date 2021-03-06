//
//  MainWindowController.swift
//  macCANable
//
//  Created by Robert Huston on 3/6/21.
//

import Cocoa

class MainWindowController: NSWindowController {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
