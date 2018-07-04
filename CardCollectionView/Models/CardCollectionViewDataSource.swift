//
//  CardCollectionViewDataSource.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 7/4/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

typealias Object = NSObject
final class CardCollectionViewDataSource: Object, UICollectionViewDataSource {
    
    var imageCount: Int = 15
    var imageSource = [UIImage]()
    var dataSource = [Data]()
    
    private let loadImageQueue = OperationQueue()
    private var imageOperations = [IndexPath: LoadImageOperation]()
    private var randomImageURL: URL
    
    var source = [IndexPath: UIImage]()
    var cachedIndices = Set<IndexPath>()
    
    init(qos: QualityOfService, imageSourceURL: URL) {
        loadImageQueue.qualityOfService = qos
        randomImageURL = imageSourceURL
        super.init()
    }
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration,
                          delegate: self,
                          delegateQueue: nil)
    }()
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier,
                                                      for: indexPath) as! CardCollectionViewCell
        
        if imageSource.count > indexPath.row {
            cell.previewImageView.image = imageSource[indexPath.row]
        }
        
        if imageCount - indexPath.row < 5 {
            let nextIndexPaths = (0 ..< 5).map {
                IndexPath(row: imageCount + $0, section: 0)
            }
            imageCount += 5
            collectionView.insertItems(at: nextIndexPaths)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return imageCount
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        createOperationsFor indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            guard imageOperations[indexPath] == nil else { return }
            let loadImage = LoadImageOperation(url: randomImageURL, session: session) { [weak self] (image) in
                guard let strongSelf = self else { return }
//                strongSelf.imageSource.append(image)
                strongSelf.source[indexPath] = image
                strongSelf.collectionView(collectionView,
                                          load: image,
                                          atIndexPathIfVisible: indexPath)
            }
            imageOperations[indexPath] = loadImage
            loadImageQueue.addOperation(loadImage)
        }
    }
    
    private func collectionView(_ collectionView: UICollectionView,
                                load image: UIImage,
                                atIndexPathIfVisible indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard collectionView.indexPathsForVisibleItems.contains(indexPath) else {
                //                print("Visible Items: \(collectionView.indexPathsForVisibleItems). Trying for: \(indexPath)")
                return
            }
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CardCollectionViewCell.identifier,
                for: indexPath) as! CardCollectionViewCell
            cell.previewImageView.image = image
        }
    }
}

extension CardCollectionViewDataSource: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as NSData, imageSourceOptions) else {
            return print("Failed to create image source from data")
        }
        
        let downsapleOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                kCGImageSourceShouldCacheImmediately: true,
                                kCGImageSourceCreateThumbnailWithTransform: true] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsapleOptions) else {
            return print("Failed to craete downsampled image.")
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            self.imageSource.append(UIImage(cgImage: downsampledImage))
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else { return }
        print("Session ran into an error: \(error.localizedDescription)")
    }
}

extension CardCollectionViewDataSource: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let lastIndex = indexPaths.last, lastIndex.row > (imageSource.count - 5) else { return }
        self.collectionView(collectionView, createOperationsFor: indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            let operation = imageOperations.removeValue(forKey: $0)
            operation?.cancel()
        }
    }
}

