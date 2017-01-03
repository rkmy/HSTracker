//
//  FullScreenFxHandler.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 11/08/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import CleanroomLogger
import RealmSwift

struct FullScreenFxHandler {
    
    let BeginBlurRegex = "BeginEffect blur \\d => 1"
    
    private var lastQueueTime: Date = Date.distantPast
    
    mutating func handle(game: Game, logLine: LogLine) {
        guard let currentMode = game.currentMode else { return }

        let modes: [Mode] = [.tavern_brawl, .tournament, .draft, .friendly, .adventure]
        if logLine.line.match(BeginBlurRegex) && game.isInMenu
            && modes.contains(currentMode) {
            game.enqueueTime = logLine.time
            Log.info?.message("now in queue (\(logLine.time))")
            if Date().diffInSeconds(logLine.time) > 5
                || !game.isInMenu || logLine.time <= lastQueueTime {
                return
            }
            lastQueueTime = logLine.time

            guard Settings.instance.autoDeckDetection else { return }

            let selectedModes: [Mode] = [.tavern_brawl, .tournament,
                                         .friendly, .adventure]
            if selectedModes.contains(currentMode) {
                autoSelectDeckById(game: game, mode: currentMode)
            } else if currentMode == .draft {
                autoSelectArenaDeck(game: game)
            }
        }
    }

    private func autoSelectDeckById(game: Game, mode: Mode) {
        guard let mirror = Hearthstone.instance.mirror else { return }
        Log.info?.message("Trying to import deck from Hearthstone")

        guard let selectedDeckId = mirror.getSelectedDeck() as? Int64 else {
            Log.warning?.message("Can't get selected deck id")
            return
        }

        if selectedDeckId <= 0 {
            if mode != .tavern_brawl {
                game.set(activeDeck: nil)
                return
            }
        }

        guard let decks = mirror.getDecks() as? [MirrorDeck] else {
            Log.warning?.message("Can't get decks")
            return
        }
        guard let selectedDeck = decks.first({ $0.id as Int64 == selectedDeckId }) else {
            Log.warning?.message("No deck with id=\(selectedDeckId) found")
            return
        }
        Log.info?.message("Found selected deck : \(selectedDeck.name)")

        guard let realm = try? Realm() else { return }

        if let deck = realm.objects(Deck.self)
            .filter("hsDeckId = \(selectedDeckId)").first {
            Log.info?.message("Deck \(selectedDeck.name) exists, using it.")
            game.set(activeDeck: deck)
            return
        }

        guard let hero = Cards.hero(byId: selectedDeck.hero as String) else { return }
        let deck = Deck()
        deck.name = selectedDeck.name as String
        deck.playerClass = hero.playerClass
        deck.hsDeckId.value = selectedDeckId

        Log.info?.message("Deck \(selectedDeck.name) does not exists, creating it.")
        guard let cards = selectedDeck.cards as? [MirrorCard] else { return }
        do {
            try realm.write {
                realm.add(deck)
                for card in cards {
                    guard let c = Cards.by(cardId: card.cardId as String) else { continue }
                    c.count = card.count as Int
                    deck.add(card: c)
                }
                if deck.isValid() {
                    Log.info?.message("Saving and using deck : \(deck)")
                    game.set(activeDeck: deck)
                }
            }
        } catch {
            Log.error?.message("Can not import deck. Error : \(error)")
        }
    }

    private func autoSelectArenaDeck(game: Game) {
        guard let mirror = Hearthstone.instance.mirror else { return }
        Log.info?.message("Trying to import arena deck from Hearthstone")

        guard let hsDeck = mirror.getArenaDeck()?.deck else {
            Log.warning?.message("Can't get arena deck")
            return
        }

        guard let realm = try? Realm() else { return }
        let deckId = hsDeck.id as Int64

        if let deck = realm.objects(Deck.self)
            .filter("hsDeckId = \(deckId)").first {
            Log.info?.message("Arena deck \(deckId) exists, using it.")
            game.set(activeDeck: deck)
            return
        }

        Log.info?.message("Arena deck does not exists, creating it.")
        guard let cards = hsDeck.cards as? [MirrorCard] else { return }

        guard let hero = Cards.hero(byId: hsDeck.hero as String) else { return }
        let deck = Deck()
        deck.name = "Arena \(hero.name)"
        deck.playerClass = hero.playerClass
        deck.hsDeckId.value = deckId
        deck.isArena = true

        do {
            try realm.write {
                realm.add(deck)
                for card in cards {
                    guard let c = Cards.by(cardId: card.cardId as String) else { continue }
                    c.count = card.count as Int
                    deck.add(card: c)
                }
                if deck.isValid() {
                    Log.info?.message("Saving and using deck : \(deck)")
                    game.set(activeDeck: deck)
                }
            }
        } catch {
            Log.error?.message("Can not import deck. Error : \(error)")
        }
    }
}
