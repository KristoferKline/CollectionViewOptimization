//
//  LoadImageOperation.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 7/3/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

protocol LoadImageOperationDelegate {
    func didRetrieve(image: UIImage)
}

typealias LoadImageCompletion = ((UIImage) -> Void)

final class LoadImageOperation: Operation {
    private let imageURL: URL
    var completion: LoadImageCompletion
    weak var session: URLSession?
    
    init(url: URL, session: URLSession, completion: @escaping LoadImageCompletion) {
        imageURL = url
        self.session = session
        self.completion = completion
    }
    
    override func main() {
        print("Executing")
        loadImage(from: imageURL) { (error) in
            guard let error = error else { return }
            print("Ran into an error: \(error.localizedDescription)")
        }
    }
    
    private func loadImage(from imageURL: URL, completion: @escaping (Error?) -> Void) {
        session?.dataTask(with: imageURL) { [weak self] (data, response, error) in
            guard let data = data, error == nil else { return completion(error) }
            
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageSource = CGImageSourceCreateWithData(data as NSData, imageSourceOptions) else {
                return print("Failed to create image source from data")
            }
            
            let downsapleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                ] as CFDictionary
            
            guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsapleOptions) else {
                return print("Failed to craete downsampled image.")
            }
            
            print("Retrieved an image")
            self?.completion(UIImage(cgImage: downsampledImage))
        }.resume()
        
//        URLSession.shared.dataTask(with: imageURL) { [weak self] (data, response, error) in
//            guard let data = data, error == nil else { return completion(error) }
//
//            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
//            guard let imageSource = CGImageSourceCreateWithData(data as NSData, imageSourceOptions) else {
//                return print("Failed to create image source from data")
//            }
//
//            let downsapleOptions = [
//                kCGImageSourceCreateThumbnailFromImageAlways: true,
//                kCGImageSourceShouldCacheImmediately: true,
//                kCGImageSourceCreateThumbnailWithTransform: true,
//                ] as CFDictionary
//
//            guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsapleOptions) else {
//                return print("Failed to craete downsampled image.")
//            }
//
//            print("Retrieved an image")
//            self?.image = UIImage(cgImage: downsampledImage)
//        }.resume()
    }
}
