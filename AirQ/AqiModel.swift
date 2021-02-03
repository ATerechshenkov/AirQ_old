//
//  AQIModel.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 28.12.2020.
//

import Foundation
import UIKit

protocol AqiModelDelegate {
    func aqiModelDidUpdate()
}

struct AqiModel {
    var city: String?
    var cityName: String? {
        if let city = city {
            return String(city.prefix(while: { (char) -> Bool in char != "," }))
        }
        return nil
    }
    
    var stationLatitude: Double?
    var stationLongitude: Double?
    
    var aqi: Int?
    var pm25: Int?
    var pm10: Int?
    
    var value: Int? {
        get {
            switch measure {
            case .aqi: return aqi
            case .pm25: return pm25
            case .pm10: return pm10
            case .none: return nil
            }
        }
        set {
            switch measure {
            case .aqi: self.aqi = newValue
            case .pm25: self.pm25 = newValue
            case .pm10: self.pm10 = newValue
            case .none: break
            }
        }
    }
    var measure: AQIMeasure?
    
    var name: String? {
        if let level = aqi, let measure = measure {
            return AQILevel.getLevel(level, measure: measure).rawValue
        }
        return nil
    }
    
    var color: UIColor? {
        if let level = value, let measure = measure {
            return AQILevel.getLevel(level, measure: measure).color
        }
        return nil
    }
    
    var health: String? {
        if let level = value, let measure = measure {
            return AQILevel.getLevel(level, measure: measure).health
        }
        return nil
    }
    
    init(_ aqiResponse: AQIResponseModel) {
        let data = aqiResponse.data
        
        if let aqi = data?.aqi {
            self.aqi = Int(aqi)
        }
        
        if let measure = data?.dominentpol {
            self.measure = AQIMeasure(rawValue: measure)
        }
        
        if let pm25 = data?.iaqi?.pm25?.v {
            self.pm25 = Int(pm25)
        }
        
        if let pm10 = data?.iaqi?.pm10?.v {
            self.pm10 = Int(pm10)
        }
 
        if let city = data?.city?.name {
            self.city = String(city.prefix(while: { (char) -> Bool in char != "," }))
        }
        
        if let latitude = data?.city?.geo?[0] {
            self.stationLatitude = Double(latitude)
        }
        
        if let longitude = data?.city?.geo?[1] {
            self.stationLongitude = Double(longitude)
        }
    }
}

enum AQIMeasure: String {
    case aqi
    case pm25
    case pm10
    
    var levels: [Int] {
        switch self {
        case .aqi:
            return AQILevel.allCases.map{ $0.aqi }
        case .pm25:
            return AQILevel.allCases.map{ $0.pm25 }
        case .pm10:
            return AQILevel.allCases.map{ $0.pm10 }
        }
    }
    
    var maxValue: Int {
        switch self {
        case .aqi:
            return AQILevel.hazardous.aqi
        case .pm25:
            return AQILevel.hazardous.pm25
        case .pm10:
            return AQILevel.hazardous.pm10
        }
    }
}

enum AQILevel: String, CaseIterable{
    case good = "Good"
    case moderate = "Moderate"
    case sensitive = "Unhealthy for Sensitive Groups"
    case unhealthy = "Unhealthy"
    case very_unhealthy = "Very Unhealthy"
    case hazardous = "Hazardous"
    
    var aqi: Int {
        switch self {
        case .good:
            return 50
        case .moderate:
            return 100
        case .sensitive:
            return 150
        case .unhealthy:
            return 200
        case .very_unhealthy:
            return 300
        case .hazardous:
            return 500
        }
    }
    
    var pm25: Int {
        switch self {
        case .good:
            return 30
        case .moderate:
            return 60
        case .sensitive:
            return 90
        case .unhealthy:
            return 120
        case .very_unhealthy:
            return 250
        case .hazardous:
            return 500
        }
    }
    
    var pm10: Int {
        switch self {
        case .good:
            return 50
        case .moderate:
            return 100
        case .sensitive:
            return 250
        case .unhealthy:
            return 350
        case .very_unhealthy:
            return 430
        case .hazardous:
            return 600
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
    
    static func getLevel(_ value: Int, measure: AQIMeasure) -> AQILevel {
        switch measure {
        case .aqi:
            return getLevel(forAqiValue: value)
        case .pm25:
            return getLevel(forPm25Value: value)
        case .pm10:
            return getLevel(forPm10Value: value)
        }
    }
    
    static func getLevel(forAqiValue value: Int) -> AQILevel {
        if value <= AQILevel.good.aqi {
            return AQILevel.good
        } else if value <= AQILevel.moderate.aqi {
            return AQILevel.moderate
        } else if value <= AQILevel.sensitive.aqi {
            return AQILevel.sensitive
        } else if value <= AQILevel.unhealthy.aqi {
            return AQILevel.unhealthy
        } else if value <= AQILevel.very_unhealthy.aqi {
            return AQILevel.very_unhealthy
        } else {
            return AQILevel.hazardous
        }
    }
    
    static func getLevel(forPm25Value value: Int) -> AQILevel {
        if value <= AQILevel.good.pm25 {
            return AQILevel.good
        } else if value <= AQILevel.moderate.pm25 {
            return AQILevel.moderate
        } else if value <= AQILevel.sensitive.pm25 {
            return AQILevel.sensitive
        } else if value <= AQILevel.unhealthy.pm25 {
            return AQILevel.unhealthy
        } else if value <= AQILevel.very_unhealthy.pm25 {
            return AQILevel.very_unhealthy
        } else {
            return AQILevel.hazardous
        }
    }
    
    static func getLevel(forPm10Value value: Int) -> AQILevel {
        if value <= AQILevel.good.pm10 {
            return AQILevel.good
        } else if value <= AQILevel.moderate.pm10 {
            return AQILevel.moderate
        } else if value <= AQILevel.sensitive.pm10 {
            return AQILevel.sensitive
        } else if value <= AQILevel.unhealthy.pm10 {
            return AQILevel.unhealthy
        } else if value <= AQILevel.very_unhealthy.pm10 {
            return AQILevel.very_unhealthy
        } else {
            return AQILevel.hazardous
        }
    }
}
