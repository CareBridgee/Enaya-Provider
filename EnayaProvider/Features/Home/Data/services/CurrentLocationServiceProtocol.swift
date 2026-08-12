//
//  CurrentLocationServiceProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//
import Foundation
import CoreLocation

protocol CurrentLocationServiceProtocol {
    func getCurrentLocation() async throws -> CLLocationCoordinate2D
}

final class CurrentLocationService: NSObject, CurrentLocationServiceProtocol, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    private var authContinuation: CheckedContinuation<Void, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            
            await withCheckedContinuation { continuation in
                self.authContinuation = continuation
            }
        }
        
        guard manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways else {
            throw NSError(domain: "LocationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location unauthorized"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .notDetermined {
            authContinuation?.resume()
            authContinuation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("📍 [LocationService] Current Location Fetched -> Lat: \(location.coordinate.latitude), Lng: \(location.coordinate.longitude)")
        
        locationContinuation?.resume(returning: location.coordinate)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
