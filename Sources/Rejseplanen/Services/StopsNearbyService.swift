//
//  StopsNearbyService.swift
//  
//
//  Created by Fredrik Nannestad on 09/11/2022.
//

import CoreLocation

public typealias Stops = [Stop]

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
