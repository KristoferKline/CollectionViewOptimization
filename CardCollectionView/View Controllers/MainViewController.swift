//
//  ViewController.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 6/24/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

final class MainViewController: UICollectionViewController {
    
    private let layout = CardCollectionViewLayout()
    private var operation: UINavigationController.Operation!
    private var selectedImageFrame = CGRect()
    
    private let loadImageQueue = OperationQueue()
    private var imageOperations = [IndexPath: LoadImageOperation]()
    private var randomImageURL: URL?
    
    var imageCount: Int = 15
    
    var imageSource = [UIImage?]() {
        didSet { DispatchQueue.main.async { self.cardCollectionView.reloadData() } }
    init() {
        super.init(collectionViewLayout: layout)
    }
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration,
                          delegate: self,
                          delegateQueue: nil)
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateData()
        configure()
        constrainViews()
    }
    
    private func configure() {
        view.backgroundColor = .white
        title = "Browse"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        collectionView.backgroundColor = .white
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.prefetchDataSource = dataSource
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(CardCollectionViewCell.self,
                                forCellWithReuseIdentifier: CardCollectionViewCell.identifier)
    }
    
    private func populateData() {
        let width = view.bounds.width
        let height = view.bounds.height
        let randomImageURL = URL(string: "https://picsum.photos/\(width)/\(height)/?random")!
        
        dataSource = CardCollectionViewDataSource(qos: .userInitiated,
                                                  imageSourceURL: randomImageURL)
        
        let startingIndexPaths = (0 ..< 15).map { IndexPath(row: $0, section: 0) }
        dataSource.collectionView(collectionView, createOperationsFor: startingIndexPaths)
    }
    
    private func constrainViews() {
        let marginGuide = view.safeAreaLayoutGuide
        cardCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cardCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cardCollectionView.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        cardCollectionView.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            cardCollectionView.insertItems(at: nextIndexPaths)
        }
        
        return cell
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCount
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
    }
}

extension MainViewController: URLSessionDataDelegate {
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

extension MainViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let lastIndex = indexPaths.last, lastIndex.row > (imageSource.count - 5) else { return }
        beginLoadingImages(for: indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            print("Did cancel prefetch for: \($0.row)")
            let operation = imageOperations.removeValue(forKey: $0)
            operation?.cancel()
        }
    }
}
