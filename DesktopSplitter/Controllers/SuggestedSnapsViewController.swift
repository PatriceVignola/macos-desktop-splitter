//
//  SuggestedSnapsViewController.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 2/27/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

protocol SuggestedSnapsViewControllerDelegate : AnyObject {
    func viewControllerDidSnapWindow()
    func viewControllerDidCancel()
}

class SuggestedSnapsViewController : NSViewController {
    @IBOutlet weak private var suggestedSnapsView: SuggestedSnapsView?
    
    var delegate: SuggestedSnapsViewControllerDelegate?
    private var model = SuggestedSnapsModel()
    private var focusIndexPath = IndexPath(item: 0, section: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        suggestedSnapsView?.dataSource = self
        suggestedSnapsView?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let suggestedSnaps = DesktopWindow.getOpenedWindows().filter { !$0.isKey }
        model.add(newSuggestedSnaps: suggestedSnaps)
        
        // TODO: Test the accessibility "windowCreated" event to get a notification when new windows are opened
        // https://developer.apple.com/documentation/appkit/nsaccessibilitynotificationname/1528694-windowcreated
        
        // TODO: Test the accessibility "uiElementDestroyed" event to get a notification when windows are closed
        // https://developer.apple.com/documentation/appkit/nsaccessibilitynotificationname/1530862-uielementdestroyed
    }
    
    override func cancelOperation(_ sender: Any?) {
        // TODO: Re-make the previous window key
        delegate?.viewControllerDidCancel()
    }
    
    func setSuggestedSnapDirection(_ suggestedSnapDirection: SnapHelper.SnapDirection) {
        model.suggestedSnapDirection = suggestedSnapDirection
    }
}

extension SuggestedSnapsViewController : NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numSuggestedSnaps
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .suggestedSnapItem, for: indexPath) as! SuggestedSnapItem
        
        // indexPath[0] is the section index, so indexPath[1] is the item index
        item.suggestedSnap = model.getSuggestedSnap(at: indexPath[1])
        
        return item
    }
}

extension SuggestedSnapsViewController : SuggestedSnapsViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didFocusItem item: NSCollectionViewItem) {
        item.view.layer?.borderWidth = 4
        item.view.layer?.borderColor = CGColor.white
    }
    
    func collectionView(_ collectionView: NSCollectionView, didUnfocusItem item: NSCollectionViewItem) {
        item.view.layer?.borderWidth = 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths {
            // indexPath[0] is the section index, so indexPath[1] is the item index
            let suggestedSnap = model.getSuggestedSnap(at: indexPath[1])
            
            // TODO: Add support for multiple screens
            let snapRect = SnapHelper.getSnapRect(for: model.suggestedSnapDirection)
            suggestedSnap.set(frame: snapRect)
            suggestedSnap.bringToFront()
            
            // TODO: Remake the previous window key
            delegate?.viewControllerDidSnapWindow()
        }
    }
}


/*
extension SuggestedSnapsViewController : NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        // TODO: Try to find the optimal size for every single window by packing them optimally in a giant rectangle
        // with the dimensions of the screen, and then scaling them down to fit the screen size
        //https://stackoverflow.com/questions/1213394/what-algorithm-can-be-used-for-packing-rectangles-of-different-sizes-into-the-sm
    }
}*/

extension NSUserInterfaceItemIdentifier {
    static let suggestedSnapItem = NSUserInterfaceItemIdentifier("SuggestedSnapItem")
}

