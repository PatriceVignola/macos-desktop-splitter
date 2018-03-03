//
//  SuggestedSnapsWindow.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 3/2/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

class SuggestedSnapsWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        NSLog("KeyDown fired in SuggestedSnapsWindow")
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        NSLog("MouseDown fired in SuggestedSnapsWindow")
        NSLog("Current firstResponder: \(firstResponder)")
    }
    
    override func center() {
        // Do nothing; we don't want the window at the center of the screen when it's modal
    }
}
