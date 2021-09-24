//
//  Matchify.swift
//  Set
//
//  Created by Олег Куколев on 23.09.2021.
//

import SwiftUI

struct Matchify: AnimatableModifier {
    var scale: CGFloat
    var animatableData: CGFloat {
        get { scale }
        set { scale = newValue }
    }
    
    init(isMatched: Bool) {
        scale = isMatched ? AnimationConstants.scaleDefault : .zero
    }
    
    func body(content: Content) -> some View {
        ZStack {
            if scale > 0 {
                RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius).foregroundColor(.green)
                Circle().foregroundColor(.white).padding([.horizontal, .bottom], DrawingConstants.padding)
                Text(.init(systemName: "hand.thumbsup.fill")).font(.largeTitle).foregroundColor(.green)
                    .scaleEffect(scale)
                    .animation(.linear(duration: DrawingConstants.duration).repeatForever(autoreverses: true))
                    .padding(.bottom, DrawingConstants.padding)
            } else {
                content
            }
        }
    }
    
    private struct AnimationConstants {
        static let scaleDefault: CGFloat = 1.05
    }
    
    private struct DrawingConstants {
        static let duration: Double = 0.3
        static let cornerRadius: CGFloat = 10.0
        static let padding: CGFloat = 10.0
    }
}

extension View {
    func matchify(isMatched: Bool) -> some View {
        self.modifier(Matchify(isMatched: isMatched))
    }
}
