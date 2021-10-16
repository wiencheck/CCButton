//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/02/2021.
//

import UIKit

extension UIView {
    func pinToSuperviewEdges(margin: CGFloat = 0) {
        guard let superview = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: margin),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: margin),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -margin),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -margin)
        ])
    }
}

extension UIColor {
    class var safeLabelColor: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        }
        return .black
    }
    
    class var safeBackgroundColor: UIColor {
        let alpha: CGFloat = 0.8
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground.withAlphaComponent(alpha)
        }
        return UIColor.white.withAlphaComponent(alpha)
    }
}

extension UIBlurEffect {
    class var safeBackgroundBlurEffect: UIBlurEffect {
        if #available(iOS 13.0, *) {
            return UIBlurEffect(style: .systemUltraThinMaterial)
        }
        return UIBlurEffect(style: .regular)
    }
}

extension UIActivityIndicatorView {
    class var safeIndicatorView: UIActivityIndicatorView {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        }
        return UIActivityIndicatorView(style: .gray)
    }
}
