//
//  LocationService.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 10.02.2021.
//

import Foundation
import CoreLocation

struct LocationAllert: UserAllert {
    enum ErrorKind {
        case locationServiceDisabled
        case authorizationStatusDenied
        case authorizationStatusRestricted
        case zeroLocation
    }
    
    let kind: ErrorKind
    
    var title: String {
        switch self.kind {
        case .locationServiceDisabled:
            return "Location Services are Disabled"
        case .authorizationStatusDenied:
            return "Your location is not Availeble"
        case .authorizationStatusRestricted:
            return "Restricted Authorization Status"
        case .zeroLocation:
            return "#NullIsland Either the latitude or longitude was exactly 0! That's highly unlikely"
        }
    }
    
    var message: String? {
        switch self.kind {
        case .locationServiceDisabled:
            return "Location Services are Disabled. To enable it go: Settings -> Privacy -> Location Services and turn On"
        case .authorizationStatusDenied:
            return "Your location is not Availeble. To give permission Go to: Strrings -> AirQ -> Location"
        case .authorizationStatusRestricted:
            return nil
        case .zeroLocation:
            return "#NullIsland Either the latitude or longitude was exactly 0! That's highly unlikely"
        }
    }
}


class LocationService {
    static let shared = LocationService()
    
    let locationManager: CLLocationManager
    let almatyLocation = CLLocationCoordinate2D(latitude: 43.238233, longitude: 76.945363) // Only for test
    
    init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func spotMyLocation() throws -> CLLocationCoordinate2D {
        try locationServicesEnabled()
        guard let location = locationManager.location?.coordinate else {
            return almatyLocation
            //throw LocationError(kind: .zeroLocation)
        }
        return location
    }
    
    func locationServicesEnabled() throws {
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationAllert(kind: .locationServiceDisabled)
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return
        case .denied:
            throw LocationAllert(kind: .authorizationStatusDenied)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .restricted:
            debugPrint("")
            throw LocationAllert(kind: .authorizationStatusRestricted)
        @unknown default:
            debugPrint("Unknown Authorization Status")
            return
        }
    }
}


