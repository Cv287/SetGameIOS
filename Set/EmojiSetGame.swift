//
//  EmojiSetGame.swift
//  Set
//
//  Created by Олег Куколев on 15.07.2021.
//

import Foundation
import SwiftUI

class EmojiSetGame: ObservableObject {
    private static let emojis = ["🍙", "🍘", "🍥", "🥠", "🍡", "🍯", "🍺", "🥜", "🧂",
                                 "🥮", "🥡", "🧂", "🧋", "🍫", "🍨", "🎂", "🌰", "🍩",
                                 "🍪", "🧉", "🍭", "🥣", "🍴", "🧊", "🍾", "🍵", "☕️"]
    
    private static func initGame(numOfSetsOfCards: Int) -> SetGame<String> {
        SetGame<String>(numOfSetsOfCards, getCardContent: { index in
            emojis[index]
        })
    }
    
    init() {
        numOfSetsOfCards = EmojiSetGame.emojis.count
        model = EmojiSetGame.initGame(numOfSetsOfCards: numOfSetsOfCards)
    }
    
    typealias Card = SetGame<String>.Card
    
    private let numOfSetsOfCards: Int
    
    @Published private var model: SetGame<String>
    
    var cards: [Card] {
        model.cards
    }
    
    var isDeckEmpty: Bool {
        model.deck.isEmpty
    }
    
    // MARK: - Intents
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func dealThreeMoreCards() {
        model.dealThreeMoreCards()
    }
}
