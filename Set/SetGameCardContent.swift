//
//  SetGameCardContent.swift
//  Set
//
//  Created by Олег Куколев on 16.07.2021.
//

import Foundation

// MARK: - ThreeState
struct ThreeState {
    private var value: Int
    
    init(_ value: Int) {
        self.value = value >= 2 ? 2 :
            value <= 0 ? 0 : value
    }
    
    func get() -> Int {
        return value
    }
}

// MARK: - ThreeState extensions
extension ThreeState: Equatable {
    static func == (lhs: ThreeState, rhs: ThreeState) -> Bool {
        return lhs.value == rhs.value
    }
}

extension ThreeState: CustomDebugStringConvertible {
    var debugDescription: String {
        return String(value)
    }
}

// MARK: - SetGameCardContent
struct SetGameCardContent {
    let color: ThreeState
    let shape: ThreeState
    let count: ThreeState
    let texture: ThreeState
    
    init(colorState: Int, shapeState: Int, symbols: Int, textureState: Int) {
        color = ThreeState(colorState)
        shape = ThreeState(shapeState)
        count = ThreeState(symbols)
        texture = ThreeState(textureState)
    }
    
    private static func doMakeSet(_ t1: ThreeState, _ t2: ThreeState, _ t3: ThreeState) -> Bool {
        return (t1 == t2 && t1 == t3 && t2 == t3) || (t1 != t2 && t1 != t3 && t2 != t3)
    }
    
    static func doCardsMatch(_ c1: SetGameCardContent,
                             _ c2: SetGameCardContent,
                             _ c3: SetGameCardContent)
    -> Bool {
        return doMakeSet(c1.color, c2.color, c3.color) && doMakeSet(c1.shape, c2.shape, c3.shape) &&
            doMakeSet(c1.count, c2.count, c3.count) && doMakeSet(c1.texture, c2.texture, c3.texture)
    }
}

// MARK: - SetGameCardContent extensions
extension SetGameCardContent: Equatable {
    static func ==(lhs: SetGameCardContent, rhs: SetGameCardContent) -> Bool {
        let countOfEqualCharacteristics: Int = (
            (lhs.color == rhs.color).intValue +
            (lhs.shape == rhs.shape).intValue +
            (lhs.count == rhs.count).intValue +
            (lhs.texture == rhs.texture).intValue
        )
        
        return countOfEqualCharacteristics == 1
    }
}

extension SetGameCardContent: CustomDebugStringConvertible {
    var debugDescription: String {
        return "(\(color); \(shape); \(count); \(texture))"
    }
}

// MARK: - Bool extensions
extension Bool {
    var intValue: Int {
        return self ? 1 : 0
    }
}
