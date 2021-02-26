//
//  AllertService.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 10.02.2021.
//

import Foundation
import UIKit

protocol UserAllert: Error {
    var title: String { get }
    var message: String? { get }
}

extension UIViewController {
    
    func showAllert(_ error: Error) {
        if let error = error as? UserAllert {
            showAllert(error.title, message: error.message, style: .alert)
        } else {
            showAllert("Error", message: error.localizedDescription)
        }
    }
    
    func showAllert(_ title: String, message: String? = nil, style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.present(alert, animated: true)
        }
    }
}
