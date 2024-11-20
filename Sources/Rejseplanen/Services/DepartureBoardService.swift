//
//  DepartureBoardService.swift
//  
//
//  Created by Fredrik Nannestad on 09/11/2022.
//

import Foundation

// Helper struct to pass JSON from API - not used outside this file
private struct DepartureBoardContainer: Decodable {
    let departureBoard: DepartureBoard
    
    enum CodingKeys: String, CodingKey {
        case departureBoard = "DepartureBoard"
    }
}

internal class DepartureBoardService {
    
    func departureBoard(forStop stop: Stop) async throws -> DepartureBoard {
        let url = self.departureBoardURL(forStop: stop)
        debugPrint("Requesting Rejseplanen departure service: " + url.absoluteString)
        var departureBoard = try await self.departureBoard(url: url)
        departureBoard.stop = stop
        return departureBoard
    }
    
    private func departureBoardURL(forStop stop: Stop) -> URL {
        var components = URLComponents(string: rejseplanenBaseURLString + "departureBoard")!
        let queryItems = [URLQueryItem(name: "id", value: "\(stop.id)"),
                          URLQueryItem(name: "format", value: "json")]
        components.queryItems = queryItems
        return components.url!
    }
    
    private func departureBoard(url: URL) async throws -> DepartureBoard {

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw RejseplanenError.invalidServerResponse(response: response)
        }
        
        do {
            let container = try JSONDecoder().decode(DepartureBoardContainer.self, from: data)
            return container.departureBoard
        } catch let error as DecodingError {
            switch error {
            case .dataCorrupted(let context):
                print(context.codingPath.description)
            case .keyNotFound(let key, let context):
                print(context.underlyingError?.localizedDescription ?? "")
                print("Key not found: \(key)")
            case .valueNotFound(let type, let context):
                print(context.underlyingError?.localizedDescription ?? "")
                print("Type not found: \(type)")
            case .typeMismatch(let type, let context):
                print(context.codingPath.description)
                print("Type mismatch: \(type)")
            default:
                print("Default")
            }
            throw RejseplanenError.jsonDecoding(error: error)
        }
    }
    
}
