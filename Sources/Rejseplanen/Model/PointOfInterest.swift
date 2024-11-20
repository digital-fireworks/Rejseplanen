//
//  PointOfInterest.swift
//  Rejseplanen
//
//  Created by Fredrik Nannestad on 20/11/2024.
//


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
