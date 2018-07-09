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
    var dataSource = [UIImage]()
    var loadedImages = [IndexPath: UIImage]()
    
    private let loadImageQueue = OperationQueue()
    private var imageOperations = [IndexPath: LoadImageOperation]()
    private var randomImageURL: URL
    
    let serialQueue: DispatchQueue
    let imageQueue: DispatchQueue
    let networkQueue: DispatchQueue
    
    var source = [IndexPath: UIImage]()
    var cachedIndices = Set<IndexPath>()
    
    init(qos: QualityOfService, imageSourceURL: URL) {
        loadImageQueue.qualityOfService = qos
        randomImageURL = imageSourceURL
        
        serialQueue = DispatchQueue(label: "Data Source Queue", qos: .userInitiated)
        imageQueue = DispatchQueue(label: "Image Builder Queue", target: serialQueue)
        networkQueue = DispatchQueue(label: "Image Data Queue", target: serialQueue)
        
        super.init()
    }
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration,
                          delegate: nil,
                          delegateQueue: nil)
    }()
    
    func createImages(for indexPaths: [IndexPath], collectionView: UICollectionView) {
        indexPaths.forEach { indexPath in
            self.loadData(from: self.randomImageURL) { (data, error) in
                guard let data = data, error == nil else {
                    return print("Failed to get image data: \(error!.localizedDescription)")
                }
                self.buildImage(from: data, indexPath: indexPath, collectionView: collectionView)
            }
        }
    }
    
    private func loadData(from imageURL: URL, completion: @escaping (Data?, Error?) -> Void) {
        networkQueue.async { [weak self] in
            self?.session.dataTask(with: imageURL) { (data, response, error) in
                guard let data = data, error == nil else { return completion(nil, error) }
                print("Did retrieve data")
                completion(data, nil)
                }.resume()
        }
    }
    
    private func buildImage(from data: Data, indexPath: IndexPath, collectionView: UICollectionView) {
        imageQueue.async { [weak self] in
            guard let image = UIImage.createCachedThumbnail(with: data) else { return }
            print("Did build image")
            self?.loadedImages[indexPath] = image
            self?.collectionView(collectionView, loadIfVisible: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier,
                                                      for: indexPath) as! CardCollectionViewCell
        
        guard let image = loadedImages[indexPath] else {
            createImages(for: [indexPath], collectionView: collectionView)
            return cell
        }
        
        cell.previewImageView.image = image
        
        if (imageCount - indexPath.row) < 5 {
            let nextIndexPaths = (0 ..< 5).map { IndexPath(row: imageCount + $0, section: 0) }
            imageCount += 5
//            self.collectionView(collectionView, createOperationsFor: nextIndexPaths)
            createImages(for: nextIndexPaths, collectionView: collectionView)
            collectionView.insertItems(at: nextIndexPaths)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return imageCount
    }
    
//    func collectionView(_ collectionView: UICollectionView,
//                        createOperationsFor indexPaths: [IndexPath]) {
//        indexPaths.forEach { indexPath in
//            print("Going to create opreation for: \(indexPath)")
//            guard imageOperations[indexPath] == nil else { return }
//            let loadImage = LoadImageOperation(url: randomImageURL, session: session) { [weak self] (data) in
//                guard let image = UIImage.createCachedThumbnail(with: data) else { return }
//                self?.dataSource.append(image)
//                self?.collectionView(collectionView,
//                                          loadIfVisible: indexPath)
//            }
//            imageOperations[indexPath] = loadImage
//            loadImageQueue.addOperation(loadImage)
//        }
//    }
    
    private func collectionView(_ collectionView: UICollectionView,
                                loadIfVisible indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            guard collectionView.indexPathsForVisibleItems.contains(indexPath) else { return }
            
            let cellImage = strongSelf.loadedImages[indexPath] ?? strongSelf.dataSource.removeFirst()
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CardCollectionViewCell.identifier,
                for: indexPath) as! CardCollectionViewCell
            cell.previewImageView.image = cellImage
        }
    }
}

//extension CardCollectionViewDataSource: UICollectionViewDataSourcePrefetching {
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        indexPaths.forEach { (indexPath) in
//            guard !loadedImages.keys.contains(indexPath), !dataSource.isEmpty else { return }
//            loadedImages[indexPath] = dataSource.removeFirst()
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
//        indexPaths.forEach {
//            let operation = imageOperations.removeValue(forKey: $0)
//            operation?.cancel()
//        }
//    }
//}

