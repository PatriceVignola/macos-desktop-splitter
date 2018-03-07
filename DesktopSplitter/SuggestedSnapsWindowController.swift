//
//  SuggestedSnapsWindowController.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 3/2/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

class SuggestedSnapsWindowController: NSWindowController {
    private var suggestedSnapsViewController: SuggestedSnapsViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.isOpaque = false
        window?.backgroundColor = NSColor(calibratedWhite: 0.0, alpha: 0.7)
        
        suggestedSnapsViewController = contentViewController as? SuggestedSnapsViewController
        
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    func setSuggestedSnapDirection(_ suggestedSnapDirection: SnapHelper.SnapDirection) {
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
        
        dismissController(self)
    }
}

extension SuggestedSnapsWindowController: NSWindowDelegate {
    func windowDidResignKey(_ notification: Notification) {
        NSApplication.shared.stopModal()
    }
}

extension SuggestedSnapsWindowController: SuggestedSnapsViewControllerDelegate {
    func viewControllerDidSnapWindow() {
        NSApplication.shared.stopModal()
    }
    
    func viewControllerDidCancel() {
        NSApplication.shared.stopModal()
    }
}
