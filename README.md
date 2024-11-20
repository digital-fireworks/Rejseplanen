# Rejseplanen

![Swift](https://img.shields.io/badge/Swift-5.7-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20-lightgrey.svg)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

Rejseplanen is a Swift package for integrating with the Danish public transportation Rejseplanen API. It provides functionality for fetching location data, stops, nearby stations, and departure boards, making it easy to build apps that leverage public transportation data.

## Features

- Query addresses, POIs, and stops with `LocationService`.
- Get nearby stops and stations for specific products (e.g., trains, buses, metros) using `StopsNearbyService`.
- Fetch departure boards for a given stop with `DepartureBoardService`.

### Files Overview

- **Rejseplanen.swift**: Main interface for the package.
- **LocationService.swift**: Query addresses, POIs, and stops based on a string.
- **StopsNearbyService.swift**: Obtain stops and stations near a location for selected transportation products.
- **DepartureBoardService.swift**: Retrieve departures for a given stop.

## Requirements

- Swift 5.7+
- iOS 13.0+, macOS 10.15+, tvOS 13.0+, watchOS 6.0+

## Installation

### Using Swift Package Manager in Xcode

1. Open your project in Xcode.
2. Go to `File` > `Add Packages`.
3. In the search bar, paste the repository URL: `https://github.com/digital-fireworks/Rejseplanen`
4. Choose the `main` branch or the desired version.
5. Click `Add Package`.

The package will now be available in your project.

## Usage

### Importing the Package

Import `Rejseplanen` at the top of your Swift file:

```swift
import Rejseplanen
```

In Xcode you might need to select `File` > `Packages` > `Resolve package versions` before building the project. 
