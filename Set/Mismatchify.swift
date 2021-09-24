//
//  Mismatchify.swift
//  Set
//
//  Created by Олег Куколев on 24.09.2021.
//

import SwiftUI

struct Mismatchify : AnimatableModifier {
    var scale: CGFloat
    var animatableData: CGFloat {
        get { scale }
        set { scale = newValue }
    }
    
    init(isMismatched: Bool) {
        scale = isMismatched ? AnimationConstants.scaleDefault : .zero
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if scale > 0 {
                RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius / scale)
                    .strokeBorder(lineWidth: DrawingConstants.lineWidth * scale)
                    .animation(scaleAnimation())
                    .foregroundColor(.red)
            }
        }
    }
    
    private func scaleAnimation() -> Animation {
        .easeInOut(duration: DrawingConstants.duration).repeatForever(autoreverses: true)
    }
    
    private struct AnimationConstants {
        static let scaleDefault: CGFloat = 2.0
    }
    
    private struct DrawingConstants {
        static let duration: Double = 0.35
        static let lineWidth: CGFloat = 3.0
        static let cornerRadius: CGFloat = 10.0
    }
}

extension View {
    func mismatchify(isMismatched: Bool) -> some View {
        self.modifier(Mismatchify(isMismatched: isMismatched))
    }
}
