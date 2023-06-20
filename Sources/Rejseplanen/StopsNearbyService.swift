//
//  StopsNearbyService.swift
//  
//
//  Created by Fredrik Nannestad on 09/11/2022.
//

import Foundation
import CoreLocation

public typealias Stops = [Stop]

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

internal class StopsNearbyService {
    
    private let locationService: LocationService
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    // Rejseplanen doesn't seem to respect the maxCount parameter.
    func stopsNearby(location: CLLocation, products: [RejseplanenProduct]?, maxRadius: CLLocationDistance?, maxCount: Int?) async throws -> Stops {
        
        let url = self.stopsNearbyServiceURL(location: location, products: products, maxRadius: maxRadius, maxCount: maxCount)
        
        debugPrint("Requesting Rejseplanen stops nearby service: " + url.absoluteString)
        
        let list = try await self.locationService.locationList(url: url)
        let stops = list.stopLocations.compactMap { Stop(stopLocation: $0) }
        return stops
    }
    
    private func stopsNearbyServiceURL(location: CLLocation, products: [RejseplanenProduct]?, maxRadius: CLLocationDistance?, maxCount: Int?) -> URL {
        var components = URLComponents(string: rejseplanenBaseURLString + "stopsNearby")!
        let coordX = Int(location.coordinate.longitude * 1_000_000)
        let coordY = Int(location.coordinate.latitude * 1_000_000)
        var queryItems = [URLQueryItem(name: "coordX", value: "\(coordX)"),
                          URLQueryItem(name: "coordY", value: "\(coordY)")]
        if let maxRadius = maxRadius {
            queryItems.append(URLQueryItem(name: "maxRadius", value: "\(maxRadius)"))
        }
        if let maxCount = maxCount {
            queryItems.append(URLQueryItem(name: "maxCount", value: "\(maxCount)"))
        }
        if let products = products {
            let productBitMask = bitmaskStringForProducts(products)
            queryItems.append(URLQueryItem(name: "useProduct", value: "\(productBitMask)"))
        }
        queryItems.append(URLQueryItem(name: "format", value: "json"))
        components.queryItems = queryItems
        return components.url!
    }
    
}
