//
//  RecordProviderProtocol.swift
//  Tracker
//
//  Created by Вадим Дзюба on 19.09.2024.
//

import Foundation
import CoreData


protocol RecordProviderProtocol {
    //var numberOfSections: Int { get }
    //func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerRecordCoreData?
    func add(date: String, uuid: UUID)
    func delete(id: UUID, date: String)
}
