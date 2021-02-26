//
//  MapViewController.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 18.01.2021.
//

import MapKit
import UIKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    let locationService = LocationService.shared
    
    var tileRenderer: MKTileOverlayRenderer!
    let regionInMetars = 10_000.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationManager()
        initMapView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.moveToUserLocation()
        }
    }
    
    @IBAction func moveToUserLocation() {
        do {
            let coordinate = try locationService.spotMyLocation()
            let region = MKCoordinateRegion(center: coordinate,
                                            latitudinalMeters: regionInMetars,
                                            longitudinalMeters: regionInMetars)
            mapView.setRegion(region, animated: true)
        } catch let error as LocationAllert {
            showAllert(error)
        } catch let error {
            showAllert(error)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func initMapView() {
        let overlay = MKTileOverlay(urlTemplate: NetworkService.aqiTilesUrl)
        self.mapView.addOverlay(overlay, level: .aboveLabels)
        tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return tileRenderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func initLocationManager() {
        locationService.locationManager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        do {
            try locationService.locationServicesEnabled()
        } catch let error {
            debugPrint(error)
            showAllert(error)
        }
    }
    
    func showAllert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.present(alert, animated: true)
        }
    }
}
