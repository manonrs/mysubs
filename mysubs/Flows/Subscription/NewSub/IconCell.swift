//
//  IconCell.swift
//  mysubs
//
//  Created by Manon Russo on 24/01/2022.
//

import UIKit

class IconCell: UICollectionViewCell {
    // For selection effect on cell since it's selectAction which contains the action
    override var isSelected: Bool {
       didSet{
           if self.isSelected {
               UIView.animate(withDuration: 0.3) { // for animation effect
                   self.backgroundColor = .placeholderText
               }
           }
           else {
               UIView.animate(withDuration: 0.3) { // when deselected
                   self.backgroundColor = .systemBackground
               }
           }
       }
   }
    
    static let identifier = "IconCell"
     var logo = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCell()
//        fatalError("error")
    }
    
    func configureCell() {
        logo.translatesAutoresizingMaskIntoConstraints = false
        addSubview(logo)

        // MARK: - Constraints
        NSLayoutConstraint.activate([
            logo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            logo.widthAnchor.constraint(equalToConstant: 42),
            logo.heightAnchor.constraint(equalToConstant: 42),
            logo.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            
        ])
        
    }
}