//
//  Page.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 08.02.2021.
//

import Foundation
import CoreLocation

struct Page: Codable {
    var location: Location?
    var usesLocationServices: Bool = false
    var airQualityData: AirQualityData?
    
    var locationName: String {
        if let name = location?.name {
            return name
        }
        
        if let name = airQualityData?.stationName?.components(separatedBy: ",")[0] {
            return name.condenseWhitespace()
        }
        
        return "Location"
    }

    init(location: Location?, airQualityData: AirQualityData? = nil, usesLocationServices: Bool = false) {
        self.location = location
        self.airQualityData = airQualityData
        self.usesLocationServices = usesLocationServices
    }
    
    init(usesLocationServices: Bool = true) {
        self.init(location: nil, airQualityData: nil, usesLocationServices: usesLocationServices)
    }
}

struct Location: Codable {
    let name: String
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        get {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(name: String, _ coordinate: CLLocationCoordinate2D) {
        self.init(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
