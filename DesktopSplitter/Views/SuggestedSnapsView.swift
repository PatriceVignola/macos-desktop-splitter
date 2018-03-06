//
//  SuggestedSnapsView.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 3/1/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

class SuggestedSnapsView: NSCollectionView {
    @IBOutlet weak private var flowLayout: NSCollectionViewFlowLayout?
    
    private var trackingArea: NSTrackingArea?
    
    override func awakeFromNib() {
        guard let flowLayout = flowLayout else { return }
        
        flowLayout.sectionInset = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        flowLayout.minimumInteritemSpacing = 30
        flowLayout.minimumLineSpacing = 30
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        NSLog("KeyDown fired in SuggestedSnapsView")
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSLog("Mouse Entered in Collection")
    }
    
    func numItemsDidChange(numItems: Int) {
        guard let flowLayout = flowLayout else { return }
        
        var maxContentWidth = frame.width
        maxContentWidth -= flowLayout.sectionInset.left + flowLayout.sectionInset.right
        maxContentWidth += flowLayout.minimumInteritemSpacing
        
        var maxContentHeight = frame.height
        maxContentHeight -= flowLayout.sectionInset.top + flowLayout.sectionInset.bottom
        maxContentHeight += flowLayout.minimumLineSpacing
        
        var itemSize = getItemSize(forNumItems: numItems, forWidth: maxContentWidth, forHeight: maxContentHeight)
        itemSize.width -= flowLayout.minimumInteritemSpacing
        itemSize.height -= flowLayout.minimumLineSpacing
        
        flowLayout.itemSize = itemSize
    }
    
    // TODO: Delete once the optimal size for every item has been calculated in the controller
    private func getItemSize(forNumItems numItems: Int, forWidth width: CGFloat, forHeight height: CGFloat) -> NSSize {
        let n = Double(numItems)
        let x = Double(width)
        let y = Double(height)
        
        let px = ceil(sqrt(n*x/y))
        
        var sx: Double = 0
        var sy: Double = 0
        
        if floor(px * y / x) * px < n { // Doesn't fit
            sx = y / ceil(px * y / x)
        } else {
            sx = x / px
        }
        
        let py = ceil(sqrt(n*y/x))
        
        if floor(py * x / y) * py < n { // Doesn't fit
            sy = x / ceil(x * py / y)
        } else {
            sy = y / py
        }
        
        return NSSize(width: sx, height: sy)
    }
}
