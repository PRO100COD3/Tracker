//
//  TabBarController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 05.07.2024.
//
import UIKit
final class TabBarViewController: UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let statisticViewController = StatisticViewController()
        let trackersViewController = TrackersViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "Circle_on"),
            selectedImage: nil
        )
        let navigationController = UINavigationController(rootViewController: trackersViewController)
        navigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Rabbit_on"),
            selectedImage: nil
        )
        self.viewControllers = [ navigationController, statisticViewController ]
    }
}
