//
//  SuggestedSnapsViewController.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 2/27/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

class SuggestedSnapsViewController: NSViewController, SuggestedSnapDelegate {
    func didSelect(suggestedSnap: SuggestedSnap) {
        // TODO: Instead, ask the AppDelegate or WindowController to close it. The ViewController shouldn't have to
        // know if the window is modal or not
        NSApplication.shared.stopModal()
    }
    
    @IBOutlet weak var collectionView: SuggestedSnapsView!
    
    private var model = SuggestedSnapsModel()
    var windowFrame = NSRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // TODO: Try moving to the AppDelegate
        NSApplication.shared.activate(ignoringOtherApps: true)
        generateSuggestedSnaps()
        collectionView?.numItemsDidChange(numItems: model.numSuggestedSnaps)
    }
    
    private func generateSuggestedSnaps() {
        var cgProcessWindowsMap = [pid_t : [[String : AnyObject]]]()
        
        let listOptions = CGWindowListOption.excludeDesktopElements.union(CGWindowListOption.optionOnScreenOnly)
        let windows = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID) as! Array<Dictionary<String, AnyObject>>
        
        for window in windows {
            let processId = window[kCGWindowOwnerPID as String] as! pid_t
            
            if cgProcessWindowsMap[processId] == nil {
                cgProcessWindowsMap[processId] = [[String : AnyObject]]()
            }
            
            cgProcessWindowsMap[processId]!.append(window)
        }
        
        // TODO: Make a separate class DesktopWindowHelper where we merge the info into a single easily accessible struct
        for app in NSWorkspace.shared.runningApplications {
            if app.activationPolicy == .regular {
                guard let cgWindows = cgProcessWindowsMap[app.processIdentifier] else { continue }
                
                var axWindows: AnyObject?
                let axApp = AXUIElementCreateApplication(app.processIdentifier)
                let axResult = AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &axWindows)
                
                if axResult == .success, let axWindows = (axWindows as? [AXUIElement]) {
                    for i in 0...cgWindows.count - 1 {
                        let axWindow = axWindows[i]
                        let cgWindow = cgWindows[i]
                        
                        // We don't want to add the window that we just snapped to the preview windows
                        if !isFocusedWindow(axWindow, fromApp: app) {
                            if let bounds = cgWindow[kCGWindowBounds as String] as! CFDictionary? {
                                let windowId = cgWindow[kCGWindowNumber as String] as! CGWindowID
                                let windowBounds = CGRect.init(dictionaryRepresentation: bounds)!
                                let windowOptions = CGWindowListOption.optionIncludingWindow
                                let cgPreviewImage = CGWindowListCreateImage(windowBounds, windowOptions, windowId, CGWindowImageOption.bestResolution)
                                let appIcon = app.icon
                                let windowName = cgWindow[kCGWindowName as String]
                                
                                if cgPreviewImage != nil {
                                    let size = NSSize(width: windowBounds.width, height: windowBounds.height)
                                    let previewImage = NSImage(cgImage: cgPreviewImage!, size: size)
                                    
                                    // TODO: Modify WindowPreview to contain an icon and a WindowName
                                    let suggestedSnap = SuggestedSnap(index: i, processId: app.processIdentifier, previewImage: previewImage)
                                    model.add(suggestedSnap: suggestedSnap)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        collectionView?.numItemsDidChange(numItems: model.numSuggestedSnaps)
    }
    
    // TODO: Move into the DesktopWindowHelper
    private func isFocusedWindow(_ axWindow: AXUIElement, fromApp app: NSRunningApplication) -> Bool {
        var isMainWindow: AnyObject?
        let axResult = AXUIElementCopyAttributeValue(axWindow, kAXMainAttribute as CFString, &isMainWindow)
        
        return axResult == .success && app.isActive && (isMainWindow as! CFBoolean) == kCFBooleanTrue
    }
}

extension SuggestedSnapsViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numSuggestedSnaps
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .suggestedSnapItem, for: indexPath) as! SuggestedSnapItem
        
        // indexPath[0] is the section index, so indexPath[1] is the item index
        item.suggestedSnap = model.getSuggestedSnap(atIndex: indexPath[1])
        item.delegates.append(self)
        item.delegates.append(NSApplication.shared.delegate as! SuggestedSnapDelegate)
        
        return item
    }
}

extension NSUserInterfaceItemIdentifier {
    static let suggestedSnapItem = NSUserInterfaceItemIdentifier("SuggestedSnapItem")
}
