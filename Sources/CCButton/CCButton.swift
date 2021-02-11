//
//  CCButton.swift
//  CCButtonExample
//
//  Created by Adam Wienconek on 10/02/2021.
//

import UIKit

@IBDesignable
public class CCButton: UIControl {
    // - MARK: Public properties
    
    @IBInspectable
    public var image: UIImage? {
        didSet {
            imageView.image = image
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    /**
     Action performed on `.touchUpInside` event.
     */
    public var pressHandler: ((CCButton) -> Void)?
    
    // - MARK: Private properties
    private var usesCustomTintColor = false
    
    // - MARK: Private UI elements
    
    private(set) lazy var imageView: UIImageView = {
        let i = UIImageView(frame: .zero)
        i.tintColor = .safeLabelColor
        i.contentMode = .scaleAspectFit
        return i
    }()
    
    private lazy var colorBackground: UIView = {
        let v = UIView(frame: .zero)
        v.alpha = 0
        return v
    }()
        
    private lazy var blurBackground = UIVisualEffectView(effect: UIBlurEffect.safeBackgroundBlurEffect)
    
    // - MARK: Overrides
    public override var isSelected: Bool {
        didSet {
            #if TARGET_INTERFACE_BUILDER
                updateSelectedState(animated: false)
                setNeedsLayout()
            #else
                updateSelectedState(animated: true)
            #endif
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            #if TARGET_INTERFACE_BUILDER
                updateHighlightedState(animated: false)
                setNeedsLayout()
            #else
                updateHighlightedState(animated: true)
            #endif
        }
    }
    
    public override var tintColor: UIColor! {
        didSet {
            colorBackground.backgroundColor = tintColor
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        updateSelectedState(animated: false)
        updateHighlightedState(animated: false)
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        colorBackground.backgroundColor = tintColor
    }
    
    public override var intrinsicContentSize: CGSize {
        let size: CGFloat = 36
        return CGSize(width: size, height: size)
    }
    
    public override func prepareForInterfaceBuilder() {
        invalidateIntrinsicContentSize()
    }
    
    // - MARK: Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        usesCustomTintColor = (UIView().tintColor != tintColor)
        commonInit()
    }
    
    // - MARK: Private methods
    
    private func commonInit() {
        clipsToBounds = true
        backgroundColor = .clear
        setupView()
        for subview in subviews {
            subview.isUserInteractionEnabled = false
        }
        addTarget(self, action: #selector(handleTouchUp), for: .touchUpInside)
    }
    
    private func updateSelectedState(animated: Bool) {
        func animations() {
            if usesCustomTintColor {
                colorBackground.backgroundColor = tintColor
                imageView.tintColor = isSelected ? .white : .safeLabelColor
            } else {
                colorBackground.backgroundColor = .safeBackgroundColor
                imageView.tintColor = .safeLabelColor
            }
            blurBackground.alpha = isSelected ? 0 : 1
            colorBackground.alpha = isSelected ? 1 : 0
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: animations)
        } else {
            animations()
        }
    }
    
    private func updateHighlightedState(animated: Bool) {
        func animations() {
            alpha = isHighlighted ? 0.7 : 1
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: animations)
        } else {
            animations()
        }
    }
    
    @objc private func handleTouchUp() {
        pressHandler?(self)
    }
}

private extension CCButton {
    func setupView() {
        addSubview(blurBackground)
        blurBackground.pinToSuperviewEdges()
        
        addSubview(colorBackground)
        colorBackground.pinToSuperviewEdges()
        
        let imageViewSizeRatio: CGFloat = 0.6
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: imageViewSizeRatio),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: imageViewSizeRatio)
        ])
    }
}

fileprivate extension UIView {
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

fileprivate extension UIColor {
    class var safeLabelColor: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        }
        return .black
    }
    
    class var safeBackgroundColor: UIColor {
        let alpha: CGFloat = 0.88
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground.withAlphaComponent(alpha)
        }
        return UIColor.white.withAlphaComponent(alpha)
    }
}

fileprivate extension UIBlurEffect {
    class var safeBackgroundBlurEffect: UIBlurEffect {
        if #available(iOS 13.0, *) {
            return UIBlurEffect(style: .systemUltraThinMaterial)
        }
        return UIBlurEffect(style: .regular)
    }
}
