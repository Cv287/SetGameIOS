//
//  ContentView.swift
//  Set
//
//  Created by Олег Куколев on 15.07.2021.
//

import SwiftUI

struct SymbolSetGameView: View {
    @ObservedObject var game = SymbolSetGame()
    
    @Namespace private var dealNamespace
    
    @State private var dealt = Set<Int>()
    
    private var discarded: [SymbolSetGame.Card] {
        game.cards.filter(isDiscarded).reversed()
    }
    
    private func isDealt(_ card: SymbolSetGame.Card) -> Bool {
        dealt.contains(card.id)
    }
    
    private func isDiscarded(_ card: SymbolSetGame.Card) -> Bool {
        card.isMatched
    }
    
    private func deal(_ card: SymbolSetGame.Card) {
        dealt.insert(card.id)
    }
    
    private func dealUndealtCards() {
        var counter = 0
        for card in game.cards {
            if !isDealt(card) && !isDiscarded(card) {
                withAnimation(dealAnimation(for: game.cards[counter])) {
                    deal(card)
                    counter += 1
                }
            }
        }
    }
    
    private func dealAnimation(for card: SymbolSetGame.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(of: card) {
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    var body: some View {
        VStack {
            if !game.isEnded {
                gameInProgressBody
            } else {
                endGameBody
            }
        }
    }
    
    private var gameInProgressBody: some View {
        VStack {
            gameBody
            HStack {
                deckPile
                Spacer()
                hint
                Spacer()
                discardPile
            }
            .padding()
        }
    }
    
    private var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: DrawingConstants.vGridAspectRatio, content: { card in
            if isDealt(card) && !isDiscarded(card) {
                CardView(card: card, isFaceUp: true, isHinted: hinted.contains(card.id)).onTapGesture {
                    withAnimation {
                        game.choose(card)
                        dealUndealtCards()
                    }
                }
                .padding(DrawingConstants.padding)
                .matchedGeometryEffect(id: card.id, in: dealNamespace)
            }
        })
        .padding(.horizontal)
    }
    
    private var endGameBody: some View {
        VStack {
            Text("You won!").font(.largeTitle)
            restartButton.padding()
        }
    }
    
    private var restartButton: some View {
        Button("Try again") {
            game.reset()
        }
    }
    
    private func zIndex(of card: SymbolSetGame.Card) -> Double {
        -Double(game.cards.firstIndex(of: card) ?? 0)
    }
    
    private var deckPile: some View {
        ZStack {
            ForEach(game.cards.filter{ !isDealt($0) }) { card in
                CardView(card: card, isFaceUp: false)
                    .matchedGeometryEffect(id: card.id, in: dealNamespace)
                    .zIndex(zIndex(of: card))
            }
            ForEach(game.deck) { card in
                CardView(card: card, isFaceUp: false)
                    .matchedGeometryEffect(id: card.id, in: dealNamespace)
                    .zIndex(zIndex(of: card))
            }
            Text("\(game.deck.count + game.cards.filter({ !isDealt($0) }).count)")
                .font(.largeTitle).zIndex(100).foregroundColor(.white)
        }
        .frame(width: DrawingConstants.undealtWidth, height: DrawingConstants.undealtHeight)
        .onTapGesture {
            if (dealt.isEmpty) {
                for card in game.cards {
                    withAnimation(dealAnimation(for: card)) {
                        deal(card)
                    }
                }
                return
            }
            
            game.dealThreeMoreCards()
            dealUndealtCards()
        }
    }
    
    private func moveDiscarded(card: SymbolSetGame.Card) -> CGAffineTransform {
        let index = discarded.firstIndex(of: card)!
        return index < CardConstants.discardedRotatedQuantity ?
            .init(translationX: CardConstants.discardedOffsetLeft + CGFloat(index) * CardConstants.discardedOffsetRight, y: 0.0) :
            .init()
    }
    
    private func rotation(of card: SymbolSetGame.Card) -> Double {
        let index = discarded.firstIndex(of: card)!
        return index < CardConstants.discardedRotatedQuantity ?
            Double(index) * CardConstants.discardedRotation : 0
    }
    
    @ViewBuilder
    private var discardPile: some View {
        ZStack {
            ForEach(discarded) { card in
                CardView(card: card, isFaceUp: true)
                    .matchedGeometryEffect(id: card.id, in: dealNamespace)
                    .rotationEffect(Angle.degrees(rotation(of: card)))
                    .transformEffect(moveDiscarded(card: card))
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: DrawingConstants.undealtWidth, height: DrawingConstants.undealtHeight)
    }
    
    @State private var hinted = Set<Int>()
    
    private func hintMatchingCards() {
        let cards = game.cards.filter({ isDealt($0) && !isDiscarded($0) })
        
        let foundNothing = (0, 0, 0)
        var matchIndices = foundNothing
        
        for i in cards.indices {
            for j in cards.indices {
                for k in cards.indices {
                    if  i != j && j != i && k != i &&
                        SetGameCardContent.doCardsMatch(
                            cards[i].content,
                            cards[j].content,
                            cards[k].content
                    ) {
                        matchIndices = (i, j, k)
                        break
                    }
                }
            }
        }
        
        if matchIndices != foundNothing {
            for i in [matchIndices.0, matchIndices.1, matchIndices.2] {
                let cardIndex = game.cards.firstIndex(where: { $0.id == cards[i].id })!
                hinted.insert(game.cards[cardIndex].id)
            }
        }
    }
    
    private var hint: some View {
        Button {
            hintMatchingCards()
        } label: {
            Text(.init(systemName: "questionmark.circle")).font(.largeTitle)
        }
    }
}

struct CardView: View {
    private let card: SymbolSetGame.Card
    
    private let isFaceUp: Bool
    private let isHinted: Bool
    
    init(card: SymbolSetGame.Card, isFaceUp: Bool, isHinted: Bool = false) {
        self.card = card
        self.isFaceUp = isFaceUp
        self.isHinted = isHinted
    }
    
    var body: some View {
        let symbol = CardContentConverter.createSymbolView(of: card)
        symbol.cardify(isFaceUp: isFaceUp, isSelected: card.isSelected, isHinted: isHinted)
    }
}

struct CardConstants {
    static let dealDuration: Double = 0.4
    static let totalDealDuration: Double = dealDuration * 6
    static let discardedRotation: Double = 7
    static let discardedRotatedQuantity: Int = 4
    static let discardedOffsetRight: CGFloat = 10
    static let discardedOffsetLeft: CGFloat = -33
}

struct DrawingConstants {
    static let lineWidth: CGFloat = 3.0
    static let cornerRadius: CGFloat = 10.0
    static let vGridAspectRatio: CGFloat = 2/3
    static let padding: CGFloat = 3
    static let undealtHeight: CGFloat = 110
    static let undealtWidth = DrawingConstants.undealtHeight * DrawingConstants.vGridAspectRatio
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolSetGameView().colorScheme(.dark)
    }
}
