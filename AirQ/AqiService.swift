//
//  AQIService.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 02.01.2021.
//

import Foundation
import CoreLocation
import Alamofire

struct LocationError: Error {
    enum ErrorKind {
        case locationServiceDisabled
        case authorizationStatusDenied
        case authorizationStatusRestricted
        case zeroLocation
    }
    
    let kind: ErrorKind
    
    var message: String {
        switch self.kind {
        case .locationServiceDisabled:
            return "Location Services are Disabled. To enable it go: Settings -> Privacy -> Location Services and turn On"
        case .authorizationStatusDenied:
            return "Your location is not Availeble. To give permission Go to: Strrings -> AirQ -> Location"
        case .authorizationStatusRestricted:
            return "Restricted Authorization Status"
        case .zeroLocation:
            return "#NullIsland Either the latitude or longitude was exactly 0! That's highly unlikely"
        }
    }
}

class AqiService {
    static let shared = AqiService()
    
    let locationManager: CLLocationManager
    let almatyLocation = CLLocationCoordinate2D(latitude: 43.238233, longitude: 76.945363)
    
    let aqiToken = "73a2ab937afc2da4d44222c6205a7bcc838c1f62"
    let aqiFeedUrl = "https://api.waqi.info/feed/geo:%f;%f/"
    
    var aqiTilesUrl: String {
        "https://tiles.aqicn.org/tiles/usepa-aqi/{z}/{x}/{y}.png?token=" + "73a2ab937afc2da4d44222c6205a7bcc838c1f62"
    }
    
    init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func spotMyLocation() throws -> CLLocationCoordinate2D {
        try checkLocationAuthorization()
        guard let location = locationManager.location?.coordinate else {
            return almatyLocation
            //throw LocationError(kind: .zeroLocation)
        }
        return location
    }
    
    func checkLocationAuthorization() throws {
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError(kind: .locationServiceDisabled)
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return
        case .denied:
            throw LocationError(kind: .authorizationStatusDenied)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .restricted:
            debugPrint("")
            throw LocationError(kind: .authorizationStatusRestricted)
        @unknown default:
            debugPrint("Unknown Authorization Status")
            return
        }
    }
    
    func fetchAqiData(byLocation coordinate: CLLocationCoordinate2D, successHandler: @escaping (AqiModel) -> Void, errorHandler: @escaping (Error) -> Void ) {
        guard let url = URL(string: String(format: aqiFeedUrl, coordinate.latitude, coordinate.longitude)) else { return }

        AF.request(url, method: .get, parameters: ["token": aqiToken]).validate(statusCode: 200..<300).responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    let aqiResponse = try JSONDecoder().decode(AQIResponseModel.self, from: data)
                    successHandler(AqiModel(aqiResponse))
                } catch let error {
                    debugPrint("Decode error", error)
                    errorHandler(error)
                }
            case .failure(let error):
                debugPrint("Request Error", error)
                errorHandler(error)
            }
        }
    }
}


