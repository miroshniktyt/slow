//
//  GameData.swift
//  WhoIsSlow
//
//  Created by Anton Miroshnyk on 5/18/20.
//  Copyright © 2020 Anton Miroshnyk. All rights reserved.
//

import UIKit

struct GameData: Codable {
    
    enum GameDataType: String, Codable {
        case newLocation
        case didTap
        case finished
    }
    
    let dataType: GameDataType
    let location: Location?
}

struct Location: Codable {
    
//    let dateCreated: Date = Date()
    
    let x: CGFloat
    
    let y: CGFloat
    
    static var random: Location {
        return .init(x: .random(in: 0...1), y: .random(in: 0...1))
    }
}
