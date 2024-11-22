//
//  RejseplanenProduct.swift
//  Rejseplanen
//
//  Created by Fredrik Nannestad on 20/11/2024.
//

public enum RejseplanenProduct {
    
    case interCityTrains
    case interCityFastTrains
    case regionalTrains
    case otherTrains
    case sTrains
    case bus
    case expressBus
    case nightBus
    case otherBusses
    case ferry
    case metro
    
    public static let trains: [RejseplanenProduct] = [.interCityTrains, .interCityFastTrains, .regionalTrains, .sTrains, .otherTrains]
    public static let busses: [RejseplanenProduct] = [.bus, .expressBus, .nightBus, .otherBusses]
    public static let metros: [RejseplanenProduct] = [.metro]
    public static let ferries: [RejseplanenProduct] = [.ferry]
    
}

/**
 Rejseplanen stopsNearby service define a parameter useProduct which value is a eleven digit bitmask. Since Swift doesn't support enum as bitmasks this function is a workaround to return the correct bitmask value for each product type. So instead of using the bitshift operator << we give each productType a 2^x value where x is the position in the bitmask
 
 :param: type The product type
 
 :returns: The bitmask value of the product type
 */
private func bitmaskValueForProduct(_ type: RejseplanenProduct) -> Int {
    switch type {
    case .interCityTrains:
        return 1024
    case .interCityFastTrains:
        return 512
    case .regionalTrains:
        return 256
    case .otherTrains:
        return 128
    case .sTrains:
        return 64
    case .bus:
        return 32
    case .expressBus:
        return 16
    case .nightBus:
        return 8
    case .otherBusses:
        return 4
    case .ferry:
        return 2
    case .metro:
        return 1
    }
}

/**
 Returns the 11 character bitmask string corresponding to the given array of `ProductType`s. The string can be used as value of the parameter useProduct in calls to Rejseplanen's stopsNearby service.
 
 :param: types An array of `ProductType`s
 
 :returns: An 11 character long bitmask string. Example for train product types: 000000011111
 */
internal func bitmaskStringForProducts(_ types: [RejseplanenProduct]) -> String {
    var value = 1024
    for type in types {
        value = value | bitmaskValueForProduct(type)
    }
    let string = String(value, radix: 2)
    return String(string[string.startIndex...])
}

