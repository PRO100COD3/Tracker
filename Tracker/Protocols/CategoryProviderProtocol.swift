//
//  CategoryProviderProtocol.swift
//  Tracker
//
//  Created by Вадим Дзюба on 05.09.2024.
//

import Foundation
import CoreData


protocol CategoryProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> TrackerCategoryCoreData?
    func indexPath(for object: TrackerCategoryCoreData) -> IndexPath?
    func editCategory(indexPath: IndexPath, name: String)
    func add(name: String)
    func delete(indexPath: IndexPath)
}
