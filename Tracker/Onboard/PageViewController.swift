//
//  PageViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 29.09.2024.
//

import UIKit

enum numberOfScreen: String {
    case screen1BackImageString = "Onboarding1"
    case screen2BackImageString = "Onboarding2"
}

final class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        button.backgroundColor = .yPblack
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    } ()
    private let doneButtonString: String = NSLocalizedString("launchApplicationButtonTitle", comment: "Вот это технологии!")
    
    private lazy var pages: [UIViewController] = {
        let screen1 = ScreenViewController(backgroundImageString: numberOfScreen.screen1BackImageString.rawValue, screenTextString: NSLocalizedString("onboardingPage1Title", comment: "Отслеживайте только то, что хотите"))
        let screen2 = ScreenViewController(backgroundImageString: numberOfScreen.screen2BackImageString.rawValue, screenTextString: NSLocalizedString("onboardingPage2Title", comment: "Даже если это не литры воды и йога"))
        
        return [screen1, screen2]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = UIColor.yPblack
        pageControl.pageIndicatorTintColor = UIColor.yPblackTransporent
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isEnabled = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        setupPageView()
        setupButton()
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
    
    private func setupButton() {
        doneButton.setTitle(doneButtonString, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTap(_:)), for: .touchUpInside)
        
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -84),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func doneButtonTap(_ sender: UIButton) {
        transitionToMainScreen()
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
