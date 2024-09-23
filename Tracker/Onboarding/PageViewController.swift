//
//  PageViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 24.09.2024.
//

import UIKit


final class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let screen1LabelString = "Отслеживайте только то, что хотите"
    private let screen2LabelString = "Даже если это не литры воды и йога"
    private let screen1BackImageString = "Onboarding1"
    private let screen2BackImageString = "Onboarding2"
    
    private lazy var pages: [UIViewController] = {
        let screen1 = ScreenViewController(backgroundImageString: screen1BackImageString, screenTextString: screen1LabelString)
        
        let screen2 = ScreenViewController(backgroundImageString: screen2BackImageString, screenTextString: screen2LabelString)
        
        return [screen1, screen2]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = UIColor.yPblack
        pageControl.pageIndicatorTintColor = UIColor.yPblackTransporent
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        setupPageView()
    }
    
    func transitionToMainScreen() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }
        
        let tabBarController = TabBarViewController()
        
        window.rootViewController = tabBarController
        
        UIView.transition(with: window,
                          duration: 0.5,
                          options: .transitionFlipFromTop,
                          animations: nil)
    }
    
    private func setupPageView() {
        if let firstViewController = pages.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 230),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    
    func configure(with pages: [UIViewController]) {
        self.pages = pages
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
