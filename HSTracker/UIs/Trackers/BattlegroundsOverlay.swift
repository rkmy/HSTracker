//
//  CollectionFeedback.swift
//  HSTracker
//
//  Created by Martin BONNIN on 13/11/2019.
//  Copyright © 2019 HearthSim LLC. All rights reserved.
//

import Foundation
import TextAttributes

class BattlegroundsOverlay: OverWindowController {
    override var alwaysLocked: Bool { true }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window!.contentView = BattlegroundsOverlayView()
        //self.window!.backgroundColor = NSColor.brown
    }
}
