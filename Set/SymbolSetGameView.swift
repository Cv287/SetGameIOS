//
//  ContentView.swift
//  Set
//
//  Created by Олег Куколев on 15.07.2021.
//

import SwiftUI

struct SymbolSetGameView: View {
    @ObservedObject var game = SymbolSetGame()
    
    var body: some View {
        VStack {
            if !game.isEnded {
                container(for: game.cards)
                dealButton
            } else {
                Text("You won!").font(.largeTitle)
                restartButton.padding()
            }
        }
    }
    
    private func container(for cards: [SymbolSetGame.Card]) -> some View {
        AspectVGrid(items: cards, aspectRatio: DrawingConstants.vGridAspectRatio, content: { card in
            CardView(card: card).onTapGesture {
                game.choose(card)
            }
            .padding(DrawingConstants.padding)
        })
        .padding(.horizontal)
    }
    
    private var dealButton: some View {
        Button {
            game.dealThreeMoreCards()
        } label: {
            Text("Deal 3 More Cards").font(.largeTitle)
        }
        .disabled(game.isDeckEmpty)
    }
    
    private var restartButton: some View {
        Button {
            game.reset()
        } label: {
            Text("Try again").font(.largeTitle)
        }
    }
}

struct CardView: View {
    let card: SymbolSetGame.Card
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                CardContentConverter.createSymbolView(of: card)
                
                let border = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                if card.isSelected {
                    border.strokeBorder(Color.green, lineWidth: DrawingConstants.lineWidth * 2)
                } else {
                    border.strokeBorder(Color.blue, lineWidth: DrawingConstants.lineWidth)
                }
            }
        })
    }
}

struct DrawingConstants {
    static let cornerRadius: CGFloat = 10.0
    static let lineWidth: CGFloat = 3.0
    static let vGridAspectRatio: CGFloat = 0.65
    static let shadedOpacity: Double = 0.5
    static let padding: CGFloat = 3
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolSetGameView().colorScheme(.light)
    }
}
