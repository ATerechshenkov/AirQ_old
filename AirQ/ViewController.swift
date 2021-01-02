//
//  ViewController.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 27.12.2020.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var urbanImage: UIImageView!
    @IBOutlet var smogImage: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var measureLabel: UILabel!
    @IBOutlet var aqiLevelValueLabel: UILabel!
    @IBOutlet var aqiLevelNameLabel: UILabel!
    @IBOutlet var aqiLevelSlider: UISlider!
    
    private var aqiData: AQIData!
    private var aqiLevelValue: Int = 0
    private var aqiLevelName: String {
        AQILevel.getAQILevel(forAQIValue: Int(aqiLevelValue)).name
    }
    private var city: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AQIService().fetchAQIData { [weak self] (aqiData) in
          self?.aqiData = aqiData
          DispatchQueue.main.async {
            self?.reloadData()
            self?.redrawView()
            self?.loadingData(false)
          }
        }
        
        loadingData(true)
        drawGradient4Slider()
        animateBackGround()
    }
    
    @IBAction func moveSlider(_ sender: Any) {
        aqiLevelValue = Int(aqiLevelSlider.value)
        redrawView()
    }
    
    @IBAction func touchUpSlider(_ sender: Any) {
        reloadData()
        redrawView()
    }
    
    private func reloadData() {
        if let aqi = aqiData?.aqi {
            self.aqiLevelValue = Int(aqi)
        }
 
        if let city = aqiData?.city?.name {
            self.city = String(city.prefix(while: { (char) -> Bool in char != "," }))
        }
    }
    
    private func loadingData(_ isLoading: Bool) {
        
        cityLabel.isHidden = isLoading
        measureLabel.isHidden = isLoading
        aqiLevelValueLabel.isHidden = isLoading
        aqiLevelNameLabel.isHidden = isLoading
        aqiLevelSlider.isHidden = isLoading
        if isLoading {
            smogImage.alpha = 0.0
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func redrawView() {
        aqiLevelValueLabel.text = String(aqiLevelValue)
        aqiLevelSlider.value = Float(aqiLevelValue)
        aqiLevelNameLabel.text = aqiLevelName
        cityLabel.text = city
        
        smogImage.alpha = CGFloat(aqiLevelValue) / CGFloat(AQILevel.very_unhealthy.rawValue)
        urbanImage.alpha = 2 - smogImage.alpha
    }

    private func drawGradient4Slider() {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = CGRect.init(x:0, y:0, width: aqiLevelSlider.frame.size.width, height:16)
        gradientLayer.colors = AQILevel.allCases.map({ (level) -> CGColor in level.color.cgColor })
        //gradientLayer.locations = AQILevel.allCases.map({ (level) -> NSNumber in NSNumber(value: level.rawValue / AQILevel.hazardous.rawValue) })
        gradientLayer.locations = [0, 0.1, 0.2, 0.3, 0.4, 0.6]
        gradientLayer.startPoint = CGPoint.init(x:0.0, y:0.5)
        gradientLayer.endPoint = CGPoint.init(x:1.0, y:0.5)
         
        // Roundex cornes
        //aqiLevelSlider.layer.cornerRadius = 8
        //aqiLevelSlider.clipsToBounds = true
        //aqiLevelSlider.layer.sublayers![1].cornerRadius = 8
        //aqiLevelSlider.subviews[1].clipsToBounds = true

        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, gradientLayer.isOpaque, 0.0);
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()

            image.resizableImage(withCapInsets: UIEdgeInsets.zero)

            aqiLevelSlider.setMinimumTrackImage(image, for: .normal)
            aqiLevelSlider.setMaximumTrackImage(image, for: .normal)
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

// Animation
extension ViewController {
    private func animateBackGround(_ moveRight: Bool = true) {
        UIImageView.animate(
            withDuration: 1200.0,
            delay: 0.0,
            options: [.curveLinear],
            animations: {
                let direction: CGFloat = moveRight ? -1.0 : 1.0
                self.urbanImage.frame.origin.x += (self.urbanImage.frame.width - UIScreen.main.bounds.width) * direction
                self.smogImage.frame.origin.x += (self.smogImage.frame.width - UIScreen.main.bounds.width) * direction
            },
            completion: { finished in
                self.animateBackGround(!moveRight)
            }
        )
    }
}
