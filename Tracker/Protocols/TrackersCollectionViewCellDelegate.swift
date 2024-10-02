//
//  TrackersCollectionViewCellDelegate.swift
//  Tracker
//
//  Created by Вадим Дзюба on 29.09.2024.
//

import UIKit


protocol TrackersCollectionViewCellDelegate: AnyObject {
    func presentViewController(navController: UINavigationController)
    func presentAlertController(alerController: UIAlertController)
}
