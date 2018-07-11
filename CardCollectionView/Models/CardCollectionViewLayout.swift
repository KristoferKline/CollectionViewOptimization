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
        
        scrollDirection = .vertical
        sectionInsetReference = .fromSafeArea
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Available width used for item sizing = bounds - padding between items.
        let availableWidth = collectionView.bounds.width - ((itemsPerColumn + 1) * itemSpacing)
        let itemWidth = availableWidth / itemsPerColumn
        
        // Not using right now.
//        let availableHeight = collectionView.bounds.height - ((itemsPerRow + 3) * itemSpacing)
//        let itemHeight = availableHeight / itemsPerRow
        
        itemSize = CGSize(width: itemWidth, height: itemWidth * 2)
        
        collectionView.contentInset = UIEdgeInsets(top: itemSpacing,
                                                   left: itemSpacing,
                                                   bottom: itemSpacing,
                                                   right: itemSpacing)
    }
}
