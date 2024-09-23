//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.06.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    //private var firstLaunch: Bool = true
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        if isOnboardingCompleted() {
            
            window?.rootViewController = TabBarViewController()
        } else {
            let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            window?.rootViewController = pageViewController
            setOnboardingCompleted()
        }
        window?.makeKeyAndVisible()
    }
    
    private func setOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
    }
    
    private func isOnboardingCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: "onboardingCompleted")
    }
}

