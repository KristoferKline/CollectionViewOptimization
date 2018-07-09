//
//  CardCollectionViewLayout.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 6/24/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

final class CardCollectionViewLayout: UICollectionViewFlowLayout {
    let itemsPerColumn: CGFloat = 2
    let itemsPerRow: CGFloat = 3
    let itemSpacing: CGFloat = 5
//    let maxWidth: CGFloat = 150
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        minimumLineSpacing = itemSpacing
        minimumInteritemSpacing = itemSpacing
        
        scrollDirection = .horizontal
        sectionInsetReference = .fromSafeArea
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Available width used for item sizing = bounds - padding between items.
        let availableWidth = collectionView.bounds.width - ((itemsPerColumn + 1) * itemSpacing)
        let itemWidth = availableWidth / itemsPerColumn
        
        let availableHeight = collectionView.bounds.height - ((itemsPerRow + 1) * itemSpacing)
        let itemHeight = availableHeight / itemsPerRow
        
        itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        collectionView.contentInset = UIEdgeInsets(top: 0,
                                                   left: itemSpacing,
                                                   bottom: 0,
                                                   right: itemSpacing)
    }
}
