//
//  SuggestedSnapsViewController.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 2/27/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

protocol SuggestedSnapsViewControllerDelegate: AnyObject {
    func viewControllerDidSnapWindow()
}

class SuggestedSnapsViewController: NSViewController, SuggestedSnapItemDelegate {
    @IBOutlet weak private var suggestedSnapsView: SuggestedSnapsView!
    
    var delegate: SuggestedSnapsViewControllerDelegate?
    private var model = SuggestedSnapsModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        suggestedSnapsView.dataSource = self
        generateSuggestedSnaps()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        suggestedSnapsView?.numItemsDidChange(numItems: model.numSuggestedSnaps)
    }
    
    func userDidSelect(suggestedSnap: DesktopWindow) {
        // TODO: Add support for multiple screens
        let snapRect = SnapHelper.getSnapRect(for: model.suggestedSnapDirection)
        suggestedSnap.set(frame: snapRect)
        suggestedSnap.bringToFront()
        
        delegate?.viewControllerDidSnapWindow()
    }
    
    func set(suggestedSnapDirection: SnapHelper.SnapDirection) {
        model.suggestedSnapDirection = suggestedSnapDirection
    }
    
    private func generateSuggestedSnaps() {
        let suggestedSnaps = DesktopWindow.getOpenedWindows().filter { !$0.isKey }
        model.add(newSuggestedSnaps: suggestedSnaps)
        suggestedSnapsView?.numItemsDidChange(numItems: model.numSuggestedSnaps)
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
        item.delegate = self
        
        return item
    }
}

extension NSUserInterfaceItemIdentifier {
    static let suggestedSnapItem = NSUserInterfaceItemIdentifier("SuggestedSnapItem")
}
