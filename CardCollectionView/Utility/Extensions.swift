//
//  Extensions.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 7/4/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

extension UIImage {
    static func createCachedThumbnail(with data: Data) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as NSData, imageSourceOptions) else {
            return nil
        }
        
        let downsapleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            ] as CFDictionary
        
        
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsapleOptions) else {
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
    }
}
