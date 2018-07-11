//
//  CardCollectionViewDataSource.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 7/4/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

typealias Object = NSObject

// TODO: Add addition state handling of images to retry for failed images.
enum CellState: Hashable {
    case loading
    case loaded
    case failed
}

final class CardCollectionViewDataSource: Object, UICollectionViewDataSource {
    private let cellBufferCount = 10
    private var imageCount = 0
    private var loadedStates = [IndexPath: CellState]()
    private var loadedImages = [IndexPath: UIImage]()
    
    private var randomImageURL: URL
    
    private let serialQueue: DispatchQueue
    private let imageQueue: DispatchQueue
    private let networkQueue: DispatchQueue
    
    private var source = [IndexPath: UIImage]()
    private var cachedIndices = NSOrderedSet()
    private var indicesToReload = Set<IndexPath>()
    private var indicesToInsert = Set<IndexPath>()
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration)
    }()
    
    init(qos: QualityOfService, imageSourceURL: URL) {
        randomImageURL = imageSourceURL
        serialQueue = DispatchQueue(label: "Data Source Queue", qos: .userInitiated, attributes: .concurrent)
        imageQueue = DispatchQueue(label: "Image Builder Queue", target: serialQueue)
        networkQueue = DispatchQueue(label: "Image Data Queue", target: serialQueue)
        super.init()
    }
    
    func loadFirstBatch(_ collectionView: UICollectionView) {
        for i in 0 ..< cellBufferCount {
            createImage(for: IndexPath(row: i, section: 0), collectionView: collectionView)
        }
    }
    
    private func preloadImages(_ collectionView: UICollectionView) {
        // Adding a guard to make sure we're not overloading the network with too many requests.
        let nextIndexPaths = (0 ..< cellBufferCount).map { IndexPath(row: loadedStates.count + $0,
                                                                     section: 0) }
        nextIndexPaths.forEach { self.createImage(for: $0, collectionView: collectionView) }
        collectionView.insertItems(at: nextIndexPaths)
    }
    
    private func createImage(for indexPath: IndexPath, collectionView: UICollectionView) {
        // Make sure the image hasn't already been loaded.
        guard !loadedStates.keys.contains(indexPath) else { return }
        loadedStates[indexPath] = .loading
        loadData(from: randomImageURL) { [weak self] (data, error) in
            guard let data = data, error == nil else {
                return print("Failed to get image data: \(error!.localizedDescription)")
            }
            self?.buildImage(from: data, indexPath: indexPath, collectionView: collectionView)
        }
    }
    
    private func loadData(from imageURL: URL, completion: @escaping (_ imageData: Data?, _ error: Error?) -> Void) {
        networkQueue.async { [weak self] in
            self?.session.dataTask(with: imageURL) { (data, response, error) in
                guard let data = data, error == nil else { return completion(nil, error) }
                completion(data, nil)
                }.resume()
        }
    }
    
    private func buildImage(from data: Data, indexPath: IndexPath, collectionView: UICollectionView) {
        imageQueue.async { [weak self] in
            guard let image = UIImage.createCachedThumbnail(with: data) else { return }
            self?.loadedImages[indexPath] = image
            self?.loadedStates[indexPath] = .loaded
            print("Did build image: \(indexPath.row): \(self!.loadedImages.count) images loaded")
            self?.loadIfVisible(indexPath, in: collectionView)
        }
    }
    
    private func loadIfVisible(_ indexPath: IndexPath, in collectionView: UICollectionView) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            guard collectionView.indexPathsForVisibleItems.contains(indexPath) else { return }
            guard strongSelf.loadedImages.keys.contains(indexPath) else { return }
            let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
            cell.previewImageView.image = strongSelf.loadedImages[indexPath]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Preload next batch of images.
        if (loadedStates.count - indexPath.row) < cellBufferCount {
            preloadImages(collectionView)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier,
                                                      for: indexPath) as! CardCollectionViewCell
        cell.previewImageView.image = loadedImages[indexPath]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedStates.count
    }
}
