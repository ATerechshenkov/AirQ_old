//
//  AQIModel.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 28.12.2020.
//

import Foundation
import UIKit

// MARK: AQI Model

struct AQIModel {
    var city: String?
    var cityName: String? {
        if let city = city {
            return String(city.prefix(while: { (char) -> Bool in char != "," }))
        }
        return nil
    }
    
    var aqi: Int?
    var aqiName: String? {
        if let level = aqi {
            return AQILevel.getAQILevel(forAQIValue: level).name
        }
        return nil
    }
    var aqiColor: UIColor? {
        if let level = aqi {
            return AQILevel.getAQILevel(forAQIValue: level).color
        }
        return nil
    }
    var aqiHealth: String? {
        if let level = aqi {
            return AQILevel.getAQILevel(forAQIValue: level).health
        }
        return nil
    }
    
    var pm25: Int?
    var pm10: Int?
    
    static func serialize(aqiData: AQIData?) -> AQIModel {
        var aqiModel = AQIModel()
        
        if let aqi = aqiData?.aqi {
            aqiModel.aqi = Int(aqi)
        }
        
        if let pm25 = aqiData?.iaqi?.pm25?.v {
            aqiModel.pm25 = Int(pm25)
        }
        
        if let pm10 = aqiData?.iaqi?.pm10?.v {
            aqiModel.pm10 = Int(pm10)
        }
 
        if let city = aqiData?.city?.name {
            aqiModel.city = String(city.prefix(while: { (char) -> Bool in char != "," }))
        }
        
        return aqiModel
    }
}

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

/* Response JSON example
{"status":"ok","data":{"aqi":298,"idx":12774,"attributions":[{"url":"https://kz.usembassy.gov/","name":"Almaty Air Quality Monitor - US Embassy","logo":"US-StateDepartment.png"},{"url":"https://www.kazhydromet.kz/en/","name":"Қазгидромет - Kazhydromet","logo":"Kazakhstan.hydromet.png"},{"url":"https://waqi.info/","name":"World Air Quality Index Project"}],"city":{"geo":[43.222,76.851],"name":"Almaty, US Embassy, Kazakhstan (Алматы, АҚШ елшілігі)","url":"https://aqicn.org/city/kazakhstan/almaty/us-embassy"},"dominentpol":"pm10","iaqi":{"co":{"v":47.9},"dew":{"v":-14},"h":{"v":85},"no2":{"v":49.7},"p":{"v":1033},"pm10":{"v":298},"pm25":{"v":274},"so2":{"v":2.3},"t":{"v":-12},"w":{"v":0.5}},"time":{"s":"2020-12-28 12:00:00","tz":"+06:00","v":1609156800,"iso":"2020-12-28T12:00:00+06:00"},"forecast":{"daily":{"o3":[{"avg":4,"day":"2020-12-26","max":9,"min":1},{"avg":4,"day":"2020-12-27","max":15,"min":1},{"avg":9,"day":"2020-12-28","max":20,"min":1},{"avg":8,"day":"2020-12-29","max":20,"min":2},{"avg":5,"day":"2020-12-30","max":14,"min":1},{"avg":6,"day":"2020-12-31","max":16,"min":1},{"avg":1,"day":"2021-01-01","max":6,"min":1}],"pm10":[{"avg":17,"day":"2020-12-26","max":31,"min":13},{"avg":29,"day":"2020-12-27","max":37,"min":21},{"avg":15,"day":"2020-12-28","max":26,"min":4},{"avg":16,"day":"2020-12-29","max":22,"min":4},{"avg":17,"day":"2020-12-30","max":21,"min":12},{"avg":8,"day":"2020-12-31","max":12,"min":4},{"avg":5,"day":"2021-01-01","max":9,"min":3},{"avg":5,"day":"2021-01-02","max":9,"min":3},{"avg":8,"day":"2021-01-03","max":17,"min":2}],"pm25":[{"avg":64,"day":"2020-12-26","max":98,"min":52},{"avg":92,"day":"2020-12-27","max":113,"min":72},{"avg":55,"day":"2020-12-28","max":86,"min":29},{"avg":59,"day":"2020-12-29","max":75,"min":28},{"avg":60,"day":"2020-12-30","max":71,"min":48},{"avg":38,"day":"2020-12-31","max":52,"min":28},{"avg":28,"day":"2021-01-01","max":40,"min":23},{"avg":29,"day":"2021-01-02","max":41,"min":23},{"avg":37,"day":"2021-01-03","max":64,"min":21}],"uvi":[{"avg":0,"day":"2020-12-26","max":1,"min":0},{"avg":0,"day":"2020-12-27","max":1,"min":0},{"avg":0,"day":"2020-12-28","max":1,"min":0},{"avg":0,"day":"2020-12-29","max":1,"min":0},{"avg":0,"day":"2020-12-30","max":1,"min":0},{"avg":0,"day":"2020-12-31","max":1,"min":0},{"avg":0,"day":"2021-01-01","max":1,"min":0}]}},"debug":{"sync":"2020-12-28T15:39:36+09:00"}}}
*/
