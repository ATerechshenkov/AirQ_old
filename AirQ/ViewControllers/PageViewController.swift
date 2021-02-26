import UIKit

protocol SmogDelegate {
    func setSmogValue(_ smogValue: CGFloat)
}
 
class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, SmogDelegate {
    var pages = [Page]()
    var views = [CityViewController]()
    var currentPage = 0
    var bgImageView:UIImageView = {
        let image = UIImage(named: "BGDay.png")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .bottomLeft
        return imageView
    }()
    var smogView = UIView()
    
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSmogLayer()
        configureBackGround()
        
        configurePages()
        
        let childControllers: [UIViewController] = [views.first!]
        self.setViewControllers(childControllers, direction: .forward, animated: false, completion: nil)
        self.view.frame = self.view.bounds
        
        configurePageControl()

        self.dataSource = self
        self.delegate = self
    }
    
    private func configurePages() {
        if let pages = try? PageService.loadPages() {
            self.pages = pages
        } else {
            self.pages = PageService.defaultPages
        }
        
        pages.forEach { (page) in
            let view = storyboard!.instantiateViewController(withIdentifier: "CityViewController") as! CityViewController
            view.page = page
            view.smogDelegate = self
            views.append(view)
        }
    }
    
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 50, width: UIScreen.main.bounds.width, height: 50))
        
        self.pageControl.numberOfPages = pages.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.gray
        self.pageControl.currentPageIndicatorTintColor = UIColor.green
        //self.pageControl.defersCurrentPageDisplay = false     // This has no effect
        //self.view.addSubview(pageControl)
    }
    
    // MARK: Delegate function
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
 
        let pageContentViewController = pageViewController.viewControllers![0] as! CityViewController
        self.pageControl.currentPage = views.firstIndex(of: pageContentViewController)!
    }
 
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = views.firstIndex(of: viewController as! CityViewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard pages.count > previousIndex else {
            return nil
        }
        currentPage -= 1
        
        return views[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = views.firstIndex(of: viewController as! CityViewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = pages.count
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        currentPage += 1
        
        return views[nextIndex]
    }
    
    func viewController(at index: Int) -> UIViewController {
        return views[index]
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentPage
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
 
    func setSmogValue(_ smogValue: CGFloat) {
        UIView.animate(withDuration: 1.5) {
            self.smogView.alpha = smogValue
            self.smogView.backgroundColor = UIColor(white: CGFloat(0.5), alpha: smogValue/2)
        }
    }
    
    private func configureSmogLayer() {
        print("configureSmogLayer \(view.frame.width) \(view.frame.height)")
        let smogEmitterLayer = CAEmitterLayer()
        smogEmitterLayer.emitterSize = CGSize(width: 200, height: view.frame.height/1.2)
        smogEmitterLayer.emitterShape = .rectangle
        smogEmitterLayer.emitterPosition = CGPoint(x: view.frame.width + 400, y: view.frame.height/2)
        
        let darkSmogCell = getSmogEmitterCell(UIImage(named: "smog_dark")!)
        let whiteSmogCell = getSmogEmitterCell(UIImage(named: "smog_white")!)
        
        smogEmitterLayer.emitterCells = [whiteSmogCell, darkSmogCell]
        //smogLayer.addSublayer(smogEmitterLayer)
        
        smogView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        smogView.layer.addSublayer(smogEmitterLayer)
        smogView.alpha = 0
        view.insertSubview(smogView, at: 0)
    }
    
    private func getSmogEmitterCell(_ image: UIImage) -> CAEmitterCell {
        let smogEmitterCell = CAEmitterCell()
        smogEmitterCell.color = CGColor(gray: 0.5, alpha: 0.6)
        smogEmitterCell.contents = image.cgImage
        smogEmitterCell.lifetime = 100.0
        smogEmitterCell.birthRate = 4
        
        smogEmitterCell.alphaRange = 0.9
        smogEmitterCell.alphaSpeed = -0.025
        
        smogEmitterCell.scale = 2.0
        smogEmitterCell.scaleRange = 0.5
        //smogEmitterCell.scaleSpeed = 1.0
       
        smogEmitterCell.emissionRange = CGFloat.pi / 2
        smogEmitterCell.emissionLatitude = CGFloat.pi
        
        smogEmitterCell.velocity = 4
        smogEmitterCell.velocityRange = 1.5
        smogEmitterCell.xAcceleration = -1.0
        smogEmitterCell.yAcceleration = -0.1
        //smogEmitterCell.zAcceleration = -1.5
        
        return smogEmitterCell
    }
    
    private func configureBackGround() {
        bgImageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        view.insertSubview(bgImageView, at: 0)
        
        UIView.animate(
            withDuration: 300.0,
            delay: 0.0,
            options: [.autoreverse, .repeat, .curveLinear]) { [weak self] in
                guard let self = self else { return }
            
                self.bgImageView.frame.origin.x -= (self.bgImageView.image?.size.width)! - UIScreen.main.bounds.width
            }
    }
}
