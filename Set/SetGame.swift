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
        
    private(set) var hasMismatchOccured = false
    
    var selected: [Card] {
        cards.filter { $0.isSelected }
    }
    
    private mutating func matchSelectedCards() {
        selected.forEach {
            let index = index(of: $0)!
            cards[index].isMatched = true
            cards[index].isSelected = false
        }
    }
    
    var isThereAtLeastOneMatchedCard: Bool {
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
    
    mutating func choose(_ card: Card, doCardsMatch: (CardContent, CardContent, CardContent) -> Bool) {
        hasMismatchOccured = false
        
        if selected.contains(card) {
            cards[index(of: card)!].isSelected = false
            return
        }
        
        var doSelectedCardsMatch: Bool {
            let contents = selected.map { $0.content }
            return doCardsMatch(contents[0], contents[1], contents[2])
        }

        if let indexOfSelectedCard = index(of: card) {
            cards[indexOfSelectedCard].isSelected.toggle()
            if cards.filter({ !$0.isMatched }).count == 3 && selected.count == 3 {
                if doSelectedCardsMatch || deck.isEmpty {
                    matchSelectedCards()
                } else {
                    dealThreeMoreCards()
                    hasMismatchOccured = true
                }
            }
        }
        
        if selected.count == 3 {
            if doSelectedCardsMatch || cards.count == 3 {
                matchSelectedCards()
            } else {
                cards.indices.forEach { cards[$0].isSelected = false }
                dealThreeMoreCards()
                hasMismatchOccured = true
            }
        }
    }
    
    mutating func moveAllMatchedCardsBack() {
        let matchedCards = cards.filter({ $0.isMatched })
        let unmatchedCards = cards.filter({ !matchedCards.contains($0) })
        cards = unmatchedCards + matchedCards
    }
    
    mutating func dealThreeMoreCards() {
        pushBackFromDeck(3)
    }
    
    mutating func replaceThreeMatchedCards() {
        replaceMatchedCardsWithCardsFromDeck(3)
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
        if deck.count >= cardsQuantity && isThereAtLeastOneMatchedCard {
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
        var isMatched = false
        
        static func == (lhs: Card, rhs: Card) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
