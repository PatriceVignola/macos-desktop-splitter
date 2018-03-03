//
//  AppDelegate.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 2/26/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SuggestedSnapDelegate {
    func didSelect(suggestedSnap: SuggestedSnap) {
        // TODO: Add support for multiple screens
        let snapRect = getSnapRect(forSnapDirection: getMirrorSnapDirection(latestSnapPosition))
        
        var snapOrigin = snapRect.origin
        var snapSize = snapRect.size
        
        let axSnapOrigin = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &snapOrigin)!
        let axSnapSize = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &snapSize)!
        
        var axWindows: AnyObject?
        let axApp = AXUIElementCreateApplication(suggestedSnap.processId)
        let result = AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &axWindows)
        
        if result == .success {
            if let axWindows = axWindows as? [AXUIElement] {
                let axWindow = axWindows[suggestedSnap.index]
                AXUIElementSetAttributeValue(axWindow, kAXPositionAttribute as CFString, axSnapOrigin)
                AXUIElementSetAttributeValue(axWindow, kAXSizeAttribute as CFString, axSnapSize)
                AXUIElementSetAttributeValue(axWindow, kAXMainAttribute as CFString, kCFBooleanTrue)
            }
        }
    }
    
    @IBOutlet weak var mainMenu: NSMenu!
    var statusItem: NSStatusItem?
    
    private enum SnapDirection {
        case None, FullScreen, Left, Right, Top, Bottom, TopLeft, TopRight, BottomLeft, BottomRight
    }
   
    private var latestSnapPosition = SnapDirection.None
    
    private func handleKeyPress(_ event: NSEvent) {
        guard event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.control) else { return }
        guard event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.option) else { return }
        guard !event.isARepeat else { return }
        guard let focusedProcessId = NSWorkspace.shared.frontmostApplication?.processIdentifier else { return }
        
        let pressedKey = Int(event.charactersIgnoringModifiers!.unicodeScalars.first!.value)
        
        var snapDirection: SnapDirection?
        
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
    
    private func getSnapRect(forSnapDirection snapDirection:SnapDirection) -> NSRect {
        // TODO: Add support for multiple screens
        // TODO: Maybe return nil instead of default NSRect()
        guard let screen = NSScreen.main?.visibleFrame else { return NSRect() }
        
        var snapRect = NSRect()
        
        switch snapDirection {
        case .FullScreen:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width, height: screen.size.height)
        case .Left:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height)
        case .Right:
            snapRect.origin = NSPoint(x: screen.minX + screen.size.width / 2, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height)
        case .Top:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width, height: screen.size.height / 2)
        case .Bottom:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY + screen.size.height / 2)
            snapRect.size = NSSize(width: screen.size.width, height: screen.size.height / 2)
        case .TopLeft:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height / 2)
        case .TopRight:
            snapRect.origin = NSPoint(x: screen.minX + screen.size.width / 2, y: screen.minY)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height / 2)
        case .BottomLeft:
            snapRect.origin = NSPoint(x: screen.minX, y: screen.minY + screen.size.height / 2)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height / 2)
        case .BottomRight:
            snapRect.origin = NSPoint(x: screen.minX + screen.size.width / 2, y: screen.minY + screen.size.height / 2)
            snapRect.size = NSSize(width: screen.size.width / 2, height: screen.size.height / 2)
        default:
            break
        }
        
        return snapRect
    }
    
    private func getMirrorSnapDirection(_ snapDirection: SnapDirection) -> SnapDirection {
        switch snapDirection {
        case .None:
            return .None
        case .FullScreen:
            return .None
        case .Left:
            return .Right
        case .Right:
            return .Left
        case .Top:
            return .Bottom
        case .Bottom:
            return .Top
        case .TopLeft:
            return .BottomLeft
        case .TopRight:
            return .BottomRight
        case .BottomLeft:
            return .TopLeft
        case .BottomRight:
            return .TopRight
        }
    }
    
    private func snapProcessWindow(processId: pid_t, snapDirection: SnapDirection) {
        guard let screen = NSScreen.main?.visibleFrame else { return }
        
        latestSnapPosition = snapDirection
        
        let snapRect = getSnapRect(forSnapDirection: snapDirection)
        
        var snapOrigin = snapRect.origin
        var snapSize = snapRect.size
        
        let axSnapOrigin = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &snapOrigin)!
        let axSnapSize = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &snapSize)!
        
        var windows: AnyObject?
        let windowAppRef = AXUIElementCreateApplication(processId)
        
        var axResult = AXUIElementCopyAttributeValue(windowAppRef, kAXWindowsAttribute as CFString, &windows)
        
        switch axResult {
        case .success:
            // TODO: Put in separate function
            
            if let windows = (windows as? [AXUIElement]) {
                for window in windows {
                    var isFocusedWindow: AnyObject?
                    axResult = AXUIElementCopyAttributeValue(window, kAXMainAttribute as CFString, &isFocusedWindow)
                    
                    if axResult == .success && (isFocusedWindow as! CFBoolean) == kCFBooleanTrue {
                        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, axSnapOrigin)
                        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, axSnapSize)
                        break
                    }
                }
            }
        case .apiDisabled:
            NSLog("Enable the accessibility features for this app")
        // TODO: Add a user-friendly message and a refresh or retry button
        default:
            NSLog("Can't get the accessibility attributes for the window")
        }
        
        // TODO: Refactor in another method and call it in the .success most nested block
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.init(rawValue: "SuggestedSnapsWindowController")) as! NSWindowController
        
        if snapDirection != .FullScreen, let snapshotWindow = controller.window {
            var snapshotRect = getSnapRect(forSnapDirection: getMirrorSnapDirection(snapDirection))
            
            // Convert from AX space to frame space
            let frameSpaceY = screen.height - snapshotRect.height - snapshotRect.origin.y
            snapshotRect.origin = NSPoint(x: snapshotRect.origin.x, y: frameSpaceY)
            
            snapshotWindow.setFrame(snapshotRect, display: true)
            NSApplication.shared.runModal(for: snapshotWindow)
            snapshotWindow.close()
        }
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
