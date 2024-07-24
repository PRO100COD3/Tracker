//
//  TrackerRecordProtocol.swift
//  Tracker
//
//  Created by Вадим Дзюба on 22.07.2024.
//

import UIKit


protocol TrackerRecordProtocol: AnyObject{
    func didTapAddButton(on cell: TrackersCollectionViewCell)
    func didRetapAddButton(on cell: TrackersCollectionViewCell)
}
