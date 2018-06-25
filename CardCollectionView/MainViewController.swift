//
//  ViewController.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 6/24/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var cardCollectionView: UICollectionView!
    let layout = CardCollectionViewLayout()
    let options: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple]
    var imageSource = [UIImage?]() {
        didSet { cardCollectionView.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        populateData()
        configure()
        constrainViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func configure() {
        view.backgroundColor = .white
        
        cardCollectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        cardCollectionView.translatesAutoresizingMaskIntoConstraints = false
        cardCollectionView.backgroundColor = .clear
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        cardCollectionView.contentInset = UIEdgeInsets.init(top: 0,
                                                            left: layout.itemSpacing,
                                                            bottom: 0,
                                                            right: layout.itemSpacing)
        
        cardCollectionView.register(CardCollectionViewCell.self,
                                    forCellWithReuseIdentifier: CardCollectionViewCell.identifier)
        
        view.addSubview(cardCollectionView)
    }
    
    private func populateData() {
        for _ in 0...100 {
            fetchImage()
        }
    }
    
    private func fetchImage() {
        let width = view.bounds.width
        let height = view.bounds.height
        let randomImageURL = URL(string: "https://picsum.photos/\(width)/\(height)/?random")!
        URLSession.shared.dataTask(with: randomImageURL) { (data, response, error) in
            guard let data = data, error == nil else { return print(error!.localizedDescription) }
            guard let image = UIImage(data: data) else { return print("Failed to convert data to image!") }
            DispatchQueue.main.async { [unowned self] in
                self.imageSource.append(image)
            }
        }.resume()
    }
    
    private func constrainViews() {
        let marginGuide = view.safeAreaLayoutGuide
        cardCollectionView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        cardCollectionView.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        cardCollectionView.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        cardCollectionView.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier,
                                                      for: indexPath) as! CardCollectionViewCell
        cell.previewImageView.image = imageSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageSource.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
    }
}

extension MainViewController: UIScrollViewDelegate {
    
}
