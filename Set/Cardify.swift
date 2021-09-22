//
//  Cardify.swift
//  Set
//
//  Created by Олег Куколев on 14.09.2021.
//

import Foundation
import SwiftUI

struct CardifyModifier: AnimatableModifier {
    let isSelected: Bool
    let isHinted: Bool
    
    var rotation: Double // in degrees
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    init(isFaceUp: Bool, isSelected: Bool, isHinted: Bool = false) {
        rotation = isFaceUp ? 0 : 180
        self.isSelected = isSelected
        self.isHinted = isHinted
    }
    
    func body(content: Content) -> some View {
        ZStack {
            let border = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            
            if rotation < 90 {
                if isSelected {
                    border.strokeBorder(Color.green, lineWidth: DrawingConstants.lineWidth * 2)
                } else {
                    border.foregroundColor(.white)
                    
                    if isHinted {
                        border.strokeBorder(Color.yellow, lineWidth: DrawingConstants.lineWidth * 2)
                    } else {
                        border.strokeBorder(Color.blue, lineWidth: DrawingConstants.lineWidth)
                    }
                }
                
                content
            } else {
                RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius).foregroundColor(.blue)
            }
        }
        .rotation3DEffect(Angle.degrees(rotation), axis: (0, 1, 0))
    }
    
    private struct DrawingConstants {
        static let lineWidth: CGFloat = 3.0
        static let cornerRadius: CGFloat = 10.0
    }
}

extension View {
    func cardify(isFaceUp: Bool, isSelected: Bool, isHinted: Bool = false) -> some View {
        self.modifier(CardifyModifier(isFaceUp: isFaceUp, isSelected: isSelected, isHinted: isHinted))
    }
}

struct Cardify_Previews: PreviewProvider {
    @State static var rotated = false
    
    static var previews: some View {
        Text("Sample").cardify(isFaceUp: rotated, isSelected: rotated)
        .onTapGesture {
            Cardify_Previews.rotated.toggle()
        }
        .padding()
    }
}
