//
//  SimpleAnimator.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 6/30/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

final class SimpleAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let originFrame: CGRect
    
    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let form = transitionContext.viewController(forKey: .from),
            let to = transitionContext.viewController(forKey: .to),
            let snapShot = to.view.snapshotView(afterScreenUpdates: true)
            else { return }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: to)
        
        snapShot.frame = originFrame
//        snapShot.
    }
}
