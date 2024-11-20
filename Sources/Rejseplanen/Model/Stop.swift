//
//  Stop.swift
//  Rejseplanen
//
//  Created by Fredrik Nannestad on 20/11/2024.
//

import Foundation

public class Stop: Location, Identifiable, Equatable {
    
    public let id: String
    
#if DEBUG
    /**
     Use this function to create stop object for test use.
    */
    public override init(name: String, x: Double, y: Double) {
        self.id = UUID().uuidString
        super.init(name: name, x: x, y: y)
    }
#endif
    
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
