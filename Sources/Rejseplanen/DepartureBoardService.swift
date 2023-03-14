//
//  DepartureBoardService.swift
//  
//
//  Created by Fredrik Nannestad on 09/11/2022.
//

import Foundation

/**
 <xs:enumeration value="IC"/>
 <xs:enumeration value="LYN"/>
 <xs:enumeration value="REG"/>
 <xs:enumeration value="S"/>
 <xs:enumeration value="TOG"/>
 <xs:enumeration value="BUS"/>
 <xs:enumeration value="EXB"/>
 <xs:enumeration value="NB"/>
 <xs:enumeration value="TB"/>
 <xs:enumeration value="F"/>
 <xs:enumeration value="M"/>
 <xs:enumeration value="LET"/>
 */

public enum DepartureType: String {
    case intercity = "IC"
    case lyn = "LYN"
    case regional = "REG"
    case stog = "S"
    case tog = "TOG"
    case bus = "BUS"
    case expressBus = "EXB"
    case nightBus = "NB"
    case teleBus = "TB"
    case ferry = "F"
    case metro = "M"
    case lightRail = "LET"
    case unknown = "UNKNOWN"
}

public struct Departure: Decodable, Identifiable, CustomStringConvertible {
    
    public let name: String
    public let type: DepartureType
    public let stop: String
    public let date: Date
    public let track: String?
    public let realTimeDate: Date?
    public let realtimeTrack: String?
    public let direction: String?
    public let messages: String?
    public let finalStop: String?
    public let journeyDetails: JourneyDetailsRef?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case type = "type"
        case stop = "stop"
        case time = "time"
        case date = "date"
        case track = "track"
        case realtimeTime = "rtTime"
        case realtimeDate = "rtDate"
        case realtimeTrack = "rtTrack"
        case direction = "direction"
        case messages = "messages"
        case finalStop = "finalStop"
        case journeyDetails = "JourneyDetailRef"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
       
        let typeString = try container.decode(String.self, forKey: .type)
        self.type = DepartureType(rawValue: typeString) ?? .unknown
        
        self.stop = try container.decode(String.self, forKey: .stop)
        
        let time = try container.decode(String.self, forKey: .time)
        let date = try container.decode(String.self, forKey: .date)
        self.date = try RejseplanenDateFormatter.shared.dateFromRejseplanenTime(time, andDate: date)
        
        self.track = try container.decodeIfPresent(String.self, forKey: .track)
        if let realtimeTime = try container.decodeIfPresent(String.self, forKey: .realtimeTime), let realtimeDate = try container.decodeIfPresent(String.self, forKey: .realtimeDate) {
            self.realTimeDate = try RejseplanenDateFormatter.shared.dateFromRejseplanenTime(realtimeTime, andDate: realtimeDate)
        } else {
            self.realTimeDate = nil
        }
        
        self.realtimeTrack = try container.decodeIfPresent(String.self, forKey: .realtimeTrack)
        
        self.direction = try container.decodeIfPresent(String.self, forKey: .direction)
        self.messages = try container.decodeIfPresent(String.self, forKey: .messages)
        self.finalStop = try container.decodeIfPresent(String.self, forKey: .finalStop)
        self.journeyDetails = try container.decodeIfPresent(JourneyDetailsRef.self, forKey: .journeyDetails)
    }
    
    public var id: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.type)
        hasher.combine(self.stop)
        hasher.combine(self.date)

        return hasher.finalize()
    }
    
    public var description: String {
        return "Departure: \(self.name), \(self.type), \(self.date)"
    }
    
}

public struct DepartureBoard: Decodable {
    public internal(set) var stop: Stop!
    public let departures: [Departure]
    
    enum CodingKeys: String, CodingKey {
        case departures = "Departure"
    }
}

struct DepartureBoardContainer: Decodable {
    let departureBoard: DepartureBoard
    
    enum CodingKeys: String, CodingKey {
        case departureBoard = "DepartureBoard"
    }
}

public struct JourneyDetailsRef: Codable {
    public let ref: String
    
    enum CodingKeys: String, CodingKey {
        case ref = "ref"
    }
}

class DepartureBoardService {
    
    func departureBoard(forStop stop: Stop) async throws -> DepartureBoard {
        let url = self.departureBoardURL(forStop: stop)
        var departureBoard = try await self.departureBoard(url: url)
        departureBoard.stop = stop
        return departureBoard
    }
    
    private func departureBoardURL(forStop stop: Stop) -> URL {
        var components = URLComponents(string: rejseplanenBaseURLString + "departureBoard")!
        let queryItems = [URLQueryItem(name: "id", value: "\(stop.id)"),
                          URLQueryItem(name: "format", value: "json")]
        components.queryItems = queryItems
        return components.url!
    }
    
    private func departureBoard(url: URL) async throws -> DepartureBoard {
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw RejseplanenError.invalidServerResponse(response: response)
        }
        
        do {
            let container = try JSONDecoder().decode(DepartureBoardContainer.self, from: data)
            return container.departureBoard
        } catch let error as DecodingError {
            switch error {
            case .dataCorrupted(let context):
                print(context.codingPath.description)
            case .keyNotFound(let key, let context):
                print(context.underlyingError?.localizedDescription ?? "")
                print("Key not found: \(key)")
            case .valueNotFound(let type, let context):
                print(context.underlyingError?.localizedDescription ?? "")
                print("Type not found: \(type)")
            case .typeMismatch(let type, let context):
                print(context.codingPath.description)
                print("Type mismatch: \(type)")
            default:
                print("Default")
            }
            throw RejseplanenError.jsonDecoding(error: error)
        }
    }
    
}
