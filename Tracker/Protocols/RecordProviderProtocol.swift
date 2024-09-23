//
//  RecordProviderProtocol.swift
//  Tracker
//
//  Created by Вадим Дзюба on 19.09.2024.
//

import Foundation
import CoreData


protocol RecordProviderProtocol {
    func object(at indexPath: IndexPath) -> TrackerRecordCoreData?
    func add(date: String, uuid: UUID, tracker: TrackerCoreData)
    func delete(id: UUID, date: String)
}
