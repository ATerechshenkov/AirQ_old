//
//  AQIService.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 02.01.2021.
//

import Foundation

class HTTPService {
    let aqiURL = "https://api.waqi.info/feed/"
    let aqiToken = "73a2ab937afc2da4d44222c6205a7bcc838c1f62"
    
    func fetchAQIData(completionHandler: @escaping (AQIModel?) -> Void) {
      let url = URL(string: aqiURL + "almaty/?token=73a2ab937afc2da4d44222c6205a7bcc838c1f62")!
      
      let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
        if let error = error {
          print("Error with fetching AQIData: \(error)")
          return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
          print("Error with the response, unexpected status code: \(String(describing: response))")
          return
        }

        if let data = data,
          let aqiResponse = try? JSONDecoder().decode(AQIResponse.self, from: data) {
            completionHandler(AQIModel.serialize(aqiData: aqiResponse.data))
        }
      })
      task.resume()
    }
}
