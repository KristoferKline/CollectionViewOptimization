//
//  CardCollectionViewLayout.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 6/24/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

final class CardCollectionViewLayout: UICollectionViewFlowLayout {
    let itemsPerRow: CGFloat = 1
    let itemSpacing: CGFloat = 20
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        minimumLineSpacing = itemSpacing
        minimumInteritemSpacing = itemSpacing
        scrollDirection = .horizontal
        sectionInsetReference = .fromSafeArea
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Available width used for item sizing = bounds - padding between items.
        let availableWidth = collectionView.bounds.width - ((itemsPerRow - 1) * itemSpacing)
        let itemWidth = (availableWidth / itemsPerRow) - itemSpacing * 10
        itemSize = CGSize(width: itemWidth, height: collectionView.bounds.height)
    }
}