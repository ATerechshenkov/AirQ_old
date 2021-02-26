//
//  PageService.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 08.02.2021.
//

import Foundation

class PageService {
    static var defaultPages: [Page] {
        [
            Page(usesLocationServices: true),
            Page(location: Location(name: "Москва", latitude: 55.761590, longitude: 37.609460)),
            Page(location: Location(name: "Минск", latitude: 53.703799, longitude: 27.815592)),
            Page(location: Location(name: "Киев", latitude: 50.446125, longitude: 30.521498)),
            Page(location: Location(name: "Нур-Султан", latitude: 51.177256, longitude: 71.424042)),
            Page(location: Location(name: "Бишкек", latitude: 42.872352, longitude: 74.598986))
        ]
    }
    
    static func loadPages() throws -> [Page] {
        guard let pageData = UserDefaults.standard.object(forKey: "savedUserPages") as? Data else {
            throw NSError(domain: "kz.andruxa.stratus.page", code: 10, userInfo: nil)
        }
        return try JSONDecoder().decode([Page].self, from: pageData)
    }
    
    static func savePages(pages: [Page]) throws -> Bool {
        let pageData = try JSONEncoder().encode(pages)
        UserDefaults.standard.set(pageData, forKey: "savedUserPages")
        return true
    }
}
