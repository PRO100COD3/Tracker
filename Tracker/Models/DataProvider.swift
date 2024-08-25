//
//  DataProvider.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.08.2024.
//

import Foundation
import CoreData


protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

final class DataProvider: NSObject {
    
}
