//
//  DataProviderDelegate.swift
//  Tracker
//
//  Created by Вадим Дзюба on 05.09.2024.
//

import Foundation


protocol TableViewProviderDelegate: AnyObject {
    func didUpdate(_ update: CategoryStoreUpdate)
}

protocol CollectionViewProviderDelegate: AnyObject {
    func didUpdate()
}

protocol RecordProviderDelegate: AnyObject {
    func didUpdateRecords()
}
