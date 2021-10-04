//
//  Flip3DTransition.swift
//  Set
//
//  Created by Олег Куколев on 25.09.2021.
//

import SwiftUI

struct rotation3DModifier: AnimatableModifier {
    var rotation: Double = 0
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    init(_ degrees: Double) {
        rotation = degrees
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(Angle.degrees(rotation), axis: (0, 1, 0))
    }
}

extension AnyTransition {
    static var flip180: AnyTransition {
        .modifier(
            active: rotation3DModifier(0),
            identity: rotation3DModifier(180)
        )
    }
    
    static func flip(_ from: Double, _ to: Double) -> AnyTransition {
        .modifier(
            active: rotation3DModifier(from),
            identity: rotation3DModifier(to)
        )
    }
}