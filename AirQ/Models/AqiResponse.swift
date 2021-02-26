//
//  AqiResponseModel.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 24.01.2021.
//

import Foundation

struct AQIResponseError: Codable {
    var status: String
    var data: String
}

struct AQIResponse: Codable {
    var status: String
    var data: AQIData
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
    var aqi: AQIValue?     // AQI
    var pm25: AQIValue?     // PM 2.5
    var pm10: AQIValue?     // PM 10
    var pm1: AQIValue?      // PM 1
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

// MARK: Response JSON example
/*
 {
     "status": "ok",
     "data": {
         "aqi": 61,
         "idx": 12774,
         "attributions": [
             {
                 "url": "https://kz.usembassy.gov/",
                 "name": "Almaty Air Quality Monitor - US Embassy",
                 "logo": "US-StateDepartment.png"
             },
             {
                 "url": "https://www.kazhydromet.kz/en/",
                 "name": "Қазгидромет - Kazhydromet",
                 "logo": "Kazakhstan.hydromet.png"
             },
             {
                 "url": "https://waqi.info/",
                 "name": "World Air Quality Index Project"
             }
         ],
         "city": {
             "geo": [
                 43.222,
                 76.851
             ],
             "name": "Almaty, US Embassy, Kazakhstan (Алматы, АҚШ елшілігі)",
             "url": "https://aqicn.org/city/kazakhstan/almaty/us-embassy"
         },
         "dominentpol": "pm25",
         "iaqi": {
             "co": {
                 "v": 6.1
             },
             "dew": {
                 "v": -13
             },
             "h": {
                 "v": 78
             },
             "no2": {
                 "v": 20.7
             },
             "p": {
                 "v": 1031
             },
             "pm10": {
                 "v": 51
             },
             "pm25": {
                 "v": 61
             },
             "so2": {
                 "v": 1.9
             },
             "t": {
                 "v": -10
             },
             "w": {
                 "v": 1
             },
             "wg": {
                 "v": 6.6
             }
         },
         "time": {
             "s": "2021-01-14 18:00:00",
             "tz": "+06:00",
             "v": 1610647200,
             "iso": "2021-01-14T18:00:00+06:00"
         },
         "forecast": {
             "daily": {
                 "o3": [
                     {
                         "avg": 7,
                         "day": "2021-01-12",
                         "max": 21,
                         "min": 1
                     },
                     {
                         "avg": 7,
                         "day": "2021-01-13",
                         "max": 15,
                         "min": 3
                     },
                     {
                         "avg": 5,
                         "day": "2021-01-14",
                         "max": 11,
                         "min": 2
                     },
                     {
                         "avg": 12,
                         "day": "2021-01-15",
                         "max": 22,
                         "min": 4
                     },
                     {
                         "avg": 16,
                         "day": "2021-01-16",
                         "max": 28,
                         "min": 4
                     },
                     {
                         "avg": 6,
                         "day": "2021-01-17",
                         "max": 16,
                         "min": 1
                     },
                     {
                         "avg": 4,
                         "day": "2021-01-18",
                         "max": 12,
                         "min": 4
                     }
                 ],
                 "pm10": [
                     {
                         "avg": 8,
                         "day": "2021-01-12",
                         "max": 13,
                         "min": 3
                     },
                     {
                         "avg": 11,
                         "day": "2021-01-13",
                         "max": 18,
                         "min": 3
                     },
                     {
                         "avg": 11,
                         "day": "2021-01-14",
                         "max": 14,
                         "min": 8
                     },
                     {
                         "avg": 17,
                         "day": "2021-01-15",
                         "max": 22,
                         "min": 11
                     },
                     {
                         "avg": 10,
                         "day": "2021-01-16",
                         "max": 13,
                         "min": 6
                     },
                     {
                         "avg": 22,
                         "day": "2021-01-17",
                         "max": 31,
                         "min": 12
                     },
                     {
                         "avg": 20,
                         "day": "2021-01-18",
                         "max": 29,
                         "min": 18
                     },
                     {
                         "avg": 18,
                         "day": "2021-01-19",
                         "max": 21,
                         "min": 13
                     },
                     {
                         "avg": 15,
                         "day": "2021-01-20",
                         "max": 18,
                         "min": 12
                     }
                 ],
                 "pm25": [
                     {
                         "avg": 35,
                         "day": "2021-01-12",
                         "max": 53,
                         "min": 21
                     },
                     {
                         "avg": 37,
                         "day": "2021-01-13",
                         "max": 56,
                         "min": 23
                     },
                     {
                         "avg": 44,
                         "day": "2021-01-14",
                         "max": 53,
                         "min": 29
                     },
                     {
                         "avg": 63,
                         "day": "2021-01-15",
                         "max": 75,
                         "min": 47
                     },
                     {
                         "avg": 28,
                         "day": "2021-01-16",
                         "max": 37,
                         "min": 24
                     },
                     {
                         "avg": 61,
                         "day": "2021-01-17",
                         "max": 75,
                         "min": 29
                     },
                     {
                         "avg": 61,
                         "day": "2021-01-18",
                         "max": 73,
                         "min": 53
                     },
                     {
                         "avg": 60,
                         "day": "2021-01-19",
                         "max": 71,
                         "min": 52
                     },
                     {
                         "avg": 58,
                         "day": "2021-01-20",
                         "max": 67,
                         "min": 47
                     }
                 ],
                 "uvi": [
                     {
                         "avg": 0,
                         "day": "2021-01-12",
                         "max": 2,
                         "min": 0
                     },
                     {
                         "avg": 0,
                         "day": "2021-01-13",
                         "max": 1,
                         "min": 0
                     },
                     {
                         "avg": 0,
                         "day": "2021-01-14",
                         "max": 2,
                         "min": 0
                     },
                     {
                         "avg": 0,
                         "day": "2021-01-15",
                         "max": 2,
                         "min": 0
                     },
                     {
                         "avg": 0,
                         "day": "2021-01-16",
                         "max": 2,
                         "min": 0
                     },
                     {
                         "avg": 0,
                         "day": "2021-01-17",
                         "max": 2,
                         "min": 0
                     },
                     {
                         "avg": 0,
                         "day": "2021-01-18",
                         "max": 1,
                         "min": 0
                     },
                     {
                         "avg": 0,
                         "day": "2021-01-19",
                         "max": 0,
                         "min": 0
                     }
                 ]
             }
         },
         "debug": {
             "sync": "2021-01-14T22:28:06+09:00"
         }
     }
*/
