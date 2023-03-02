//
//  PushTransition.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/22/23.
//

import UIKit

class PushTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    // Returns the duration of the animation
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    // Performs the animation
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // Get the source and destination view controllers and the container view
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView
        
        // Add the destination view to the container view
        containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0
        
        // If the source view controller is ArticlesViewController and it has a table view
        if let fromTableViewController = fromViewController as? ArticlesViewController,
           let fromTableView = fromTableViewController.tableView {
            
            // If a cell was selected, get its index path and frame
            if let selectedIndexPath = fromTableView.indexPathForSelectedRow {
                let indexPath = IndexPath(row: selectedIndexPath.row, section: selectedIndexPath.section)
                let cellFrame = fromTableView.rectForRow(at: indexPath)
                let cellFrameInWindowCoordinates = fromTableView.convert(cellFrame, to: nil)
                let distanceFromTopOfScreen = cellFrameInWindowCoordinates.origin.y
                
                // Move the destination view controller's view to the cell's y-position
                toViewController.view.frame.origin.y = distanceFromTopOfScreen
            }
        }
        
        // Animate the transition
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromViewController.view.alpha = 0
            toViewController.view.alpha = 1
        }) { (finished) in
            fromViewController.view.alpha = 1
            
            // Animate the destination view back to its original position
            UIView.animate(withDuration: 0.2) {
                toViewController.view.frame.origin.y = 0
            }
            
            // Notify the transition context that the transition is complete
            transitionContext.completeTransition(finished)
        }
    }
}
