//
//  ScreenViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 24.09.2024.
//

import UIKit


final class ScreenViewController: UIViewController {
    private let backgroundImageString: String?
    private let doneButtonString: String = "Вот это технологии!"
    private var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    } ()
    private let backgroundImageView = UIImageView()
    private let screenTextString: String?
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "black")
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
        setupButton()
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
        self.getPageViewController()?.transitionToMainScreen()
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
