//
//  AQIService.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 02.01.2021.
//

import Foundation
import CoreLocation
import Alamofire

struct AqiServiceError: Error {
    enum ErrorKind {
        case locationServiceDisabled
        case authorizationStatusDenied
        case authorizationStatusRestricted
    }
    
    let alert: String
    let message: String
    let kind: ErrorKind
}

class AqiService {
    static let shared = AqiService()
    
    let locationManager: CLLocationManager
    
    let aqiToken = "73a2ab937afc2da4d44222c6205a7bcc838c1f62"
    let aqiFeedUrl = "https://api.waqi.info/feed/geo:%f;%f/"
    
    var aqiTilesUrl: String {
        "https://tiles.aqicn.org/tiles/usepa-aqi/{z}/{x}/{y}.png?token=" + "73a2ab937afc2da4d44222c6205a7bcc838c1f62"
    }
    
    init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestAqiData(byLocation coordinate: CLLocationCoordinate2D, successHandler: @escaping (AqiModel) -> Void, errorHandler: @escaping (Error) -> Void ) {
        let parameters = ["token": aqiToken]
        let url = URL(string: String(format: aqiFeedUrl, coordinate.latitude, coordinate.longitude))!
        
        AF.request(url, method: .get, parameters: parameters).validate(statusCode: 200..<300).responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    let aqiResponse = try JSONDecoder().decode(AQIResponseModel.self, from: data)
                    DispatchQueue.main.async {
                        successHandler(AqiModel(aqiResponse))
                    }
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
    
    func getCurrentLocation() throws -> CLLocationCoordinate2D? {
        try checkLocationAuthorization()
        return locationManager.location?.coordinate
    }
    
    func checkLocationAuthorization() throws {
        guard CLLocationManager.locationServicesEnabled() else {
            throw AqiServiceError(alert: "Location Services are Disabled",
                                       message: "To enable it go: Settings -> Privacy -> Location Services and turn On",
                                       kind: .locationServiceDisabled)
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return
        case .denied:
            throw AqiServiceError(alert: "Your location is not Availeble",
                                       message: "To give permission Go to: Strrings -> AirQ -> Location",
                                       kind: .locationServiceDisabled)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .restricted:
            debugPrint("Restricted Authorization Status")
            return
        @unknown default:
            debugPrint("Unknown Authorization Status")
            return
        }
    }
}


