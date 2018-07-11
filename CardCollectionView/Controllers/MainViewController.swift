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
    }
    
    private func populateData() {
        let width = view.bounds.width
        let height = view.bounds.height
        let randomImageURL = URL(string: "https://picsum.photos/\(width)/\(height)/?random")!
        
        dataSource = CardCollectionViewDataSource(qos: .userInitiated,
                                                  imageSourceURL: randomImageURL)
        dataSource.loadFirstBatch(collectionView)
    }
    
    private func configure() {
        view.backgroundColor = .white
        title = "Browse"
        
        navigationController?.navigationBar.isTranslucent = false
        tabBarController?.tabBar.isTranslucent = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        collectionView.backgroundColor = .white
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(CardCollectionViewCell.self,
                                forCellWithReuseIdentifier: CardCollectionViewCell.identifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
    }
}
