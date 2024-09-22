//
//  CustomColorCell.swift
//  Tracker
//
//  Created by Вадим Дзюба on 20.08.2024.
//
import UIKit


final class CustomColorCell: UICollectionViewCell {
    static let identifier = "CustomColorCell"
    
    private let centeredView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(centeredView)
        
        NSLayoutConstraint.activate([
            centeredView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centeredView.centerYAnchor.constraint(equalTo: centerYAnchor),
            centeredView.widthAnchor.constraint(equalToConstant: 40),
            centeredView.heightAnchor.constraint(equalToConstant: 40)
        ])
    
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeCell(color: UIColor, isSelected: Bool) {
        centeredView.backgroundColor = color
        
        if isSelected {
            layer.borderWidth = 3
            layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
        }
    }
}
