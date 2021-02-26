//
//  RootViewController.swift
//  AirQ
//
//  Created by Terechshenkov Andrey on 04.02.2021.
//

import UIKit

class ScrollViewController: UIViewController {

    private let scrollView = UIScrollView()
    
    private var pageControl: UIPageControl {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 5
        pageControl.backgroundColor = .systemBlue
        pageControl.tintColor = .cyan
        return pageControl
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.addTarget(self, action: #selector(pageControlDidChanged(_:)), for: .valueChanged)
        scrollView.backgroundColor = .systemRed
        view.addSubview(pageControl)
        //view.addSubview(scrollView)
        
    }
    
    @objc private func pageControlDidChanged(_ sender: UIPageControl) {
        let current = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: view.frame.size.width * CGFloat(current), y: 0), animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //pageControl.frame = CGRect(x: 10, y: view.frame.size.height-100, width: view.frame.size.width-20 , height: 70)
        pageControl.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height-100)
        
        if scrollView.subviews.count == 2 {
            configurationScrollView()
        }
    }
    
    private func configurationScrollView() {
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        let colors: [UIColor] = [.systemGray2, .systemGray3, .systemGray4, .systemGray5, .systemGray6]
        
        for i in 0..<5 {
            let page = UIView()
            page.frame = CGRect(x: view.frame.size.width * CGFloat(i), y: 0, width: view.frame.size.width, height: scrollView.frame.size.height)
            page.backgroundColor = colors[i]
            scrollView.addSubview(page)
        }
    }
}
