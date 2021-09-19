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
    
    @State private var discarded = Set<Int>()
    
    private func isDealt(_ card: SymbolSetGame.Card) -> Bool {
        dealt.contains(card.id)
    }
    
    private func deal(_ card: SymbolSetGame.Card) {
        dealt.insert(card.id)
    }
    
    private func dealUndealtCards() {
        for card in game.cards {
            if !isDealt(card) && !isDiscarded(card) {
                deal(card)
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
   
    private func isDiscarded(_ card: SymbolSetGame.Card) -> Bool {
        card.isMatched
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
    
    var gameInProgressBody: some View {
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
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: DrawingConstants.vGridAspectRatio, content: { card in
            if isDealt(card) && !isDiscarded(card) {
                CardView(card: card, isHinted: hinted.contains(card.id)).onTapGesture {
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
    
    var endGameBody: some View {
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
    
    private var deckPile: some View {
        ZStack {
            ForEach(game.cards.filter{ !isDealt($0) }) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealNamespace)
            }
            ForEach(game.deck) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealNamespace)
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
            withAnimation(dealAnimation(for: game.cards[0])) {
                dealUndealtCards()
            }
        }
    }
    
    @ViewBuilder
    private var discardPile: some View {
        let discardedCards = game.cards.filter(isDiscarded)
        ZStack {
            ForEach(discardedCards) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealNamespace)
            }
            if (discardedCards.count > 0) {
                Text("\(discardedCards.count)").font(.largeTitle).zIndex(100).foregroundColor(.white)
            }
        }
        .frame(width: DrawingConstants.undealtWidth, height: DrawingConstants.undealtHeight)
    }
    
    @State private var hinted = Set<Int>()
    
    private func hintMatchingCards() {
        let cards = game.cards.filter({ isDealt($0) && !isDiscarded($0) })
        var result: (Int, Int, Int) = (0, 0, 0)
        for i in cards.indices {
            for j in cards.indices {
                for k in cards.indices {
                    if  i != j && j != i && k != i &&
                        SetGameCardContent.doCardsMatch(
                            cards[i].content,
                            cards[j].content,
                            cards[k].content
                    ) {
                        result = (i, j, k)
                        break
                    }
                }
            }
        }
        if result != (0, 0, 0) {
            for i in [result.0, result.1, result.2] {
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
    let card: SymbolSetGame.Card
    let isHinted: Bool
    
    init(card: SymbolSetGame.Card, isHinted: Bool = false) {
        self.card = card
        self.isHinted = isHinted
    }
    
    var body: some View {
        GeometryReader(content: { geometry in
            let symbol = CardContentConverter.createSymbolView(of: card)
            symbol.cardify(isFaceUp: !card.isMatched, isSelected: card.isSelected, isHinted: isHinted)
        })
    }
}

struct CardConstants {
    static let dealDuration: Double = 0.4
    static let totalDealDuration: Double = dealDuration * 6
}

struct DrawingConstants {
    static let lineWidth: CGFloat = 3.0
    static let cornerRadius: CGFloat = 10.0
    static let vGridAspectRatio: CGFloat = 2/3
    static let padding: CGFloat = 3
    static let undealtHeight: CGFloat = 90
    static let undealtWidth = DrawingConstants.undealtHeight * DrawingConstants.vGridAspectRatio
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolSetGameView().colorScheme(.dark)
    }
}