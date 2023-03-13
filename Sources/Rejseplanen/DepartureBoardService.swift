//
//  DepartureBoardService.swift
//  
//
//  Created by Fredrik Nannestad on 09/11/2022.
//

import Foundation

enum DepartureType {
    case intercity
    case lyn
    case regional
    case stog
    case tog
    case bus
    case expressBus
    case nightBus
    case teleBus
    case ferry
    case metro
    case unknown
    
    
}

public struct Departure: Decodable, Identifiable {
    
    let name: String
    let type: String
    let stop: String
    let date: Date
    let track: String?
    let realTimeDate: Date?
    let realtimeTrack: String?
    let direction: String?
    let messages: String?
    let finalStop: String?
    let journeyDetails: JourneyDetailsRef?
    
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
        self.type = try container.decode(String.self, forKey: .type)
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
    
}

extension Departure: CustomStringConvertible {
    
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

struct JourneyDetailsRef: Codable {
    let ref: String
    
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
