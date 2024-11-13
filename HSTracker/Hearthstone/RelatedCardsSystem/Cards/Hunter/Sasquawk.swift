//
//  Sasquawk.swift
//  HSTracker
//
//  Created by Francisco Moraes on 11/7/24.
//  Copyright © 2024 Benjamin Michotte. All rights reserved.
//

import Foundation

class Sasquawk: ICardWithRelatedCards {
    
    func getCardId() -> String {
        return CardIds.Collectible.Hunter.Sasquawk
    }

    func shouldShowForOpponent(opponent: Player) -> Bool {
        guard let card = Cards.by(cardId: getCardId()) else {
            return false
        }
        return CardUtils.mayCardBeRelevant(card: card, format: AppDelegate.instance().coreManager.game.currentFormat, playerClass: opponent.originalClass) && getRelatedCards(player: opponent).count > 0
    }

    func getRelatedCards(player: Player) -> [Card?] {
        return player.cardsPlayedLastTurn
            .compactMap { CardUtils.getProcessedCardFromEntity($0, player) }
            .sorted { $0.cost > $1.cost }
    }

    required init() {
    }
}