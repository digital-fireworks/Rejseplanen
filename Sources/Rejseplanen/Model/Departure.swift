//
//  Departure.swift
//  Rejseplanen
//
//  Created by Fredrik Nannestad on 20/11/2024.
//

import Foundation

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

public struct Departure: Decodable, Identifiable, CustomStringConvertible, Equatable {
    
    public let name: String
    public let type: DepartureType
    public let stop: String
    public let date: Date
    public let track: String?
    public let realTimeDate: Date?
    public let realtimeTrack: String?
    public let direction: String?
    public let cancelled: Bool?
    public let messages: Int
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
        case cancelled = "cancelled"
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
        
        let cancelledString = try container.decodeIfPresent(String.self, forKey: .cancelled) ?? "false"
        self.cancelled = cancelledString == "true" ? true : false
        
        let messagesString = try container.decodeIfPresent(String.self, forKey: .messages) ?? "0"
        self.messages = Int(messagesString) ?? 0
        
        self.finalStop = try container.decodeIfPresent(String.self, forKey: .finalStop)
        self.journeyDetails = try container.decodeIfPresent(JourneyDetailsRef.self, forKey: .journeyDetails)
    }
    
    public static func == (lhs: Departure, rhs: Departure) -> Bool {
        return lhs.id == rhs.id
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

// MARK: Debug helpers

#if DEBUG
public extension Departure {
    /**
     Use this function to create departure object for test use.
    */
    static func fromJSON(json: String) -> Departure? {
        guard let data = json.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(Departure.self, from: data)
        } catch {
            print("Failed to create departure from json: \(json)")
            return nil
        }
    }
}
#endif
