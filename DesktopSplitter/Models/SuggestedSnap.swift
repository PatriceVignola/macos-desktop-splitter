//
//  SuggestedSnap.swift
//  DesktopSplitter
//
//  Created by Patrice Vignola on 2/28/18.
//  Copyright © 2018 Patrice Vignola. All rights reserved.
//

import Cocoa

struct SuggestedSnap {
    var index: Int
    var processId: pid_t
    var previewImage: NSImage
    
    init(index: Int, processId: pid_t, previewImage: NSImage) {
        self.index = index
        self.processId = processId
        self.previewImage = previewImage
    }
}
