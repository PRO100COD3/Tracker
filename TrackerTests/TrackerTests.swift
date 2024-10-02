//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Вадим Дзюба on 30.09.2024.
//


import XCTest
import SnapshotTesting
@testable import Tracker


final class TrackerTests: XCTestCase {
    
    func testViewController() {
        let vc = TrackersViewController()
        vc.loadViewIfNeeded()
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
}
