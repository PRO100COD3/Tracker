//
//  CollectionViewHeaders.swift
//  Tracker
//
//  Created by Вадим Дзюба on 18.07.2024.
//

import UIKit

final class CollectionViewHeaders: UICollectionReusableView {
    static let identifier = "CollectionViewHeaders"
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "header"
        label.textAlignment = .left
        label.textColor = UIColor.label
        label.font = UIFont(name: "SFPro-Bold", size: 19)
        return label
    }()
    
    public func configure(with title: String){
        backgroundColor = .ypBackground
        addSubview(label)
        label.text = title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0))
    }
}
