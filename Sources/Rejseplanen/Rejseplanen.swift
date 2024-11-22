import Foundation
import CoreLocation

internal let rejseplanenBaseURLString = "https://xmlopen.rejseplanen.dk/bin/rest.exe/"

enum RejseplanenError: Error {
    case unexpectedError
    case invalidServerResponse(response: URLResponse)
    case jsonDecoding(error: DecodingError)
}

/// Main interface for interacting with the Rejseplanen API.
public class Rejseplanen {
    
    private let locationService: LocationService
    private let stopsNearbyService: StopsNearbyService
    private let departureBoardService: DepartureBoardService
    
    /**
     Initializes the `Rejseplanen` class.
     
     This sets up internal services required for fetching locations, nearby stops, and departure board information.
     */
    public init() {
        self.locationService = LocationService()
        self.stopsNearbyService = StopsNearbyService(locationService: self.locationService)
        self.departureBoardService = DepartureBoardService()
    }
    
    /**
     Fetches location data based on a query.
     
     - Parameter query: A string representing the search term (e.g., a city, address, or stop name).
     - Returns: A `Locations` object containing matching locations.
     - Throws: A `RejseplanenError` if an unexpected error, invalid server response, or JSON decoding issue occurs.
     */
    public func location(query: String) async throws -> Locations {
        return try await self.locationService.location(query: query)
    }
    
    /**
     Fetches the departure board for a specific stop.
     
     - Parameter stop: The `Stop` for which to fetch the departure board.
     - Returns: A `DepartureBoard` containing upcoming departures from the stop.
     - Throws: A `RejseplanenError` if an unexpected error occurs or the data cannot be retrieved.
     */
    public func departureBoard(ofType type: DepartureBoardType, forStop stop: Stop) async throws -> DepartureBoard {
        return try await self.departureBoardService.departureBoard(ofType: type, forStop: stop)
    }
    
    /**
     Fetches nearby stops based on a specified location.
     
     - Parameters:
     - location: The user's current `CLLocation`.
     - products: An optional list of `RejseplanenProduct` to filter the stops (e.g., bus, train).
     - maxRadius: An optional maximum radius (in meters) to limit the search area.
     - Returns: A `Stops` object containing nearby stops.
     - Throws: A `RejseplanenError` if an unexpected error occurs.
     */
    public func stopsNearby(location: CLLocation, products: [RejseplanenProduct]?, maxRadius: CLLocationDistance?) async throws -> Stops {
        // Rejseplanen doesn't seem to respect the maxCount (maxNumber in Rejseplanen terminology), so it's not exposed outside the package.
        return try await self.stopsNearbyService.stopsNearby(location: location, products: products, maxRadius: maxRadius, maxCount: nil)
    }
    
    public func trip() async throws {
        assert(false, "Trip is not implemented yet")
    }
    
    public func arrivalBoard() async throws {
        assert(false, "arrivalBoard is not implemented yet")
    }

    public func multiDepartureBoard() async throws {
        assert(false, "multiDepartureBoard is not implemented yet")
    }
    
}
