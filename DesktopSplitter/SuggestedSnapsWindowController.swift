//
//  SuggestedSnapsWindowController.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 3/2/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

class SuggestedSnapsWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.isOpaque = false
        window?.backgroundColor = NSColor(calibratedWhite: 0.0, alpha: 0.7)
    }
}
