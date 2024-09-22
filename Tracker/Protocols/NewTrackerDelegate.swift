//
//  NewTrackerDelegate.swift
//  Tracker
//
//  Created by Вадим Дзюба on 06.09.2024.
//

import Foundation


protocol NewTrackerDelegate: AnyObject {
    func add(name: String, color: String, emoji: String, shedule: String, category: TrackerCategoryCoreData)
}
