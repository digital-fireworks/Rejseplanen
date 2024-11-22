//
//  DepartureBoard.swift
//  Rejseplanen
//
//  Created by Fredrik Nannestad on 20/11/2024.
//

import Foundation

public enum DepartureBoardType {
    case all
    case trains
    case busses
    case metros
    
    internal var queryItems: [URLQueryItem] {
        switch self {
        case .all:
            return [] // No paramters is required to return departures for all types.
        case .trains:
            return [.init(name: "useTog", value: "1"), .init(name: "useBus", value: "0"), .init(name: "useMetro", value: "0")]
        case .busses:
            return [.init(name: "useTog", value: "0"), .init(name: "useBus", value: "1"), .init(name: "useMetro", value: "0")]
        case .metros:
            return [.init(name: "useTog", value: "0"), .init(name: "useBus", value: "0"), .init(name: "useMetro", value: "1")]
        }
    }
}

public struct DepartureBoard: Decodable {
    public internal(set) var stop: Stop!
    public internal(set) var type: DepartureBoardType!
    public let departures: [Departure]
    
    enum CodingKeys: String, CodingKey {
        case departures = "Departure"
    }
}
