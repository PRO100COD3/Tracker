//
//  ScreenViewController 2.swift
//  Tracker
//
//  Created by Вадим Дзюба on 29.09.2024.
//


import UIKit


final class ScreenViewController: UIViewController {
    private let backgroundImageString: String?
    private let backgroundImageView = UIImageView()
    private let screenTextString: String?
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .yPblack
        label.font = UIFont(name: "SFPro-Bold", size: 32)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    init(backgroundImageString: String?, screenTextString: String?) {
        self.backgroundImageString = backgroundImageString
        self.screenTextString = screenTextString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundView()
        setupLabel()
    }
    
    private func setupBackgroundView() {
        guard let backgroundImageString, let image = UIImage(named: backgroundImageString) else { return }
        setBackgroundImage(image)
    }
    
    func setBackgroundImage(_ image: UIImage) {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        backgroundImageView.image = image
    }
    
    private func setupLabel() {
        label.text = screenTextString
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 60),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    private func getPageViewController() -> PageViewController? {
        var parentController = self.parent
        while let parent = parentController {
            if let pageViewController = parent as? PageViewController {
                return pageViewController
            }
            parentController = parent.parent
        }
        return nil
    }
}
