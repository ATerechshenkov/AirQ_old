//
//  AQIService.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 02.01.2021.
//

import Foundation
import Alamofire
import CoreLocation

struct NetworkAllert: UserAllert {
    enum ErrorKind {
        case noInternetConnection // Alamofire.AFError.sessionTaskFailed
        case requestError(couse: String)
        case responseError(couse: String)
    }
    
    let kind: ErrorKind
    
    var title: String {
        switch self.kind {
        case .noInternetConnection:
            return "No Internet connection"
        case .requestError:
            return "Request data error"
        case .responseError:
            return "Data retrieval error"
        }
    }
    
    var message: String? {
        switch self.kind {
        case .noInternetConnection:
            return "Please check your connection and try again"
        case .requestError:
            return "Please try again later"
        case .responseError:
            return "Please try again later"
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    
    // TODO: Вынести в конфигурационный файл
    let aqiToken = "73a2ab937afc2da4d44222c6205a7bcc838c1f62"
    let aqiFeedUrl = "https://api.waqi.info/feed/geo:%f;%f/"
    static var aqiTilesUrl: String {
        "https://tiles.aqicn.org/tiles/usepa-aqi/{z}/{x}/{y}.png?token=73a2ab937afc2da4d44222c6205a7bcc838c1f62"
    }
    
    func fetchAqiData(byLocation coordinate: CLLocationCoordinate2D, successHandler: @escaping (AirQualityData) -> Void, errorHandler: @escaping (Error) -> Void ) {
        guard NetworkReachabilityManager()?.isReachable ?? false else {
            errorHandler(NetworkAllert(kind: .noInternetConnection))
            return
        }
        
        guard let url = URL(string: String(format: aqiFeedUrl, coordinate.latitude, coordinate.longitude)) else { return }
        
        AF.request(url, method: .get, parameters: ["token": aqiToken]).validate(statusCode: 200..<300).responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    debugPrint("Request: ", url, "\nResponse:\n", String(decoding: data, as: UTF8.self))
                    if let aqiResponse = try? JSONDecoder().decode(AQIResponse.self, from: data) {
                        successHandler(AirQualityData(aqiResponse.data))
                    } else if let aqiResponseError = try? JSONDecoder().decode(AQIResponseError.self, from: data) {
                        throw NetworkAllert(kind: .responseError(couse: aqiResponseError.data))
                    }
                } catch let error {
                    debugPrint(error)
                    errorHandler(error)
                }
            case .failure(let error):
                debugPrint(error)
                errorHandler(error)
            }
        }
    }
    
    func fetchAqiData2(byLocation coordinate: CLLocationCoordinate2D, successHandler: @escaping (AirQualityData) -> Void, errorHandler: @escaping (Error) -> Void ) {
        
        guard NetworkReachabilityManager()?.isReachable ?? false else {
            errorHandler(NetworkAllert(kind: .noInternetConnection))
            return
        }
        
        
        let strUrl = String(format: aqiFeedUrl, coordinate.latitude, coordinate.longitude)
        guard let url = URL(string: strUrl) else {
            errorHandler(NetworkAllert(kind: .requestError(couse: "URL error. URL: \(strUrl)")))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                errorHandler(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                errorHandler(NetworkAllert(kind: .responseError(couse: response.debugDescription)))
                return
            }
            
            if let data = data {
                do {
                    debugPrint("Request: ", url, "\nResponse:\n", String(decoding: data, as: UTF8.self))
                    if let aqiResponse = try? JSONDecoder().decode(AQIResponse.self, from: data) {
                        successHandler(AirQualityData(aqiResponse.data))
                    } else if let aqiResponseError = try? JSONDecoder().decode(AQIResponseError.self, from: data) {
                        throw NetworkAllert(kind: .responseError(couse: aqiResponseError.data))
                    }
                } catch let error {
                    debugPrint(error)
                    errorHandler(error)
                }
            }
        }
        
        task.resume()
    }
}


