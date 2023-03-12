import Foundation
import CoreLocation

internal let rejseplanenBaseURLString = "https://xmlopen.rejseplanen.dk/bin/rest.exe/"

enum RejseplanenError: Error {
    case unexpectedError
    case invalidServerResponse(response: URLResponse)
    case jsonDecoding(error: DecodingError)
}

public class Rejseplanen {
    
    private let locationService: LocationService
    private let stopsNearbyService: StopsNearbyService
    private let departureBoardService: DepartureBoardService
    
    public init() {
        self.locationService = LocationService()
        self.stopsNearbyService = StopsNearbyService(locationService: self.locationService)
        self.departureBoardService = DepartureBoardService()
    }
    
    public func location(query: String) async throws -> Locations {
        return try await self.locationService.location(query: query)
    }
    
//    public func trip() async throws {
//
//    }
//
    
    public func departureBoard(forStop stop: Stop) async throws -> DepartureBoard {
        return try await self.departureBoardService.departureBoard(forStop: stop)        
    }
//
//    public func arrivalBoard() async throws {
//
//    }
//
//    public func multiDepartureBoard() async throws {
//
//    }
    
    public func stopsNearby(location: CLLocation, products: [RejseplanenProduct]?, maxRadius: CLLocationDistance?) async throws -> Stops {
        // Rejseplanen doesn't seem to respect the maxCount (maxNumber in Rejseplanen terminology), so it's not exposed outside the package.
        return try await self.stopsNearbyService.stopsNearby(location: location, products: products, maxRadius: maxRadius, maxCount: nil)
    }
}
