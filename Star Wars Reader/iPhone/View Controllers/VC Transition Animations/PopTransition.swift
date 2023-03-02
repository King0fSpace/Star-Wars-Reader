//
//  PopTransition.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/22/23.
//

import Foundation
import UIKit

class PopTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    // Set the duration of the transition animation
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    // Define the transition animation
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Get the from and to view controllers and the container view
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView

        // Insert the toViewController's view below the fromViewController's view in the container view
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        // Set the initial alpha value of the toViewController's view to 0
        toViewController.view.alpha = 0
        
        // Animate the transition
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            // Set the alpha value of the fromViewController's view to 0 to fade it out
            fromViewController.view.alpha = 0
            // Set the alpha value of the toViewController's view to 1 to fade it in
            toViewController.view.alpha = 1
        }) { (finished) in
            // Set the alpha value of the fromViewController's view back to 1
            fromViewController.view.alpha = 1
            // Complete the transition
            transitionContext.completeTransition(finished)
        }
    }
}
