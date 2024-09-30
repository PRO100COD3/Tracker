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
        let statisticViewController = StatisticsViewController()
        let trackersViewController = TrackersViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statisticsTabBarItemTitle", comment: "Статистика"),
            image: UIImage(named: "Rabbit_on"),
            selectedImage: nil
        )
        let navigationController = UINavigationController(rootViewController: trackersViewController)
        navigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackersTabBarItemTitle", comment: "Трекеры"),
            image: UIImage(named: "Circle_on"),
            selectedImage: nil
        )
        self.viewControllers = [ navigationController, statisticViewController ]
    }
}
