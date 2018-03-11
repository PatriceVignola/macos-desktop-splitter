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
    
    var snapDirection = SnapHelper.SnapDirection.None
    var modifiersPressed = false
    
    private let statusBarImageName = "Windows.png"
    
    private func handleKeyPress(_ event: NSEvent) {
        guard !event.isARepeat && modifiersPressed else { return }
        
        let keyCode = Int(event.charactersIgnoringModifiers!.unicodeScalars.first!.value)
        snapDirection = SnapHelper.getNextSnapDirection(fromPrevious: snapDirection, withArrowCode: keyCode)
        
        if snapDirection != .None {
            snapKeyWindow()
        }
    }
    
    private func handleModifierKeys(_ event: NSEvent) {
        // TODO: Let the user customize the modifier keys instead of hardcoding them
        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        case [.control, .option]:
            modifiersPressed = true
        default:
            modifiersPressed = false
            handleModifierKeysReleased()
        }
    }
    
    private func handleModifierKeysReleased() {
        if snapDirection != .None && snapDirection != .FullScreen {
            let suggestedSnapDirection = SnapHelper.getMirror(of: snapDirection)
            snapDirection = .None
            showSuggestedSnapsWindow(to: suggestedSnapDirection)
        }
    }
    
    private func snapKeyWindow() {
        guard let keyWindow = (DesktopWindow.getOpenedWindows().filter { $0.isKey }).first else { return }
        guard snapDirection != .None else { return }
        
        keyWindow.set(frame: SnapHelper.getSnapRect(for: snapDirection))
    }
    
    private func showSuggestedSnapsWindow(to suggestedSnapDirection: SnapHelper.SnapDirection) {
        let openedWindows = DesktopWindow.getOpenedWindows()
        
        if openedWindows.count > 1 {
            let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let controllerId = NSStoryboard.SceneIdentifier.init(rawValue: "SuggestedSnapsWindowController")
            let controller = sb.instantiateController(withIdentifier: controllerId) as! SuggestedSnapsWindowController
            
            // TODO: Pass the opened windows to the controller and don't fetch them again when the controller loads
            controller.setSuggestedSnapDirection(suggestedSnapDirection)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handleKeyPress)
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged, handler: handleModifierKeys)
        
        // Create a status bar with variable length
        statusItem = NSStatusBar.system.statusItem(withLength: -1)
        
        // Set the text that appears in the menu bar
        statusItem?.image = NSImage(named: NSImage.Name("Windows.png"))
        statusItem?.image?.size = NSSize(width: 20, height: 20)
        statusItem?.length = 30
        // image should be set as tempate so that it changes when the user sets the menu bar to a dark theme
        statusItem?.image?.isTemplate = true
        
        // Set the menu that should appear when the item is clicked
        statusItem?.menu = mainMenu
        
        // Set if the item should change color when clicked
        statusItem?.highlightMode = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
