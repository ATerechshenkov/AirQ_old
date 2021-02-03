//
//  ViewController.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 27.12.2020.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {

    var aqiModel: AqiModel!
    
    let aqiService = AqiService.shared
    
    @IBOutlet var urbanImage: UIImageView!
    @IBOutlet var smogImage: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var cityLabel: UILabel!
    
    @IBOutlet var measureAQIButton: UIButton!
    @IBOutlet var measurePM10Button: UIButton!
    @IBOutlet var measurePM25Button: UIButton!
    
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var aqiLevelValueLabel: UILabel!
    @IBOutlet var aqiLevelNameLabel: UILabel!
    @IBOutlet var aqiLevelSlider: UISlider!
    @IBOutlet var aqiLevelHealthLabel: UILabel!
    
    override func viewDidLoad()  {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            do {
                let coordinate = try self.aqiService.spotMyLocation()
                self.fetchAqiData(coordinate)
            } catch let error as LocationError {
                debugPrint(error)
                DispatchQueue.main.async {
                    self.showAllert(error.message)
                }
            } catch let error {
                debugPrint(error)
                DispatchQueue.main.async {
                    self.showAllert(error.localizedDescription)
                }
            }
        }
        
        loadingDataInProcess(inProcess: true)
        animateBackGround()
    }
    
    private func fetchAqiData(_ coordinate: CLLocationCoordinate2D) {
        aqiService.fetchAqiData(byLocation: coordinate) { [weak self] (model) in
            guard let self = self else { return }
                
            self.aqiModel = model
            
            DispatchQueue.main.async {
                self.redrawView()
                self.switchMeasure(self.aqiModel.measure ?? .aqi)
                self.loadingDataInProcess(inProcess: false)
            }
        } errorHandler: { [weak self] (error) in
            guard let self = self else { return }
            
            debugPrint(error)
            DispatchQueue.main.async {
                self.showAllert(error.localizedDescription)
            }
        }
    }
    
    private func loadingDataInProcess(inProcess: Bool) {
        smogImage.isHidden = inProcess
        cityLabel.isHidden = inProcess
        infoButton.isHidden = inProcess
        measureAQIButton.isHidden = inProcess
        measurePM10Button.isHidden = inProcess
        measurePM25Button.isHidden = inProcess
        aqiLevelValueLabel.isHidden = inProcess
        aqiLevelNameLabel.isHidden = inProcess
        aqiLevelSlider.isHidden = inProcess
        aqiLevelHealthLabel.isHidden = inProcess
        
        if inProcess {
            smogImage.alpha = 0.0
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func redrawView() {
        aqiLevelValueLabel.text = String(aqiModel.value ?? 0)
        aqiLevelSlider.value = Float(aqiModel.value ?? 0)
        aqiLevelSlider.thumbTintColor = aqiModel.color
        aqiLevelNameLabel.text = aqiModel.name
        aqiLevelHealthLabel.text = aqiModel.health
        cityLabel.text = aqiModel.cityName
        
        smogImage.alpha = CGFloat(aqiModel.value ?? 0) / CGFloat(aqiModel.measure!.maxValue)
        urbanImage.alpha = 1.5 - smogImage.alpha
    }
    
    var valueBeforeChanged = 0
    @IBAction func onTouchDownSlider(_ sender: Any) {
        valueBeforeChanged = aqiModel.value ?? 0
    }
    
    @IBAction func onChangedSlider(_ sender: Any) {
        aqiModel.value = Int(aqiLevelSlider.value)
        redrawView()
    }
    
    @IBAction func onTouchUpSlider(_ sender: Any) {
        aqiModel.value = valueBeforeChanged
        redrawView()
    }
    
    @IBAction func onAQIButtonClick(_ sender: Any) {
        switchMeasure(.aqi)
    }
    
    @IBAction func onPM10ButtonClick(_ sender: Any) {
        switchMeasure(.pm10)
    }

    @IBAction func onPM25ButtonClick(_ sender: Any) {
        switchMeasure(.pm25)
    }
    
    private func switchMeasure(_ measure: AQIMeasure) {
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
        aqiModel.measure = measure
        redrawView()
        
        drawGradientScale(measure)
    }
    
    private func drawGradientScale(_ measure: AQIMeasure) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = CGRect.init(x:0, y:0, width: aqiLevelSlider.frame.size.width, height:16)
        gradientLayer.colors = AQILevel.allCases.map({ (level) -> CGColor in level.color.cgColor })
        gradientLayer.cornerRadius = gradientLayer.frame.height / 2
        
        // Gradient scale
        gradientLayer.locations = measure.levels.map({ (level) -> NSNumber in
            return NSNumber(value: Double(level) / Double(measure.maxValue))
        })
        gradientLayer.locations?.insert(0, at: 0)
        gradientLayer.locations?.removeLast()

        gradientLayer.startPoint = CGPoint.init(x:0.0, y:0.5)
        gradientLayer.endPoint = CGPoint.init(x:1.0, y:0.5)

        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, gradientLayer.isOpaque, 0.0);
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()

            image.resizableImage(withCapInsets: UIEdgeInsets.zero)

            aqiLevelSlider.setMinimumTrackImage(image, for: .normal)
            aqiLevelSlider.setMaximumTrackImage(image, for: .normal)
            aqiLevelSlider.maximumValue = Float(measure.maxValue)
        }
    }
    
    private func animateBackGround() {
        UIView.animate(
            withDuration: 200.0,
            delay: 0.0,
            options: [.autoreverse, .repeat, .curveLinear]) { [weak self] in
                guard let self = self else { return }
            
                self.urbanImage.frame.origin.x += self.urbanImage.frame.width - UIScreen.main.bounds.width
                self.smogImage.frame.origin.x += self.smogImage.frame.width - UIScreen.main.bounds.width
            }
    }
    
    @IBAction func unwindSeque(seque: UIStoryboardSegue) {
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

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
