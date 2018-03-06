//
//  SuggestedSnapsModel.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 3/1/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

class SuggestedSnapsModel {
    var suggestedSnapDirection = SnapHelper.SnapDirection.None
    private var suggestedSnaps = [DesktopWindow]()
    
    func add(newSuggestedSnap: DesktopWindow) {
        suggestedSnaps.append(newSuggestedSnap)
    }
    
    func add(newSuggestedSnaps: [DesktopWindow]) {
        suggestedSnaps += newSuggestedSnaps
    }
    
    func getSuggestedSnap(atIndex index:Int) -> DesktopWindow {
        return suggestedSnaps[index]
    }
    
    var numSuggestedSnaps: Int {
        return suggestedSnaps.count
    }
}
