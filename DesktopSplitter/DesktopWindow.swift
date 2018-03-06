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
    private let axWindow: AXUIElement
    
    fileprivate init(indexInApp: Int, processId: pid_t, title: String, screenshot: NSImage, icon: NSImage, isKey: Bool,
                     axWindow: AXUIElement) {
        self.indexInApp = indexInApp
        self.processId = processId
        self.title = title
        self.screenshot = screenshot
        self.icon = icon
        self.isKey = isKey
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
        // TODO: Make sure that it works as intended
        AXUIElementSetAttributeValue(axWindow, kAXMainAttribute as CFString, kCFBooleanTrue)
    }
    
    static func getOpenedWindows() -> [DesktopWindow] {
        var openedWindows = [DesktopWindow]()
        
        var cgProcessWindowsMap = [pid_t : [[String : AnyObject]]]()
        
        let listOptions = CGWindowListOption.excludeDesktopElements.union(CGWindowListOption.optionOnScreenOnly)
        let windows = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID) as! Array<Dictionary<String, AnyObject>>
        
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
            guard let cgWindows = cgProcessWindowsMap[app.processIdentifier] else { continue }
            
            var axWindowsOptional: AnyObject?
            let axApp = AXUIElementCreateApplication(app.processIdentifier)
            let axResult = AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &axWindowsOptional)
            
            guard axResult == .success else {
                if axResult == .apiDisabled {
                    // TODO: Find the best way to handle the error and retry the operation
                    NSLog("Enable the accessibility features for this app")
                }
                
                continue
            }
            
            guard let axWindows = axWindowsOptional as? [AXUIElement] else { continue }
            
            for i in 0...cgWindows.count - 1 {
                let axWindow = axWindows[i]
                let cgWindow = cgWindows[i]
                
                guard let boundsDict = cgWindow[kCGWindowBounds as String] as! CFDictionary? else { continue }
                
                let windowId = cgWindow[kCGWindowNumber as String] as! CGWindowID
                let windowOptions = CGWindowListOption.optionIncludingWindow
                let bounds = CGRect.init(dictionaryRepresentation: boundsDict)!
                let resolution = CGWindowImageOption.bestResolution
                let cgScreenshotOptional = CGWindowListCreateImage(bounds, windowOptions, windowId, resolution)
                
                guard let cgScreenshot = cgScreenshotOptional else { continue }
                guard let title = cgWindow[kCGWindowName as String] as? String else { continue }
                guard let icon = app.icon else { continue }
                
                let screenshotSize = NSSize(width: bounds.width, height: bounds.height)
                
                let openedWindow = DesktopWindow(
                    indexInApp: i,
                    processId: app.processIdentifier,
                    title: title,
                    screenshot: NSImage(cgImage: cgScreenshot, size: screenshotSize),
                    icon: icon,
                    isKey: isKey(axWindow: axWindow, from: app),
                    axWindow: axWindow
                )
                
                openedWindows.append(openedWindow)
            }
        }
        
        return openedWindows
    }
    
    private static func isKey(axWindow: AXUIElement, from app: NSRunningApplication) -> Bool {
        var isMainWindow: AnyObject?
        let axResult = AXUIElementCopyAttributeValue(axWindow, kAXMainAttribute as CFString, &isMainWindow)
        return axResult == .success && app.isActive && (isMainWindow as! CFBoolean) == kCFBooleanTrue
    }
}
