//
//  Cardify.swift
//  Set
//
//  Created by Олег Куколев on 14.09.2021.
//

import Foundation
import SwiftUI

struct CardifyModifier: ViewModifier {
    let isFaceUp: Bool
    let isSelected: Bool
    let isHinted: Bool
    
    func body(content: Content) -> some View {
        let border = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
        
        ZStack {
            if isFaceUp {
                content
                
                if isSelected {
                    border.strokeBorder(Color.green, lineWidth: DrawingConstants.lineWidth * 2)
                } else {
                    if isHinted {
                        border.strokeBorder(Color.yellow, lineWidth: DrawingConstants.lineWidth * 2)
                    } else {
                        border.strokeBorder(Color.blue, lineWidth: DrawingConstants.lineWidth)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius).foregroundColor(.blue)
            }
        }
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
