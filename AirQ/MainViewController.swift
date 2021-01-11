//
//  ViewController.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 27.12.2020.
//

import UIKit

class MainViewController: UIViewController {

    private var aqiModel: AQIModel!
    
    @IBOutlet var urbanImage: UIImageView!
    @IBOutlet var smogImage: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var measurePM25Label: UILabel!
    @IBOutlet var measurePM10Label: UILabel!
    @IBOutlet var measureAQILabel: UILabel!
    
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var aqiLevelValueLabel: UILabel!
    @IBOutlet var aqiLevelNameLabel: UILabel!
    @IBOutlet var aqiLevelSlider: UISlider!
    @IBOutlet var aqiLevelHealthLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HTTPService().fetchAQIData { [weak self] (aqiModel) in
          self?.aqiModel = aqiModel
          DispatchQueue.main.async {
            self?.redrawView()
            self?.loadingDataInProcess(inProcess: false)
          }
        }
        
        loadingDataInProcess(inProcess: true)
        drawGradient4Slider()
    }
    
    private func loadingDataInProcess(inProcess: Bool) {
        urbanImage.isHidden = inProcess
        smogImage.isHidden = inProcess
        cityLabel.isHidden = inProcess
        infoButton.isHidden = inProcess
        measureAQILabel.isHidden = inProcess
        measurePM10Label.isHidden = inProcess
        measurePM25Label.isHidden = inProcess
        aqiLevelValueLabel.isHidden = inProcess
        aqiLevelNameLabel.isHidden = inProcess
        aqiLevelSlider.isHidden = inProcess
        aqiLevelHealthLabel.isHidden = inProcess
        
        if inProcess {
            smogImage.alpha = 0.0
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            animateBackGround()
        }
    }
    
    // TODO: После вызова этого метода слетает анимация
    private func redrawView() {
        print("call redrawView")
        aqiLevelValueLabel.text = String(aqiModel.aqi ?? 0)
        aqiLevelSlider.value = Float(aqiModel.aqi ?? 0)
        aqiLevelSlider.thumbTintColor = aqiModel.aqiColor
        aqiLevelNameLabel.text = aqiModel.aqiName
        aqiLevelHealthLabel.text = aqiModel.aqiHealth
        cityLabel.text = aqiModel.cityName
        
        smogImage.alpha = CGFloat(aqiModel.aqi ?? 0) / CGFloat(AQILevel.very_unhealthy.rawValue)
        urbanImage.alpha = 2 - smogImage.alpha
    }
    
    var aqiBeforeChanged = 0
    @IBAction func onTouchDownSlider(_ sender: Any) {
        aqiBeforeChanged = aqiModel.aqi ?? 0
    }
    
    @IBAction func onChangedSlider(_ sender: Any) {
        aqiModel.aqi = Int(aqiLevelSlider.value)
        redrawView()
    }
    
    @IBAction func onTouchUpSlider(_ sender: Any) {
        aqiModel.aqi = aqiBeforeChanged
        redrawView()
    }
    
    private func drawGradient4Slider() {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = CGRect.init(x:0, y:0, width: aqiLevelSlider.frame.size.width, height:16)
        gradientLayer.colors = AQILevel.allCases.map({ (level) -> CGColor in level.color.cgColor })
        //gradientLayer.locations = AQILevel.allCases.map({ (level) -> NSNumber in NSNumber(value: level.rawValue / AQILevel.hazardous.rawValue) })
        gradientLayer.locations = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
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
    
    private func animateBackGround(_ moveRight: Bool = true) {
        UIImageView.animate(
            withDuration: 200.0,
            delay: 0.0,
            options: [.curveLinear],
            animations: {
                let direction: CGFloat = moveRight ? -1.0 : +1.0
                self.urbanImage.frame.origin.x += (self.urbanImage.frame.width - UIScreen.main.bounds.width) * direction
                self.smogImage.frame.origin.x += (self.smogImage.frame.width - UIScreen.main.bounds.width) * direction
            },
            completion: { finished in
                self.animateBackGround(!moveRight)
            }
        )
    }
    
    @IBAction func unwindSeque(seque: UIStoryboardSegue) {
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
