//
//  ContentView.swift
//  Set
//
//  Created by Олег Куколев on 15.07.2021.
//

import SwiftUI

struct EmojiSetGameView: View {
    @ObservedObject var game = EmojiSetGame()
    
    var body: some View {
        VStack {
            container(for: game.cards)
            
            Button {
                game.dealThreeMoreCards()
            } label: {
                Text("Deal 3 More Cards").font(.largeTitle)
            }.disabled(game.isDeckEmpty)
        }
    }
    
    private func container(for cards: [EmojiSetGame.Card]) -> some View {
        AspectVGrid(items: cards, aspectRatio: DrawingConstants.vGridAspectRatio, content: { card in
            CardView(card: card).onTapGesture {
                game.choose(card)
            }.padding(3)
        })
        .padding(.horizontal)
    }
}

struct CardView: View {
    let card: EmojiSetGame.Card
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                Text(card.content).font(.system(size: geometry.size.width / 1.5))
                let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                if card.isSelected {
                    shape.strokeBorder(Color.green, lineWidth: DrawingConstants.lineWidth)
                } else {
                    shape.strokeBorder(Color.blue, lineWidth: DrawingConstants.lineWidth)
                }
            }
        })
    }
}

struct DrawingConstants {
    static let cornerRadius: CGFloat = 10.0
    static let lineWidth: CGFloat = 3.0
    static let vGridAspectRatio: CGFloat = 0.65
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiSetGameView().colorScheme(.dark)
        EmojiSetGameView().colorScheme(.light)
    }
}
