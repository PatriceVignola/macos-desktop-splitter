//
//  SuggestedSnapItem.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 2/27/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

protocol SuggestedSnapDelegate: AnyObject {
    func didSelect(suggestedSnap: SuggestedSnap)
}

class SuggestedSnapItem: NSCollectionViewItem {
    var delegates: [SuggestedSnapDelegate] = []
    
    var suggestedSnap: SuggestedSnap? {
        didSet {
            guard isViewLoaded else { return }
            
            imageView?.image = suggestedSnap?.previewImage
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
            for delegate in delegates {
                delegate.didSelect(suggestedSnap: suggestedSnap!)
            }
        }
    }
}
