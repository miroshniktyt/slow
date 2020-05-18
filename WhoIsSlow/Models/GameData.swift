//
//  GameData.swift
//  WhoIsSlow
//
//  Created by Anton Miroshnyk on 5/18/20.
//  Copyright © 2020 Anton Miroshnyk. All rights reserved.
//

import Foundation

struct GameData: Codable {
    
    enum GameDataType: String, Codable {
        case newLocation
        case didTap
        case finish
    }
    
    let dataType: GameDataType
    let location: Location?
}
