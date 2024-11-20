//
//  Address.swift
//  Rejseplanen
//
//  Created by Fredrik Nannestad on 20/11/2024.
//


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
