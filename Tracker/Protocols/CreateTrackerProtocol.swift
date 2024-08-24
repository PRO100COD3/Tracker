//
//  CreateHabitProtocol.swift
//  Tracker
//
//  Created by Вадим Дзюба on 14.07.2024.
//

import UIKit

protocol CreateTrackerProtocol: AnyObject{
    func createNewTracker(name: String, shedule: [String], category: TrackerCategory, emoji: String)
}
