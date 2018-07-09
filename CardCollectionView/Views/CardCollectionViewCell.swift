//
//  CardCollectionViewCell.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 6/24/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

final class CardCollectionViewCell: UICollectionViewCell {
    static var identifier = String(describing: self)
    
    let previewImageView = UIImageView()
    
    override func prepareForReuse() {
        previewImageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 10
        previewImageView.backgroundColor = .lightGray
        contentView.addSubview(previewImageView)
        
        previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        previewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        previewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
