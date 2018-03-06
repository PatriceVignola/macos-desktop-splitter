//
//  SuggestedSnapItem.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 2/27/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

protocol SuggestedSnapItemDelegate: AnyObject {
    func userDidSelect(suggestedSnap: DesktopWindow)
}

class SuggestedSnapItem: NSCollectionViewItem {
    var delegate: SuggestedSnapItemDelegate?
    
    var suggestedSnap: DesktopWindow? {
        didSet {
            guard isViewLoaded else { return }
            
            imageView?.image = suggestedSnap?.screenshot
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSLog("Mouse Entered")
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        NSLog("Mouse Down")
        
        if suggestedSnap != nil {
            delegate?.userDidSelect(suggestedSnap: suggestedSnap!)
        }
    }
}
