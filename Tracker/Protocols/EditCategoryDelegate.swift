//
//  EditCategoryDelegate.swift
//  Tracker
//
//  Created by Вадим Дзюба on 29.09.2024.
//

import Foundation


protocol EditCategoryDelegate: AnyObject {
    func edit(name: String, index: IndexPath)
}
