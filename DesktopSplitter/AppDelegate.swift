//
//  AppDelegate.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 2/26/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak private var mainMenu: NSMenu!
    var statusItem: NSStatusItem?
    
    private func handleKeyPress(_ event: NSEvent) {
        guard event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.control) else { return }
        guard event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.option) else { return }
        guard !event.isARepeat else { return }
        guard let focusedProcessId = NSWorkspace.shared.frontmostApplication?.processIdentifier else { return }
        
        let pressedKey = Int(event.charactersIgnoringModifiers!.unicodeScalars.first!.value)
        
        var snapDirection: SnapHelper.SnapDirection?
        
        switch pressedKey {
        case NSRightArrowFunctionKey:
            snapDirection = .Right
        case NSLeftArrowFunctionKey:
            snapDirection = .Left
        case NSUpArrowFunctionKey:
            snapDirection = .Top
        case NSDownArrowFunctionKey:
            snapDirection = .Bottom
        default:
            NSLog("Unsupported key pressed")
        }
        
        if snapDirection != nil {
            snapProcessWindow(processId: focusedProcessId, snapDirection: snapDirection!)
        }
    }
    
    private func snapProcessWindow(processId: pid_t, snapDirection: SnapHelper.SnapDirection) {
        guard let keyWindow = (DesktopWindow.getOpenedWindows().filter { $0.isKey }).first else { return }
        
        keyWindow.set(frame: SnapHelper.getSnapRect(for: snapDirection))
        
        let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let controllerId = NSStoryboard.SceneIdentifier.init(rawValue: "SuggestedSnapsWindowController")
        let controller = sb.instantiateController(withIdentifier: controllerId) as! SuggestedSnapsWindowController
        
        controller.set(suggestedSnapDirection: SnapHelper.getMirror(of: snapDirection))
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handleKeyPress)
        
        // Make a status bar that has variable length (as opposed to being a standard square size)
        // -1 to indicate "variable length"
        self.statusItem = NSStatusBar.system.statusItem(withLength: -1)
        
        // Set the text that appears in the menu bar
        self.statusItem?.image = NSImage(named: NSImage.Name("Windows.png"))
        self.statusItem?.image?.size = NSSize(width: 20, height: 20)
        self.statusItem?.length = 30
        // image should be set as tempate so that it changes when the user sets the menu bar to a dark theme
        self.statusItem?.image?.isTemplate = true
        
        // Set the menu that should appear when the item is clicked
        self.statusItem!.menu = self.mainMenu
        
        // Set if the item should change color when clicked
        self.statusItem!.highlightMode = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
