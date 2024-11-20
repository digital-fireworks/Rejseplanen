//
//  Location.swift
//  Rejseplanen
//
//  Created by Fredrik Nannestad on 20/11/2024.
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
