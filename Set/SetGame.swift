//
//  SetGame.swift
//  Set
//
//  Created by Олег Куколев on 15.07.2021.
//

import Foundation

struct SetGame<CardContent> where CardContent: Equatable {
    private(set) var deck: [Card]
    
    private(set) var cards: [Card]
    
    private var selected: [Card] {
        cards.filter { $0.isSelected }
    }
    
    private let countOfSetsOfCardsOnStart = 2
    
    init(_ numOfSetsOfCards: Int, getCardContent: (Int) -> CardContent) {
        cards = []
        let countOfCardsOnTable = min(countOfSetsOfCardsOnStart, numOfSetsOfCards)
        for index in 0..<countOfCardsOnTable {
            cards.append(Card(id: index * 3 + 0, content: getCardContent(index)))
            cards.append(Card(id: index * 3 + 1, content: getCardContent(index)))
            cards.append(Card(id: index * 3 + 2, content: getCardContent(index)))
        }
        cards.shuffle()
        
        deck = []
        if countOfCardsOnTable < numOfSetsOfCards {
            for index in countOfCardsOnTable..<numOfSetsOfCards {
                deck.append(Card(id: index * 3 + 0, content: getCardContent(index)))
                deck.append(Card(id: index * 3 + 1, content: getCardContent(index)))
                deck.append(Card(id: index * 3 + 2, content: getCardContent(index)))
            }
        }
    }
    
    mutating func choose(_ card: Card) {
        if selected.contains(card) {
            cards[index(of: card)!].isSelected = false
            return
        }
        
        if selected.count == 3 {
            if (selected.allSatisfy({ selected[0].content == $0.content })) {
                selected.forEach { cards.remove(at: index(of: $0)!) }
            } else {
                cards.indices.forEach { cards[$0].isSelected = false }
            }
        }
            
        if let indexOfselectedCard = index(of: card) {
            cards[indexOfselectedCard].isSelected.toggle()
            if cards.count == 3 && selected.count == 3 {
                cards.removeAll()
            }
        }
    }
    
    mutating func dealThreeMoreCards() {
        if !deck.isEmpty {
            for _ in 0..<3 {
                cards.insert(deck.popLast()!, at: Int.random(in: 0..<cards.count))
            }
        }
    }
    
    func index(of card: Card) -> Int? {
        cards.indices.firstIndex { cards[$0] == card }
    }
    
    struct Card: Identifiable, Equatable {
        let id: Int
        let content: CardContent
        var isSelected = false
    }

}
