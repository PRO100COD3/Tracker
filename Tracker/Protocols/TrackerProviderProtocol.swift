//
//  TrackerProviderProtocol.swift
//  Tracker
//
//  Created by Вадим Дзюба on 06.09.2024.
//

import Foundation
import CoreData


protocol TrackerProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath, id: UUID) -> TrackerCoreData?
    func add(name: String, color: String, emoji: String, shedule: String, category: TrackerCategoryCoreData)
    func edit(tracker: TrackerCoreData, name: String, color: String, emoji: String, shedule: String, category: TrackerCategoryCoreData)
    func delete(record: NSManagedObject)
}
