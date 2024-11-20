//
//  JourneyDetailsRef.swift
//  Rejseplanen
//
//  Created by Fredrik Nannestad on 20/11/2024.
//

import Foundation

// TODO: Only partially implemented

public struct JourneyDetailsRef: Codable {
    
    public let ref: String
    
    enum CodingKeys: String, CodingKey {
        case ref = "ref"
    }
}
