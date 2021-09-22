//
//  SetGame.swift
//  Set
//
//  Created by Олег Куколев on 15.07.2021.
//

import Foundation

struct SetGame<CardContent>  {
    private(set) var deck: [Card]
    
    private(set) var cards: [Card]
    
    var selected: [Card] {
        cards.filter { $0.isSelected }
    }
    
    var areThereThreeMatchedCards: Bool {
        cards.first(where: { $0.isMatched }) != nil
    }
    
    private let countOfCardsOnStart = 21
    
    init(_ numOfCards: Int, getCardContent: (Int) -> CardContent) {
        deck = []
        for index in 0..<numOfCards {
            let card = Card(id: index, content: getCardContent(index))
            deck.append(card)
        }
        cards = []
        pushBackFromDeck(countOfCardsOnStart)
    }
    
    private mutating func matchSelectedCards() {
        selected.forEach {
            let index = index(of: $0)!
            cards[index].isMatched = true
            cards[index].isSelected = false
        }
    }
    
    mutating func choose(_ card: Card, doCardsMatch: (CardContent, CardContent, CardContent) -> Bool) {
        var doSelectedCardsMatch: Bool {
            let contents = selected.map { $0.content }
            return doCardsMatch(contents[0], contents[1], contents[2])
        }

        if selected.count == 3 {
            if (doSelectedCardsMatch || cards.count == 3) {
                matchSelectedCards()
            } else {
                cards.indices.forEach { cards[$0].isSelected = false }
                dealThreeMoreCards()
            }
        }

        if let indexOfSelectedCard = index(of: card) {
            cards[indexOfSelectedCard].isSelected.toggle()
            if cards.filter({ !$0.isMatched }).count == 3 && selected.count == 3 {
                if doSelectedCardsMatch || deck.isEmpty {
                    matchSelectedCards()
                } else {
                    dealThreeMoreCards()
                }
            }
        }
    }
    
    mutating func dealOrReplaceMatched(_ cardsQuantity: Int) {
        for _ in 0..<cardsQuantity {
            if areThereThreeMatchedCards {
                replaceMatchedCardsWithCardsFromDeck(1)
            } else {
                pushBackFromDeck(1)
            }
        }
    }
    
    mutating func dealThreeMoreCards() {
        pushBackFromDeck(3)
    }
    
    private mutating func pushBackFromDeck(_ cardsQuantity: Int) {
        if deck.count >= cardsQuantity {
            for _ in 0..<cardsQuantity {
                deck[deck.count - 1].isMatched = false
                cards.append(deck.last!)
                deck.removeLast()
            }
        }
    }
    
    private mutating func replaceMatchedCardsWithCardsFromDeck(_ cardsQuantity: Int) {
        if deck.count >= cardsQuantity && areThereThreeMatchedCards {
            for _ in 0..<cardsQuantity {
                let matchedCardIndex = cards.firstIndex { $0.isMatched == true }!
                cards.append(cards[matchedCardIndex])
                let cardFromDeck = deck.removeLast()
                cards[matchedCardIndex] = cardFromDeck
                cards[matchedCardIndex].isMatched = false
            }
        }
    }
    
    private func index(of card: Card) -> Int? {
        cards.indices.firstIndex { cards[$0].id == card.id }
    }
    
    struct Card: Identifiable, Equatable, Hashable {
        let id: Int
        let content: CardContent
        var isSelected = false
        var isMatched = true
        
        static func == (lhs: Card, rhs: Card) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
