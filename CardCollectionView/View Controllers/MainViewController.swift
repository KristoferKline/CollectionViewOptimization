//
//  ViewController.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 6/24/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
    
    private var cardCollectionView: UICollectionView!
    private let layout = CardCollectionViewLayout()
    private var operation: UINavigationController.Operation!
    private var selectedImageFrame = CGRect()
    
    private let loadImageQueue = OperationQueue()
    private var imageOperations = [IndexPath: LoadImageOperation]()
    private var randomImageURL: URL?
    
    var imageCount: Int = 15
    
    var imageSource = [UIImage?]() {
        didSet { DispatchQueue.main.async { self.cardCollectionView.reloadData() } }
    }
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration,
                          delegate: self,
                          delegateQueue: nil)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadImageQueue.qualityOfService = .userInitiated
        loadImageQueue.maxConcurrentOperationCount = 10
        populateData()
        configure()
        constrainViews()
    }
    
    private func configure() {
        view.backgroundColor = .white
        
        cardCollectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        cardCollectionView.translatesAutoresizingMaskIntoConstraints = false
        cardCollectionView.backgroundColor = .clear
        cardCollectionView.delegate = self
        cardCollectionView.prefetchDataSource = self
        cardCollectionView.dataSource = self
        
        cardCollectionView.register(CardCollectionViewCell.self,
                                    forCellWithReuseIdentifier: CardCollectionViewCell.identifier)
        
        view.addSubview(cardCollectionView)
    }
    
    private func populateData() {
        let width = view.bounds.width
        let height = view.bounds.height
        randomImageURL = URL(string: "https://picsum.photos/\(width)/\(height)/?random")
        
        let startingIndexPaths = (0 ..< imageCount).map { IndexPath(row: $0, section: 0) }
        beginLoadingImages(for: startingIndexPaths)
    }
    
    private func beginLoadingImages(for indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            guard imageOperations[indexPath] == nil else { return }
            print("Added prefetch operation: \(indexPath.row)")
            let loadImage = LoadImageOperation(url: randomImageURL!, session: session) { [weak self] (image) in
                guard let strongSelf = self else { return }
                strongSelf.imageSource.append(image)
                strongSelf.collectionView(strongSelf.cardCollectionView,
                                          load: image,
                                          atIndexPathIfVisible: indexPath)
            }
            imageOperations[indexPath] = loadImage
            loadImageQueue.addOperation(loadImage)
        }
    }
    
    private func collectionView(_ collectionView: UICollectionView, load image: UIImage, atIndexPathIfVisible indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard collectionView.indexPathsForVisibleItems.contains(indexPath) else {
                print("Visible Items: \(collectionView.indexPathsForVisibleItems). Trying for: \(indexPath)")
                return
            }
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CardCollectionViewCell.identifier,
                for: indexPath) as! CardCollectionViewCell
            cell.previewImageView.image = image
        }
    }
    
    private func fetchImages() {
        let task = session.dataTask(with: randomImageURL!)
        task.resume()
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
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCount
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: - Collection View Delegate Methods
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
