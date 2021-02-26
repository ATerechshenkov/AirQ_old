//
//  ViewController.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 27.12.2020.
//

import UIKit
import CoreLocation

class CityViewController: UIViewController {

    var page: Page!
    var data: AirQualityData! {
        get {
            page.airQualityData
        }
        set {
            page.airQualityData = newValue
        }
    }
    var location: Location! {
        get {
            page.location
        }
    }
    var smog: CGFloat {
        if let data = self.page.airQualityData {
            return CGFloat(data.value ?? 0) / CGFloat(data.measure!.maxValue)
        }
        return CGFloat(0)
    }
    var smogDelegate: SmogDelegate?
    
    let networkService = NetworkService.shared
    let locationService = LocationService.shared
    
    @IBOutlet var smogImage: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var levelNameLabel: UILabel!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var levelValueLabel: UILabel!
    
    @IBOutlet var measureAQIButton: UIButton!
    @IBOutlet var measurePM10Button: UIButton!
    @IBOutlet var measurePM25Button: UIButton!
    
    @IBOutlet var levelSlider: UISlider!
    @IBOutlet var stationButton: UIButton!
    @IBOutlet var stationNameLabel: UILabel!
    @IBOutlet var aqiLevelHealthLabel: UILabel!
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        
        initView()
        loadingDataInProcess(inProcess: true)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            do {
                let coordinate = self.page.usesLocationServices ? try self.locationService.spotMyLocation() : self.location.coordinate
                print("CITY " + self.page.locationName.uppercased())
                self.updateData(coordinate)
            } catch let error {
                debugPrint(error)
                self.showAllert(error)
            }
        }
    }
    
    func initView() {
        smogImage.alpha = 0.0
        cityLabel.text = page.locationName
        levelNameLabel.text = ""
        infoButton.isHidden = true
        levelValueLabel.text = "_ _"
        
        measureAQIButton.isHidden = true
        measurePM10Button.isHidden = true
        measurePM25Button.isHidden = true
        
        levelSlider.isHidden = true
        stationButton.isHidden = true
        stationNameLabel.text = ""
        aqiLevelHealthLabel.text = ""
    }
    
    private func updateData(_ coordinate: CLLocationCoordinate2D) {
        networkService.fetchAqiData(byLocation: coordinate) { [weak self] (model) in
            guard let self = self else { return }
                
            self.page.airQualityData = model
            
            self.redrawView()
            self.loadingDataInProcess(inProcess: false)
        } errorHandler: { [weak self] (error) in
            guard let self = self else { return }
            self.loadingDataInProcess(inProcess: false)
            self.showAllert(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        smogDelegate?.setSmogValue(smog)
    }
    
    private func loadingDataInProcess(inProcess: Bool) {
        if inProcess {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func redrawView() {
        infoButton.isHidden = false
        stationButton.isHidden = false
        levelSlider.isHidden = false
        
        cityLabel.text = page.locationName
        stationNameLabel.text = data.stationName
        aqiLevelHealthLabel.text = data.health
        
        changeMeasure(self.data.measure ?? .pm25)
    
        smogDelegate?.setSmogValue(smog)
    }
    
    @IBAction func onSlider(_ sender: Any) {
        page.airQualityData?.pm25 = Int(levelSlider.value)
        redrawView()
    }
    
    @IBAction func onAQIButtonClick(_ sender: Any) {
        changeMeasure(.aqi)
    }
    
    @IBAction func onPM10ButtonClick(_ sender: Any) {
        changeMeasure(.pm10)
    }

    @IBAction func onPM25ButtonClick(_ sender: Any) {
        changeMeasure(.pm25)
    }
    
    private func changeMeasure(_ measure: AQIMeasure) {
        data.measure = measure
        
        measureAQIButton.isHidden = data.aqi == nil
        measurePM10Button.isHidden = data.pm10 == nil
        measurePM25Button.isHidden = data.pm25 == nil
        
        measureAQIButton.isHighlighted = true
        measurePM10Button.isHighlighted = true
        measurePM25Button.isHighlighted = true
        
        switch measure {
        case .aqi:
            measureAQIButton.isHighlighted = false
        case .pm10:
            measurePM10Button.isHighlighted = false
        case .pm25:
            measurePM25Button.isHighlighted = false
        }
        
        levelNameLabel.text = data.level
        levelValueLabel.text = String(data.value ?? 0)
        
        levelSlider.value = Float(data.value ?? 0)
        levelSlider.thumbTintColor = data.color

        drawGradientScale(measure)
    }
    
    private func drawGradientScale(_ measure: AQIMeasure) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = CGRect.init(x:0, y:0, width: levelSlider.frame.size.width, height:16)
        gradientLayer.cornerRadius = gradientLayer.frame.height / 2
        
        gradientLayer.colors = AQILevel.allCases.map({ (level) -> CGColor in level.color.cgColor })
        var colors = [CGColor]()
        AQILevel.allCases.forEach { (level) in
            colors.append(level.color.cgColor)
            colors.append(level.color.cgColor)
        }
        gradientLayer.colors = colors
        
        // Gradient scale
        let delta = 0.025
        var locations = [NSNumber(value: 0)]
        measure.levels.forEach { (level) in
            locations.append(NSNumber(value: (Double(level) / Double(measure.maxValue)) - delta))
            locations.append(NSNumber(value: (Double(level) / Double(measure.maxValue)) + delta))
        }
        locations.removeLast()
        gradientLayer.locations = locations
        
        gradientLayer.startPoint = CGPoint.init(x:0.0, y:0.5)
        gradientLayer.endPoint = CGPoint.init(x:1.0, y:0.5)

        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, gradientLayer.isOpaque, 0.0);
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()

            image.resizableImage(withCapInsets: UIEdgeInsets.zero)

            levelSlider.setMinimumTrackImage(image, for: .normal)
            levelSlider.setMaximumTrackImage(image, for: .normal)
            levelSlider.maximumValue = Float(measure.maxValue)
        }
    }
    
    @IBAction func unwindSeque(seque: UIStoryboardSegue) {
    }

}
