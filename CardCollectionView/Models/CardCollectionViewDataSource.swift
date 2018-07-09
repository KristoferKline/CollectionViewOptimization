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
    var loadingIndices = Set<IndexPath>()
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
    
    func createImage(for indexPath: IndexPath, collectionView: UICollectionView) {
        loadingIndices.insert(indexPath)
        loadData(from: randomImageURL) { (data, error) in
            guard let data = data, error == nil else {
                return print("Failed to get image data: \(error!.localizedDescription)")
            }
            self.buildImage(from: data, indexPath: indexPath, collectionView: collectionView)
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
            self?.loadedImages[indexPath] = image
            print("Did build image: \(indexPath.row): \(self!.loadedImages.count) images loaded")
            self?.collectionView(collectionView, loadIfVisible: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier,
                                                      for: indexPath) as! CardCollectionViewCell
        
        guard let image = loadedImages[indexPath] else {
            if !loadingIndices.contains(indexPath) {
                createImage(for: indexPath, collectionView: collectionView)
            }
            return cell
        }
        
        cell.previewImageView.image = image
        
        if (imageCount - indexPath.row) < 5 {
            let nextIndexPaths = (0 ..< 5).map { IndexPath(row: imageCount + $0, section: 0) }
            imageCount += 5
            nextIndexPaths.forEach { self.createImage(for: $0, collectionView: collectionView) }
            collectionView.insertItems(at: nextIndexPaths)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCount
    }

    private func collectionView(_ collectionView: UICollectionView,
                                loadIfVisible indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            guard collectionView.indexPathsForVisibleItems.contains(indexPath) else { return }
            guard strongSelf.loadedImages.keys.contains(indexPath) else { return }
            collectionView.reloadItems(at: [indexPath])
        }
    }
}
