//
//  ArticlesViewConroller+NavigationControllerDelegate.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/28/23.
//

import UIKit

extension ArticlesViewController: UINavigationControllerDelegate {

    // This object is responsible for animating the transition between two view controllers in the navigation stack
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return PushTransition()
        } else if operation == .pop {
            return PopTransition()
        }
        return nil
    }

}
