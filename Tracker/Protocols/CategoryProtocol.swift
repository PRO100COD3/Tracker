//
//  CreateHabitDelegate.swift
//  Tracker
//
//  Created by Вадим Дзюба on 14.07.2024.
//

import UIKit

protocol CategoryProtocol: AnyObject{
    func selectCategory(selected: TrackerCategory)
    func addCategoryAtProtocol(name: String)
}
