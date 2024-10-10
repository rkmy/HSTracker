//
//  OdynPrimeDesignateEnchantment.swift
//  HSTracker
//
//  Created by Francisco Moraes on 9/15/24.
//  Copyright © 2024 Benjamin Michotte. All rights reserved.
//

import Foundation

class OdynPrimeDesignateEnchantment: EntityBasedEffect {
    override var cardId: String {
        return CardIds.NonCollectible.Warrior.OdynPrimeDesignate_ImpenetrableEnchantment
    }

    override var cardIdToShowInUI: String {
        return CardIds.Collectible.Warrior.OdynPrimeDesignate
    }

    required init(entityId: Int, isControlledByPlayer: Bool) {
        super.init(entityId: entityId, isControlledByPlayer: isControlledByPlayer)
    }

    override var effectDuration: EffectDuration {
        return .permanent
    }

    override var effectTag: EffectTag {
        return .heroModification
    }
}