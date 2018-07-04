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
    private var dataSource: CardCollectionViewDataSource!
    
    init() {
        super.init(collectionViewLayout: layout)
    }
    
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
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
    }
}
