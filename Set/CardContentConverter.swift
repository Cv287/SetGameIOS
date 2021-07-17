//
//  CardContentConverter.swift
//  Set
//
//  Created by Олег Куколев on 17.07.2021.
//

import SwiftUI

struct CardContentConverter {
    @ViewBuilder
    static func createSymbolView(of card: SymbolSetGame.Card) -> some View {
        GeometryReader { geometry in
            let aspectRatio: CGFloat = geometry.size.width / geometry.size.height
            
            VStack {
                ForEach(0..<(card.content.count.get())+1) { _ in
                    switch card.content.texture.get() {
                    case 0: filledShape(of: card)
                    case 1: strokedShape(of: card)
                    default:shadedShape(of: card)
                    }
                }
            }
            .padding()
            .foregroundColor(getColor(of: card))
            .aspectRatio(aspectRatio, contentMode: .fit)
        }
    }
    
    @ViewBuilder
    private static func filledShape(of card: SymbolSetGame.Card) -> some View {
        switch card.content.shape.get() {
        case 0: Diamond()
        case 1: Rectangle()
        default:Circle()
        }
    }
    
    @ViewBuilder
    private static func strokedShape(of card: SymbolSetGame.Card) -> some View {
        switch card.content.shape.get() {
        case 0: Diamond().stroke(lineWidth: DrawingConstants.lineWidth)
        case 1: Rectangle().stroke(lineWidth: DrawingConstants.lineWidth)
        default:Circle().stroke(lineWidth: DrawingConstants.lineWidth)
        }
    }
    
    @ViewBuilder
    private static func shadedShape(of card: SymbolSetGame.Card) -> some View {
        switch card.content.shape.get() {
        case 0: ZStack{ Diamond().opacity(DrawingConstants.shadedOpacity); strokedShape(of: card) }
        case 1: ZStack{ Rectangle().opacity(DrawingConstants.shadedOpacity); strokedShape(of: card) }
        default:ZStack{ Circle().opacity(DrawingConstants.shadedOpacity); strokedShape(of: card) }
        }
    }
    
    private static func getColor(of card: SymbolSetGame.Card) -> Color {
        switch card.content.color.get() {
        case 0: return Color.purple
        case 1: return Color.red
        default:return Color.yellow
        }
    }
}
