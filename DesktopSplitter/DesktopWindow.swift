//
//  DesktopWindow
//  DesktopSplitter
//
//  Created by Patrice Vignola on 3/3/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

class DesktopWindow {
    let indexInApp: Int
    let processId: pid_t
    let title: String
    let screenshot, icon: NSImage
    let isKey: Bool
    private var isMinimized: Bool
    private let axWindow: AXUIElement
    
    fileprivate init(indexInApp: Int, processId: pid_t, title: String, screenshot: NSImage, icon: NSImage, isKey: Bool,
                     isMinimized: Bool, axWindow: AXUIElement) {
        self.indexInApp = indexInApp
        self.processId = processId
        self.title = title
        self.screenshot = screenshot
        self.icon = icon
        self.isKey = isKey
        self.isMinimized = isMinimized
        self.axWindow = axWindow
    }
    
    func set(frame: NSRect) {
        set(origin: frame.origin)
        set(size: frame.size)
    }
    
    func set(origin: NSPoint) {
        var originSource = origin
        let axOrigin = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &originSource)!
        AXUIElementSetAttributeValue(axWindow, kAXPositionAttribute as CFString, axOrigin)
    }
    
    func set(size: NSSize) {
        var sizeSource = size
        let axSize = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &sizeSource)!
        AXUIElementSetAttributeValue(axWindow, kAXSizeAttribute as CFString, axSize)
    }
    
    func bringToFront() {
        AXUIElementSetAttributeValue(axWindow, kAXMainAttribute as CFString, kCFBooleanTrue)
        set(isMinimized: false)
    }
    
    func set(isMinimized: Bool) {
        guard self.isMinimized != isMinimized else { return }
        
        let cfMinimized: CFBoolean = isMinimized ? kCFBooleanTrue : kCFBooleanFalse
        AXUIElementSetAttributeValue(axWindow, kAXMinimizedAttribute as CFString, cfMinimized)
        self.isMinimized = isMinimized
    }
    
    static func getOpenedWindows() -> [DesktopWindow] {
        var openedWindows = [DesktopWindow]()
        
        var cgProcessWindowsMap = [pid_t : [[String : AnyObject]]]()
        
        let listOptions = CGWindowListOption.excludeDesktopElements
        let windows = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID) as! [[String : AnyObject]]
        
        // Since AXUIElement windows and CGWindows are not linked by a common ID, we need to link them manually
        for window in windows {
            let processId = window[kCGWindowOwnerPID as String] as! pid_t
            
            if cgProcessWindowsMap[processId] == nil {
                cgProcessWindowsMap[processId] = [[String : AnyObject]]()
            }
            
            cgProcessWindowsMap[processId]!.append(window)
        }
        
        for app in NSWorkspace.shared.runningApplications {
            guard app.activationPolicy == .regular else { continue }
            guard var cgWindows = cgProcessWindowsMap[app.processIdentifier] else { continue }
            
            let axWindows = getAxWindows(for: app.processIdentifier)
        
            for axWindow in axWindows {
                guard let title = getTitle(from: axWindow) else { continue }

                for i in 0...cgWindows.count - 1 {
                    let cgWindow = cgWindows[i]
                    
                    // We make sure that cgWindow's title is the same as axWindow's
                    guard title == cgWindow[kCGWindowName as String] as? String else { continue }
                    
                    // TODO: Maybe make the icon optional?
                    guard let icon = app.icon else { continue }
                    
                    let windowId = cgWindow[kCGWindowNumber as String] as! CGWindowID
                    var isMinimized = true
                    
                    if let isOnScreen = cgWindow[kCGWindowIsOnscreen as String] {
                        isMinimized = !(isOnScreen as! Bool)
                    }
                    
                    let windowOptions = CGWindowListOption.optionIncludingWindow
                    let options = CGWindowImageOption.bestResolution.union(.boundsIgnoreFraming)
                    let cgScreenshotOptional = CGWindowListCreateImage(CGRect.null, windowOptions, windowId, options)
                    
                    // TODO: Maybe make the screenshot optional?
                    guard let cgScreenshot = cgScreenshotOptional else { continue }
                    
                    let screenshotSize = NSSize(width: cgScreenshot.width, height: cgScreenshot.height)
                    
                    let openedWindow = DesktopWindow(
                        indexInApp: i,
                        processId: app.processIdentifier,
                        title: title,
                        screenshot: NSImage(cgImage: cgScreenshot, size: screenshotSize),
                        icon: icon,
                        isKey: isKey(axWindow: axWindow, from: app),
                        isMinimized: isMinimized,
                        axWindow: axWindow
                    )
                     
                    openedWindows.append(openedWindow)
                    
                    cgWindows.remove(at: i)
                    
                    break
                }
            }
        }
        
        return openedWindows
    }
    
    private static func isKey(axWindow: AXUIElement, from app: NSRunningApplication) -> Bool {
        var isMainWindow: AnyObject?
        let axResult = AXUIElementCopyAttributeValue(axWindow, kAXMainAttribute as CFString, &isMainWindow)
        return axResult == .success && app.isActive && (isMainWindow as! CFBoolean) == kCFBooleanTrue
    }
    
    private static func getAxWindows(for processId: pid_t) -> [AXUIElement] {
        var axWindowsOptional: AnyObject?
        let axApp = AXUIElementCreateApplication(processId)
        let axResult = AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &axWindowsOptional)
        
        if axResult == .success, let axWindows = axWindowsOptional as? [AXUIElement] {
            return axWindows
        }
        
        if axResult == .apiDisabled {
            // TODO: Find the best way to handle the error and retry the operation
            NSLog("Enable the accessibility features for this app")
        }
        
        return [AXUIElement]()
    }
    
    private static func getTitle(from axWindow: AXUIElement) -> String? {
        var axTitle: AnyObject?
        let axResult = AXUIElementCopyAttributeValue(axWindow, kAXTitleAttribute as CFString, &axTitle)
        
        if axResult == .success, let axTitleString = axTitle as? String {
            return axTitleString
        }
        
        return nil
    }
}
