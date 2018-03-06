//
//  SuggestedSnapsWindow.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 3/2/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

class SuggestedSnapsWindow: NSWindow {
    override func center() {
        // Do nothing; we don't want the window at the center of the screen when it's modal
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        NSLog("Mouse Entered in Window")
    }
}
