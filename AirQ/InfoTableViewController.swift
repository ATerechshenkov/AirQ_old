//
//  InfoTableViewController.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 10.01.2021.
//

import UIKit

class InfoTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AQILevel.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        
        cell.imageView?.image = UIImage(systemName: "app.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 36.0, weight: .regular))?.withTintColor(AQILevel.allCases[indexPath.row].color, renderingMode: .alwaysOriginal)
        
        let from: Int = indexPath.row == 0 ? 0 : AQILevel.allCases[indexPath.row-1].rawValue + 1
        let to: Int = AQILevel.allCases[indexPath.row].rawValue
        cell.textLabel?.text = String(format: "%d…%d %@", from, to, AQILevel.allCases[indexPath.row].name)
        
        cell.detailTextLabel?.text = AQILevel.allCases[indexPath.row].health
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.numberOfLines = 0

        return cell
    }
}
