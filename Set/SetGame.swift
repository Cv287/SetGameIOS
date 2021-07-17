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
    
    private var selected: [Card] {
        cards.filter { $0.isSelected }
    }
    
    private let countOfCardsOnStart = 21
    
    init(_ numOfCards: Int, getCardContent: (Int) -> CardContent) {
        deck = []
        for index in 0..<numOfCards {
            let card = Card(id: index, content: getCardContent(index))
            deck.append(card)
        }
        cards = []
        deal(countOfCardsOnStart)
    }
    
    mutating func choose(_ card: Card, doCardsMatch: (CardContent, CardContent, CardContent) -> Bool) {
        if selected.contains(card) {
            cards[index(of: card)!].isSelected = false
            return
        }

        var doSelectedCardsMatch: Bool {
            let contents = selected.map { $0.content }
            return doCardsMatch(contents[0], contents[1], contents[2])
        }

        if selected.count == 3 {
            if (doSelectedCardsMatch) {
                selected.forEach { cards.remove(at: index(of: $0)!) }
            } else {
                cards.indices.forEach { cards[$0].isSelected = false }
                dealThreeMoreCards()
            }
        }

        if let indexOfSelectedCard = index(of: card) {
            cards[indexOfSelectedCard].isSelected.toggle()
            if cards.count == 3 && selected.count == 3 {
                if doSelectedCardsMatch {
                    cards.removeAll()
                } else {
                    dealThreeMoreCards()
                }
            }
        }
    }
    
    mutating func dealThreeMoreCards() {
        deal(3)
    }
    
    private mutating func deal(_ cardsQuantity: Int) {
        if deck.count >= cardsQuantity {
            cards.append(contentsOf: deck.suffix(cardsQuantity))
            deck.removeLast(cardsQuantity)
        }
    }
    
    private func index(of card: Card) -> Int? {
        cards.indices.firstIndex { cards[$0].id == card.id }
    }
    
    struct Card: Identifiable, Equatable {
        let id: Int
        let content: CardContent
        var isSelected = false
        
        static func == (lhs: Card, rhs: Card) -> Bool {
            return lhs.id == rhs.id
        }
    }
}
