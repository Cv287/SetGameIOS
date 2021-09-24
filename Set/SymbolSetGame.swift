//
//  SymbolSetGame.swift
//  Set
//
//  Created by Олег Куколев on 15.07.2021.
//

import Foundation

class SymbolSetGame: ObservableObject {
    typealias CardSymbol = SetGameCardContent
    typealias SetGameModel = SetGame<CardSymbol>
    typealias Card = SetGame<CardSymbol>.Card
    
    private static func generateSymbolsForAllCards() -> [CardSymbol] {
        var symbols = [CardSymbol]()
        for color in 0..<3 {
            for shape in 0..<3 {
                for count in 0..<3 {
                    for texture in 0..<3 {
                        let symbol = CardSymbol(colorState: color, shapeState: shape,
                                                countState: count, textureState: texture)
                        symbols.append(symbol)
                    }
                }
            }
        }
        return symbols.shuffled()
    }
    
    private static let symbols: [CardSymbol] = generateSymbolsForAllCards()
    
    private static func initGame(_ numOfSetsOfCards: Int) -> SetGameModel {
        SetGameModel(numOfSetsOfCards, getCardContent: { index in
            symbols[index]
        })
    }
    
    init() {
        numOfSetsOfCards = SymbolSetGame.symbols.count
        model = SymbolSetGame.initGame(numOfSetsOfCards)
    }
    
    private let numOfSetsOfCards: Int
    
    @Published private var model: SetGameModel
    
    var cards: [Card] {
        model.cards
    }
    
    var deck: [Card] {
        model.deck
    }
    
    var hasMismatchOccured: Bool {
        model.hasMismatchOccured
    }
    
    var isDeckEmpty: Bool {
        model.deck.isEmpty
    }
    
    var isEnded: Bool {
        model.deck.isEmpty && model.cards.allSatisfy { $0.isMatched }
    }
    
    var selectedCards: [Card] {
        model.selected
    }
    
    private var selectedCardsAudit = [Card]()
    
    func lastThreeSelectedCards() -> [Card] {
        selectedCardsAudit.suffix(3)
    }
    
    // MARK: - Intents
    func choose(_ card: Card) {
        if !selectedCards.contains(card) {
            selectedCardsAudit.append(card)
        }
        model.choose(card, doCardsMatch: SetGameCardContent.doCardsMatch)
    }
    
    func dealThreeMoreCards() {
        model.dealThreeMoreCards()
    }
    
    func replaceThreeMatchedCards() {
        model.replaceThreeMatchedCards()
    }
    
    func moveDiscardedCardsAway() {
        model.moveAllMatchedCardsBack()
    }
    
    func reset() {
        model = SymbolSetGame.initGame(numOfSetsOfCards)
    }
}

