//
//  AppDelegate.swift
//  macCANable
//
//  Created by Robert Huston on 3/6/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Do the things that need done before the application object is
        // initialized, e.g., before any of the the view controllers get loaded
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Do the things that need done after the application run loop has started,
        // but before the application receives its first event
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Do the things that need done before the application terminates
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
