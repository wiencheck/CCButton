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
    
    /**
     Image displayed inside of the button.
     */
    @IBInspectable public var image: UIImage? {
        didSet {
            imageView.image = image
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    /**
     Toggle this value to display loading indicator inside of the button.
     */
    @IBInspectable public var isLoading: Bool = false {
        didSet {
            isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
            #if TARGET_INTERFACE_BUILDER
                updateLoadingState(animated: false)
                setNeedsLayout()
            #else
                updateLoadingState(animated: true)
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
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.safeIndicatorView
        indicator.hidesWhenStopped = false
        indicator.alpha = 0
        return indicator
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
    
    public override var isEnabled: Bool {
        didSet {
            #if TARGET_INTERFACE_BUILDER
                updateEnabledState(animated: false)
                setNeedsLayout()
            #else
                updateEnabledState(animated: true)
            #endif
        }
    }
    
    public override var tintColor: UIColor! {
        didSet {
            usesCustomTintColor = (tintColor != nil)
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
    
    private func updateLoadingState(animated: Bool) {
        func animations() {
            imageView.alpha = isLoading ? 0 : 1
            loadingIndicator.alpha = isLoading ? 1 : 0
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: animations)
        } else {
            animations()
        }
    }
    
    private func updateEnabledState(animated: Bool) {
        func animations() {
            alpha = isEnabled ? 1 : 0.6
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
        
        addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Activate constraints
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: imageViewSizeRatio),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: imageViewSizeRatio),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
