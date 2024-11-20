//
//  DepartureBoard.swift
//  Rejseplanen
//
//  Created by Fredrik Nannestad on 20/11/2024.
//

import Foundation

public struct DepartureBoard: Decodable {
    public internal(set) var stop: Stop!
    public let departures: [Departure]
    
    enum CodingKeys: String, CodingKey {
        case departures = "Departure"
    }
}
