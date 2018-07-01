//
//  ViewController.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 6/24/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    private var cardCollectionView: UICollectionView!
    private let layout = CardCollectionViewLayout()
    private var transition: CardAnimator!
    private var operation: UINavigationController.Operation!
    
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
    
    private func configure() {
        view.backgroundColor = .white
        
        cardCollectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        cardCollectionView.translatesAutoresizingMaskIntoConstraints = false
        cardCollectionView.backgroundColor = .clear
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
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
            
//            guard let image = UIImage(data: data) else { return print("Failed to convert data to image!") }
            DispatchQueue.main.async { [unowned self] in
                self.imageSource.append(UIImage(cgImage: downsampledImage))
//                self.imageSource.append(image)
            }
        }.resume()
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

// MARK: - Collection View Delegate Methods
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
        
        let previewViewController = CardPreviewViewController()
        previewViewController.transitioningDelegate = self
        present(previewViewController, animated: true, completion: nil)
    }
}

// MARK: - Navigation Controller Animation Delegate
extension MainViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.operation = operation
        return self
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }
}

// MARK: - Transition Animations
extension MainViewController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        transition = CardAnimator(operation: operation,
                                  context: transitionContext)
    }
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

extension MainViewController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transition.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        
        containerView.addSubview(toView)
        
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        print(#function)
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return transition
    }
}
