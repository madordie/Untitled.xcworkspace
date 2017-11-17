//
//  AppDelegate.swift
//  macOS
//
//  Created by 孙继刚 on 2017/11/3.
//  Copyright © 2017年 madordie.github.io. All rights reserved.
//

import Cocoa

import SQLite3


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}


