//
//  AQIModel.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 28.12.2020.
//

import Foundation
import UIKit

// MARK: AQI Model

enum AQILevel: Int, CaseIterable{
    case good = 50
    case moderate = 100
    case sensitive = 150
    case unhealthy = 200
    case very_unhealthy = 300
    case hazardous = 500
    
    var name: String {
        switch self {
        case .good:
            return "Good"
        case .moderate:
            return "Moderate"
        case .sensitive:
            return "Unhealthy for Sensitive Groups"
        case .unhealthy:
            return "Unhealthy"
        case .very_unhealthy:
            return "Very Unhealthy"
        case .hazardous:
            return "Hazardous"
        }
    }
    
    var color: UIColor {
        switch self {
        case .good:
            return #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
        case .moderate:
            return #colorLiteral(red: 1, green: 0.9855536819, blue: 0, alpha: 1)
        case .sensitive:
            return #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        case .unhealthy:
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case .very_unhealthy:
            return #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)
        case .hazardous:
            return #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        }
    }
    
    var health: String {
        switch self {
        case .good:
            return "Air quality is considered satisfactory, and air pollution poses little or no risk."
        case .moderate:
            return "Air quality is acceptable; however, for some pollutants there may be a moderate health concern for a very small number of people who are unusually sensitive to air pollution."
        case .sensitive:
            return "Members of sensitive groups may experience health effects. The general public is not likely to be affected."
        case .unhealthy:
            return "Everyone may begin to experience health effects; members of sensitive groups may experience more serious health effects."
        case .very_unhealthy:
            return "Health warnings of emergency conditions. The entire population is more likely to be affected."
        case .hazardous:
            return "Health alert: everyone may experience more serious health effects."
        }
    }
    
    var warning: String {
        switch self {
        case .good:
            return ""
        case .moderate:
            return "Active children and adults, and people with respiratory disease, such as asthma, should limit prolonged outdoor exertion."
        case .sensitive:
            return "Active children and adults, and people with respiratory disease, such as asthma, should limit prolonged outdoor exertion."
        case .unhealthy:
            return "Active children and adults, and people with respiratory disease, such as asthma, should avoid prolonged outdoor exertion; everyone else, especially children, should limit prolonged outdoor exertion"
        case .very_unhealthy:
            return "Active children and adults, and people with respiratory disease, such as asthma, should avoid all outdoor exertion; everyone else, especially children, should limit outdoor exertion."
        case .hazardous:
            return "Everyone should avoid all outdoor exertion."
        }
    }
    
    static func getAQILevel(forAQIValue value: Int) -> AQILevel {
        if value <= AQILevel.good.rawValue {
            return AQILevel.good
        } else if value <= AQILevel.moderate.rawValue {
            return AQILevel.moderate
        } else if value <= AQILevel.sensitive.rawValue {
            return AQILevel.sensitive
        } else if value <= AQILevel.unhealthy.rawValue {
            return AQILevel.unhealthy
        } else if value <= AQILevel.very_unhealthy.rawValue {
            return AQILevel.very_unhealthy
        } else {
            return AQILevel.hazardous
        }
    }
}

// MARK: JSON Model

struct AQIResponse: Codable {
    var status: String?
    var data: AQIData?
}

struct AQIData: Codable {
    var aqi: Int?
    var idx: Int?
    var attributions: [AQIAttribute]?
    var city: AQICity?
    var dominentpol: String?
    var iaqi: AQIMetrics?
    var time: AQITime?
}

struct AQICity: Codable {
    var geo: [Double]?
    var name: String?
    var url: String?
}

struct AQIAttribute: Codable {
    var url: String?
    var name: String?
    var logo: String?
}

struct AQIMetrics: Codable {
    var pm25: AQIValue?     // PM 2.5
    var pm10: AQIValue?     // PM 10
    var o3: AQIValue?       // Ozone
    var no2: AQIValue?      // Nitrogen Dioxide
    var so2: AQIValue?      // Sulphur Dioxide
    var co: AQIValue?       // Carbon Monoxyde
    var t: AQIValue?        // Temperature
    var p: AQIValue?        // Atmostpheric Pressure
    var dew: AQIValue?      // Dew
    var rain: AQIValue?     // Rain (precipitation)
    var h: AQIValue?        // Relative Humidity
    var w: AQIValue?        // Wind speed
}

struct AQIValue: Codable {
    var v: Double?
}

struct AQITime: Codable {
    var s: String?
    var tz: String?
    var v: Int32?
    var iso: String?
}

struct AQIForecast: Codable {
    var daily: [AQIDaily]?
    var debug: String?
}

struct AQIDaily: Codable {
    var o3: [AQIDailyMetrics]?
    var pm10: [AQIDailyMetrics]?
    var pm25: [AQIDailyMetrics]?
    var uvi: [AQIDailyMetrics]?
}

struct AQIDailyMetrics: Codable {
    var avg: Double?
    var day: String?
    var max: Double?
    var min: Double?
}
