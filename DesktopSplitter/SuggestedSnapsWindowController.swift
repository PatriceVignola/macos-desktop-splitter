//
//  SuggestedSnapsWindowController.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 3/2/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

class SuggestedSnapsWindowController: NSWindowController, SuggestedSnapsViewControllerDelegate {
    private var suggestedSnapsViewController: SuggestedSnapsViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.isOpaque = false
        window?.backgroundColor = NSColor(calibratedWhite: 0.0, alpha: 0.7)
        
        suggestedSnapsViewController = contentViewController as? SuggestedSnapsViewController
    }
    
    func set(suggestedSnapDirection: SnapHelper.SnapDirection) {
        if suggestedSnapDirection != .FullScreen, let screen = NSScreen.main?.visibleFrame, let window = window {
            var snapshotRect = SnapHelper.getSnapRect(for: suggestedSnapDirection)
            
            // Convert from AX space to frame space
            let frameSpaceY = screen.height - snapshotRect.height - snapshotRect.origin.y
            snapshotRect.origin = NSPoint(x: snapshotRect.origin.x, y: frameSpaceY)
            window.setFrame(snapshotRect, display: true)
            suggestedSnapsViewController?.set(suggestedSnapDirection: suggestedSnapDirection)
            suggestedSnapsViewController?.delegate = self
            
            NSApplication.shared.runModal(for: window)
            
            window.close()
        }
        
        // TODO: Uncomment after test
        dismissController(self)
    }
    
    func viewControllerDidSnapWindow() {
        NSApplication.shared.stopModal()
    }
}
