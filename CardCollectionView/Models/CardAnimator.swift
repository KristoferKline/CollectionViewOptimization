//
//  CardAnimator.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 6/29/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

final class CardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var duration: TimeInterval = 0.2
    var presenting = true
    var originFrame: CGRect = .zero
    var operation: UINavigationController.Operation
    var transitionContext: UIViewControllerContextTransitioning
//    var panGestureRecognizer: UIPanGestureRecognizer
    
    var transitionAnimator = UIViewPropertyAnimator()
    
    init(operation: UINavigationController.Operation, context: UIViewControllerContextTransitioning) {
        self.operation = operation
        transitionContext = context
        
        setupTransitionAnimator({
            <#code#>
        }) { (<#UIViewAnimatingPosition#>) in
            <#code#>
        }
        
        let string = " "
    }
//    init(operation: Int, context: UIViewControllerContextTransitioning, panGesture: UIPanGestureRecognizer) {
//        self.operation = operation
//        transitionContext = context
//        panGestureRecognizer = panGesture
//    }
    
    func setupTransitionAnimator(_ transitionAnimations: @escaping () -> Void,
                                 completion: @escaping (UIViewAnimatingPosition) -> Void) {
        transitionAnimator = UIViewPropertyAnimator(duration: duration,
                                                    curve: .easeInOut,
                                                    animations: transitionAnimations)
        
        transitionAnimator.addCompletion { [unowned self] (position) in
            completion(position)
            
            let isCompleted = (position == .end)
            self.transitionContext.completeTransition(isCompleted)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        <#code#>
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        <#code#>
    }
    
    func updateIteraction(from gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let translation = gesture.translation(in: transitionContext.containerView)
            let percentComplete = transitionAnimator.fractionComplete

            // Update transition context.
            transitionAnimator.fractionComplete = percentComplete
            transitionContext.updateInteractiveTransition(percentComplete)
            
            // Update transition item for the
            //updateItemsForInteractive(translation: translation)
            
            gesture.setTranslation(.zero, in: transitionContext.containerView)
        case .ended, .cancelled:
            endInteraction()
        default: break
        }
    }
    
    func endInteraction() {
        guard transitionContext.isInteractive else { return }
        
        let completionPosition: UIViewAnimatingPosition!
        if completionPosition == .end {
            transitionContext.finishInteractiveTransition()
        } else {
            transitionContext.cancelInteractiveTransition()
        }
        
        animate(completionPosition)
    }
    
    func animate(_ toPosition: UIViewAnimatingPosition) {
        transitionAnimator.addAnimations {
            imageView?.frame = (toPosition == .end) ? item.targetFrame : item.initailFrame
        }
        
        transitionAnimator.startAnimation()
        
        transitionAnimator.isReversed = (toPosition == .start)
        
        if transitionAnimator.state == .inactive {
            transitionAnimator.startAnimation()
        } else {
            let duractionPercent = CGFloat(duration / transitionAnimator.duration)
            transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: duractionPercent)
        }
    }
    
    func pauseAnimation() {
        
    }
}
