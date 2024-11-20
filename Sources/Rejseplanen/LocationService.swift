//
//  LocationService.swift
//  
//
//  Created by Fredrik Nannestad on 08/11/2022.
//

import Foundation
import CoreLocation

public typealias Locations = (stops: [Stop], addresses: [Address], pointsOfInterest: [PointOfInterest])

public class Location {
    public let name: String
    public let location: CLLocation
    
    internal init(name: String, x: Double, y: Double) {
        self.name = name
        // This is not an error - y *is* latitude and x *is* longitude.
        self.location = CLLocation(latitude: y, longitude: x)
    }
}

extension Location: CustomStringConvertible {
    
    @objc public var description: String {
        return self.name + ", (\(self.location.coordinate.latitude), \(self.location.coordinate.longitude))"
    }
}

public class Stop: Location, Identifiable, Equatable {
    
    public let id: String
    
    internal init(id: String, name: String, x: Double, y: Double) {
        self.id = id
        super.init(name: name, x: x, y: y)
    }
    
    internal init?(stopLocation: StopLocation) {
        if let dx = Double(stopLocation.x), let dy = Double(stopLocation.y) {
            self.id = stopLocation.id
            super.init(name: stopLocation.name, x: dx/1_000_000, y: dy/1_000_000)
        } else {
            // Cannot convert x or y to double value - so this must an invalid stop - discard.
            return nil
        }
    }
    
    public override var description: String {
        return "Stop, " + self.id + ", " + super.description
    }
    
    public static func == (lhs: Stop, rhs: Stop) -> Bool {
        return lhs.id == rhs.id
    }
}

public class Address: Location {
    
    internal init?(coordLocation: CoordLocation) {
        if coordLocation.type == "ADR", let dx = Double(coordLocation.x), let dy = Double(coordLocation.y) {
            super.init(name: coordLocation.name, x: dx/1_000_000, y: dy/1_000_000)
        } else {
            return nil
        }
    }
    
    public override var description: String {
        return "Address" + ", " + super.description
    }
}

public class PointOfInterest: Location {
    
    internal init?(coordLocation: CoordLocation) {
        if coordLocation.type == "POI", let dx = Double(coordLocation.x), let dy = Double(coordLocation.y) {
            super.init(name: coordLocation.name, x: dx/1_000_000, y: dy/1_000_000)
        } else {
            return nil
        }
    }
    
    public override var description: String {
        return "Point of interest, " + super.description
    }
}

internal class LocationService {
    
    func location(query: String) async throws -> Locations {
        let url = self.locationServiceURL(searchString: query)
        debugPrint("Requesting Rejseplanen location service: " + url.absoluteString)
        let list = try await self.locationList(url: url)
        
        let stops = list.stopLocations.compactMap { Stop(stopLocation: $0) }
        let addresses = list.coordLocations.compactMap { Address(coordLocation: $0) }
        let pointsOfInterest = list.coordLocations.compactMap { PointOfInterest(coordLocation: $0) }
        
        return (stops, addresses, pointsOfInterest)
    }
    
    private func locationServiceURL(searchString: String) -> URL {
        var components = URLComponents(string: rejseplanenBaseURLString + "location")!
        let queryItems = [URLQueryItem(name: "input", value: searchString),
                          URLQueryItem(name: "format", value: "json")]
        components.queryItems = queryItems
        return components.url!
    }
    
    internal func locationList(url: URL) async throws -> LocationList {

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw RejseplanenError.invalidServerResponse(response: response)
        }
        do {
            let container = try JSONDecoder().decode(LocationListContainer.self, from: data)
            return container.locationList
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

internal struct LocationListContainer: Codable, CustomStringConvertible {
    
    let locationList: LocationList
    
    enum CodingKeys: String, CodingKey {
        case locationList = "LocationList"
    }
    
    var description: String {
        return "LocationListContainer: " + self.locationList.description
    }
}

internal struct LocationList: Codable, CustomStringConvertible {
    
    let stopLocations: [StopLocation]
    let coordLocations: [CoordLocation]
    
    enum CodingKeys: String, CodingKey {
        case stopLocations = "StopLocation"
        case coordLocations = "CoordLocation"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.stopLocations) {
            do {
                self.stopLocations = try container.decode([StopLocation].self, forKey: .stopLocations)
            } catch DecodingError.typeMismatch {
                do {
                    let stopLocation = try container.decode(StopLocation.self, forKey: .stopLocations)
                    self.stopLocations = [stopLocation]
                } catch {
                    self.stopLocations = []
                }
            } catch is DecodingError {
                self.stopLocations = []
            }
        } else {
            self.stopLocations = []
        }
   
        /*
         Rejseplanen will return either no CoordLocations (i.e. the key will not be present at all), an array of CoordLocations or a dictionary containing a single CoordLocation. For that reason we need to decode in several steps.
         */
        if container.contains(.coordLocations) {
            do {
                // Look for an array of CoordLocations.
                self.coordLocations = try container.decode([CoordLocation].self, forKey: .coordLocations)
            } catch DecodingError.typeMismatch {
                // We didn't find array, so maybe Rejseplanen only return a single location:
                do {
                    let coordLocation = try container.decode(CoordLocation.self, forKey: .coordLocations)
                    self.coordLocations = [coordLocation]
                } catch {
                    // We found the CoordLocation key but no valid CoordLocations were found.
                    self.coordLocations = []
                }
            } catch is DecodingError {
                // Some unexpected decoding error happened
                self.coordLocations = []
            }
        } else {
            self.coordLocations = []
        }
    }
    
    var description: String {
        return "StopLocations\(stopLocations.count): \(stopLocations.description)\nCoodLocations\(coordLocations.count): \(coordLocations.description)"
    }
}

internal struct CoordLocation: Codable, CustomStringConvertible {
    
    let name: String
    let type: String
    let x: String
    let y: String
    
    var description: String {
        return "\(name), \(type), x: \(x), y: \(y)"
    }

}

internal struct StopLocation: Codable, CustomStringConvertible {
    let id: String
    let name: String
    let x: String
    let y: String
    
    var description: String {
        return "\(id), \(name), x: \(x), y: \(y)"
    }

}
