//
//  ArticleViewController+ScrollDelegate.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/20/23.
//

import Foundation
import UIKit

extension ArticleViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
        // MARK: - Change Image Height

        // Adjust the image height based on user's scrolling
        let height = self.view.frame.size.height/2 - (self.scrollView.contentOffset.y)
        if (height > 275) {
            self.imageHeightConstraint.constant = height
        }
        
        
        // MARK: - Nav Bar appearance

        // Fade in navigation bar as user scrolls up
        var alpha = (self.scrollView.contentOffset.y - 50) / 100
        if alpha >= 0.95 {
            alpha = 0.95
        }
        
        // Configure navigation bar appearance with transparent background and fade-in effect
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = UIColor.black.withAlphaComponent(alpha)
        if let backArrowImage = UIImage(named: "chevron.backward") {
            appearance.setBackIndicatorImage(backArrowImage.withRenderingMode(.alwaysOriginal), transitionMaskImage: backArrowImage.withRenderingMode(.alwaysOriginal))
        }
        
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.compactAppearance = appearance
        navigationItem.largeTitleDisplayMode = .always

        // Set preference for large title on navigation bar to false
        navigationController?.navigationBar.prefersLargeTitles = false
        
        
        // MARK: - Article Title Animation
        
        // Animate title label onto navigation bar when it approaches the navigation bar
        let titleYPosition = scrollView.convert(self.articleTitleLabel.frame, to: self.view).minY

        guard let navBarHeight = self.navigationController?.navigationBar.frame.size.height else { return }
        if (titleYPosition < navBarHeight * 2) {
            
            if (self.titleOnNavBar == false) {
                self.titleOnNavBar = true
                self.articleTitleLabel.isHidden = true
                
                // Create a new label with the same properties as the original label
                navBarLabel = UILabel(frame: self.articleTitleLabel.frame)
                navBarLabel.text = self.articleTitleLabel.text
                navBarLabel.font = self.articleTitleLabel.font
                navBarLabel.textColor = self.articleTitleLabel.textColor
                
                if let navBar = self.navigationController?.navigationBar {
                    // Add the new label to the navigation bar's view
                    navBar.addSubview(navBarLabel)
                    let articleTitleFrame = self.articleTitleLabel.frame
                    let convertedFrame = articleTitleLabel.superview?.convert(articleTitleFrame, to: navigationController?.navigationBar)
                    
                    if let frame = convertedFrame {
                        navBarLabel.frame = frame
                    }
                    
                    // Animate the new label to the center of the navigation bar's view
                    let navBarCenter = CGPoint(x: navBar.frame.size.width/2, y: navBar.frame.size.height/2)
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveLinear], animations: {
                        self.navBarLabel.center = navBarCenter
                        self.navBarLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    }, completion: { _ in
                        
                    })
                }
            }
        }
        else if (titleYPosition >= navBarHeight) {
            let animatedTitleLabel = UILabel(frame: navBarLabel.frame)
            
            if (self.titleOnNavBar == true) {
                self.titleOnNavBar = false
                navBarLabel.isHidden = true
                
                // Create a new label with the same properties as the original label
                animatedTitleLabel.text = navBarLabel.text
                animatedTitleLabel.font = navBarLabel.font
                animatedTitleLabel.textColor = navBarLabel.textColor
                animatedTitleLabel.transform = navBarLabel.transform
                
                // Add the new label to the scroll view's view
                self.scrollView.addSubview(animatedTitleLabel)
                let navBarLabelFrame = navBarLabel.frame
                let convertedFrame = navBarLabel.superview?.convert(navBarLabelFrame, to: self.scrollView)
                
                if let frame = convertedFrame {
                    animatedTitleLabel.frame = frame
                }
                
                // Animate the new label to the center of the navigation bar's view
                UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveLinear], animations: {
                    animatedTitleLabel.center = self.articleTitleLabel.center
                    animatedTitleLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: { _ in
                    // Clean up after animation completes
                    self.navBarLabel.text = ""
                    animatedTitleLabel.removeFromSuperview()
                    self.articleTitleLabel.isHidden = false
                })
            }
        }
    }
}

