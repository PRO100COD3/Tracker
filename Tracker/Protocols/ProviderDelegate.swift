//
//  DataProviderDelegate.swift
//  Tracker
//
//  Created by Вадим Дзюба on 05.09.2024.
//

import Foundation


protocol CategoryProviderDelegate: AnyObject {
    func didUpdate(_ update: CategoryStoreUpdate)
}

protocol TrackerProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}
