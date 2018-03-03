//
//  SuggestedSnapsModel.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 3/1/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

class SuggestedSnapsModel {
    private var suggestedSnaps = [SuggestedSnap]()
    
    func add(suggestedSnap: SuggestedSnap) {
        suggestedSnaps.append(suggestedSnap)
    }
    
    func getSuggestedSnap(atIndex index:Int) -> SuggestedSnap {
        return suggestedSnaps[index]
    }
    
    var numSuggestedSnaps: Int {
        return suggestedSnaps.count
    }
}
