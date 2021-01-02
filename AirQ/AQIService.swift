//
//  AQIService.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 02.01.2021.
//

import Foundation

class AQIService {
    // TODO: Реализовать загрузку данных по городам. Пока заглушка данных по Алматы.
    let aqiURL = "https://api.waqi.info/feed/"
    let aqiToken = "73a2ab937afc2da4d44222c6205a7bcc838c1f62"
    static let aqiResponse = """
    {"status":"ok","data":{"aqi":298,"idx":12774,"attributions":[{"url":"https://kz.usembassy.gov/","name":"Almaty Air Quality Monitor - US Embassy","logo":"US-StateDepartment.png"},{"url":"https://www.kazhydromet.kz/en/","name":"Қазгидромет - Kazhydromet","logo":"Kazakhstan.hydromet.png"},{"url":"https://waqi.info/","name":"World Air Quality Index Project"}],"city":{"geo":[43.222,76.851],"name":"Almaty, US Embassy, Kazakhstan (Алматы, АҚШ елшілігі)","url":"https://aqicn.org/city/kazakhstan/almaty/us-embassy"},"dominentpol":"pm10","iaqi":{"co":{"v":47.9},"dew":{"v":-14},"h":{"v":85},"no2":{"v":49.7},"p":{"v":1033},"pm10":{"v":298},"pm25":{"v":274},"so2":{"v":2.3},"t":{"v":-12},"w":{"v":0.5}},"time":{"s":"2020-12-28 12:00:00","tz":"+06:00","v":1609156800,"iso":"2020-12-28T12:00:00+06:00"},"forecast":{"daily":{"o3":[{"avg":4,"day":"2020-12-26","max":9,"min":1},{"avg":4,"day":"2020-12-27","max":15,"min":1},{"avg":9,"day":"2020-12-28","max":20,"min":1},{"avg":8,"day":"2020-12-29","max":20,"min":2},{"avg":5,"day":"2020-12-30","max":14,"min":1},{"avg":6,"day":"2020-12-31","max":16,"min":1},{"avg":1,"day":"2021-01-01","max":6,"min":1}],"pm10":[{"avg":17,"day":"2020-12-26","max":31,"min":13},{"avg":29,"day":"2020-12-27","max":37,"min":21},{"avg":15,"day":"2020-12-28","max":26,"min":4},{"avg":16,"day":"2020-12-29","max":22,"min":4},{"avg":17,"day":"2020-12-30","max":21,"min":12},{"avg":8,"day":"2020-12-31","max":12,"min":4},{"avg":5,"day":"2021-01-01","max":9,"min":3},{"avg":5,"day":"2021-01-02","max":9,"min":3},{"avg":8,"day":"2021-01-03","max":17,"min":2}],"pm25":[{"avg":64,"day":"2020-12-26","max":98,"min":52},{"avg":92,"day":"2020-12-27","max":113,"min":72},{"avg":55,"day":"2020-12-28","max":86,"min":29},{"avg":59,"day":"2020-12-29","max":75,"min":28},{"avg":60,"day":"2020-12-30","max":71,"min":48},{"avg":38,"day":"2020-12-31","max":52,"min":28},{"avg":28,"day":"2021-01-01","max":40,"min":23},{"avg":29,"day":"2021-01-02","max":41,"min":23},{"avg":37,"day":"2021-01-03","max":64,"min":21}],"uvi":[{"avg":0,"day":"2020-12-26","max":1,"min":0},{"avg":0,"day":"2020-12-27","max":1,"min":0},{"avg":0,"day":"2020-12-28","max":1,"min":0},{"avg":0,"day":"2020-12-29","max":1,"min":0},{"avg":0,"day":"2020-12-30","max":1,"min":0},{"avg":0,"day":"2020-12-31","max":1,"min":0},{"avg":0,"day":"2021-01-01","max":1,"min":0}]}},"debug":{"sync":"2020-12-28T15:39:36+09:00"}}}
    """
    
    func fetchAQIData(completionHandler: @escaping (AQIData?) -> Void) {
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
            completionHandler(aqiResponse.data)
        }
      })
      task.resume()
    }
}
