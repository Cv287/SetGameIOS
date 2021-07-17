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
                                                symbols: count, textureState: texture)
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
    
    var isDeckEmpty: Bool {
        model.deck.isEmpty
    }
    
    var isEnded: Bool {
        model.cards.isEmpty
    }
    
    // MARK: - Intents
    func choose(_ card: Card) {
        model.choose(card, doCardsMatch: SetGameCardContent.doCardsMatch)
    }
    
    func dealThreeMoreCards() {
        model.dealThreeMoreCards()
    }
    
    func reset() {
        model = SymbolSetGame.initGame(numOfSetsOfCards)
    }
}

