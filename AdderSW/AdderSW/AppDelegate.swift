//
//  AppDelegate.swift
//  AdderSW
//
//  Created by Tom Elliott on 12/15/15.
//  Copyright © 2015 Tom Elliott. All rights reserved.
//

import Cocoa
import Adder

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let x = f1(1)
        Swift.print("AD: \(x)"
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

