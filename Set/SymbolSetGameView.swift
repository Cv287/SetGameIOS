//
//  ContentView.swift
//  Set
//
//  Created by Олег Куколев on 15.07.2021.
//

import SwiftUI

struct SymbolSetGameView: View {
    @ObservedObject var game = SymbolSetGame()
    
    @Namespace private var cardDealDiscardAnimation
    
    @State private var dealt = Set<Int>()
    
    @State private var discarded = Set<Int>()
    
    @State private var discardedCards = [SymbolSetGame.Card]()
    
    private func isDealt(_ card: SymbolSetGame.Card) -> Bool {
        dealt.contains(card.id)
    }
    
    private func isDiscarded(_ card: SymbolSetGame.Card) -> Bool {
        discarded.contains(card.id)
    }
    
    private func deal(_ card: SymbolSetGame.Card) {
        dealt.insert(card.id)
    }
    
    private func discard(_ card: SymbolSetGame.Card) {
        discardedCards.insert(card, at: 0)
        discarded.insert(card.id)
    }
    
    private func discardAllMatched() {
        game.cards.filter({ !isDiscarded($0) && $0.isMatched }).forEach({ discard($0) })
    }
    
    private func dealUndealtCards(delay: Double = 0) {
        var counter = 0
        for card in game.cards {
            if !isDealt(card) && !isDiscarded(card) {
                withAnimation(dealAnimation(for: game.cards[counter]).delay(delay)) {
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
    
    private func countCardsThatShouldBeDiscarded() -> Int {
        game.cards.filter({ !isDiscarded($0) && $0.isMatched }).count
    }
    
    private func isMismatched(_ card: SymbolSetGame.Card) -> Bool {
        game.hasMismatchOccured && game.lastThreeSelectedCards().contains(card)
    }
    
    private var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: DrawingConstants.vGridAspectRatio, content: { card in
            if isDealt(card) && !isDiscarded(card) {
                CardView(card: card, isFaceUp: true, isHinted: isHinted(card)).onTapGesture {
                    withAnimation(.easeInOut(duration: AnimationConstants.chooseDuration)) {
                        game.choose(card)
                    }
                    withAnimation(.linear(duration: AnimationConstants.dealDuration)) {
                        dealUndealtCards()
                    }
                        
                    if game.selectedCards.count == 1 && countCardsThatShouldBeDiscarded() > 0 {
                        withAnimation(.linear(duration: AnimationConstants.discardDuration)) {
                            game.moveDiscardedCardsAway()
                            discardAllMatched()
                        }
                    }
                }
                .matchify(isMatched: card.isMatched)
                .mismatchify(isMismatched: isMismatched(card))
                .zIndex(isMismatched(card) ? .infinity : zIndex(of: card))
                .animation(.linear(duration: AnimationConstants.matchDuration))
                .matchedGeometryEffect(id: card.id, in: cardDealDiscardAnimation)
                .transition(.asymmetric(insertion: .opacity, removal: .identity))
                .padding(DrawingConstants.padding)
                
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
        -Double(game.cards.firstIndex(of: card) ?? .zero)
    }
    
    private var deckPile: some View {
        ZStack {
            let undealtCards = game.cards.filter{ !isDealt($0) }
            ForEach(undealtCards + game.deck) { card in
                CardView(card: card, isFaceUp: false)
                    .matchedGeometryEffect(id: card.id, in: cardDealDiscardAnimation)
                    .animation(.linear(duration: AnimationConstants.dealDuration))
                    .zIndex(zIndex(of: card))
            }
            Text("\(game.deck.count + game.cards.filter({ !isDealt($0) }).count)")
                .font(.largeTitle).zIndex(.infinity).foregroundColor(.white)
        }
        .onTapGesture {
            let isThisStartOfTheGame = dealt.isEmpty
            if (isThisStartOfTheGame) {
                for card in game.cards {
                    withAnimation(dealAnimation(for: card)) {
                        deal(card)
                    }
                }
                return
            }
            
            var hasDiscardedCards = false
            if countCardsThatShouldBeDiscarded() > 0 {
                discardAllMatched()
                hasDiscardedCards = true
                game.replaceThreeMatchedCards()
            } else {
                game.dealThreeMoreCards()
            }
            dealUndealtCards(delay: hasDiscardedCards ? AnimationConstants.discardDuration : 0)
        }
        .frame(width: DrawingConstants.undealtWidth, height: DrawingConstants.undealtHeight)
    }
    
    private func moveDiscarded(card: SymbolSetGame.Card) -> CGAffineTransform {
        let index = discardedCards.firstIndex(of: card)!
        return index < CardConstants.discardedRotatedQuantity ?
            .init(translationX: CardConstants.discardedOffsetLeft + CGFloat(index) * CardConstants.discardedOffsetRight, y: .zero) :
            .init()
    }
    
    private func rotation(of card: SymbolSetGame.Card) -> Double {
        let index = discardedCards.firstIndex(of: card) ?? CardConstants.discardedRotatedQuantity
        return index < CardConstants.discardedRotatedQuantity ?
            Double(index) * CardConstants.discardedRotation : .zero
    }
    
    private var discardPile: some View {
        ZStack {
            ForEach(game.cards) { card in
                if isDiscarded(card) {
                    CardView(card: card, isFaceUp: true)
                        .matchedGeometryEffect(id: card.id, in: cardDealDiscardAnimation)
                        .rotationEffect(Angle.degrees(rotation(of: card)))
                        .transformEffect(moveDiscarded(card: card))
                        .animation(.linear(duration: AnimationConstants.discardDuration))
                        .zIndex(zIndex(of: card))
                }
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                discardedCards.shuffle()
            }
        }
        .frame(width: DrawingConstants.undealtWidth, height: DrawingConstants.undealtHeight)
    }
    
    @State private var hinted = Set<Int>()
    
    func isHinted(_ card: SymbolSetGame.Card) -> Bool {
        hinted.contains(card.id)
    }
    
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
            hinted.removeAll()
            withAnimation(.linear(duration: 2.5)) {
                hintMatchingCards()
            }
        } label: {
            Text(.init(systemName: "questionmark.circle")).font(.largeTitle)
        }
    }
    
    private struct AnimationConstants {
        static let matchDuration: Double = 0.5
        static let dealDuration: Double = 0.38
        static let discardDuration: Double = 0.38
        static let chooseDuration: Double = 0.3
    }
    
    private struct CardConstants {
        static let dealDuration: Double = 0.4
        static let totalDealDuration: Double = dealDuration * 6
        static let discardedRotation: Double = 7
        static let discardedRotatedQuantity: Int = 4
        static let discardedOffsetRight: CGFloat = 10
        static let discardedOffsetLeft: CGFloat = -33
    }
    
    private struct DrawingConstants {
        static let lineWidth: CGFloat = 3.0
        static let cornerRadius: CGFloat = 10.0
        static let vGridAspectRatio: CGFloat = 2/3
        static let padding: CGFloat = 3
        static let undealtHeight: CGFloat = 90
        static let undealtWidth = DrawingConstants.undealtHeight * DrawingConstants.vGridAspectRatio
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolSetGameView().colorScheme(.dark)
    }
}
