import XCTest
@testable import Rejseplanen

import CoreLocation

final class RejseplanenTests: XCTestCase {
    
    let rejseplanen = Rejseplanen()
    
    func testLocation01() async throws {
        let locations = try await self.rejseplanen.location(query: "Århus")
        locations.stops.forEach { print($0.description) }
        locations.addresses.forEach { print($0.description) }
        locations.pointsOfInterest.forEach { print($0.description) }
    }
    
    func testStopsNearby01() async throws {
        let location = CLLocation(latitude: 56.150444, longitude: 10.204761)
        let stops = try await self.rejseplanen.stopsNearby(location: location, products: RejseplanenProduct.trains, maxRadius: 200)
        stops.forEach { print($0.description) }
    }
    
    func testDepartureBoard01() async throws {
        let stop = Stop(id: "008600626", name: "København H", x: 12.565562, y: 55.673063)
        let departureBoard = try await self.rejseplanen.departureBoard(ofType: .all, forStop: stop)
        departureBoard.departures.forEach { print($0.description) }
    }
    
   
}
