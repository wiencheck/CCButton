//
//  CCButton.swift
//  CCButtonExample
//
//  Created by Adam Wienconek on 10/02/2021.
//

import UIKit

@IBDesignable
public class CCButton: UIControl {
    
    // MARK: Public properties
    
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
    @available(*, deprecated, message: "Use UIAction for .primaryActionTriggered event")
    public var pressHandler: ((CCButton) -> Void)?
    
    /**
     Custom tint color of the image.
     */
    @IBInspectable public var imageTintColor: UIColor? {
        didSet {
            #if TARGET_INTERFACE_BUILDER
                updateSelectedState(animated: false)
                setNeedsLayout()
            #else
                updateSelectedState(animated: true)
            #endif
        }
    }
    
    /**
     Defines styling of the button when in selected state.
     
     Default value is `.highlightBackground`
     */
    @IBInspectable public var selectionStyle: SelectionStyle = .highlightBackground {
        didSet {
            updateSelectedState(animated: false)
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    @available(iOS 14.0, *)
    public var menu: UIMenu? {
        get { magicButton.menu }
        set { magicButton.menu = newValue }
    }
    
    @available(iOS 14.0, *)
    public override var showsMenuAsPrimaryAction: Bool {
        get { magicButton.showsMenuAsPrimaryAction }
        set { magicButton.showsMenuAsPrimaryAction = newValue }
    }
    
    // MARK: Private properties
    private var customTintColor: UIColor?
    private var size: CGFloat = 0
    
    // MARK: Private UI elements
    
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
    
    private lazy var magicButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(nil, for: .normal)
        
        return b
    }()
    
    // MARK: Initialization
    public convenience init(size: CGFloat) {
        self.init(frame: .zero)
        self.size = size
    }
    
    // MARK: Overriden properties
    
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
            if tintColor == superview?.tintColor {
                return
            }
            customTintColor = tintColor
            updateSelectedState(animated: false)
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
        colorBackground.backgroundColor = adjustedBackgroundColor
    }
    
    public override var intrinsicContentSize: CGSize {
        var size: CGFloat = 36
        if self.size > 0 {
            size = self.size
        }
        return CGSize(width: size, height: size)
    }
    
    // MARK: Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: Overriden methods
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        invalidateIntrinsicContentSize()
    }
    
    @available(iOS 14.0, *)
    public override func addAction(_ action: UIAction, for controlEvents: UIControl.Event) {
        super.addAction(action, for: controlEvents)
        
        guard controlEvents.contains(.primaryActionTriggered) else {
            return
        }
        if image == nil {
            image = action.image
        }
        isEnabled = !action.attributes.contains(.disabled)
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin: CGFloat = 8
        
        let newArea = CGRect(
            x: self.bounds.origin.x - margin,
            y: self.bounds.origin.y - margin,
            width: self.bounds.size.width + (2 * margin),
            height: self.bounds.size.height + (2 * margin)
        )
        return newArea.contains(point)
    }
    
}

// MARK: Private
private extension CCButton {
    
    var adjustedBackgroundColor: UIColor {
        switch selectionStyle {
        case .highlightBackground:
            guard isSelected else {
                return .clear
            }
            if let customTintColor = customTintColor {
                return customTintColor
            }
            return .safeBackgroundColor
        case .highlightImage:
            return isSelected ? .safeBackgroundColor : .clear
        }
    }
    
    var adjustedImageColor: UIColor {
        if let imageTint = imageTintColor {
            return imageTint
        }
        switch selectionStyle {
        case .highlightBackground:
            return isSelected ? .white : .safeLabelColor
        case .highlightImage:
            return isSelected ? (customTintColor ?? tintColor) : .safeLabelColor
        }
    }
    
    func commonInit() {
        clipsToBounds = true
        backgroundColor = .clear
        setupView()
        magicButton.addTarget(self,
                              action: #selector(handleTouchUp),
                              for: .touchUpInside)
    }
    
    @objc func handleTouchUp() {
        if #available(iOS 14.0, *), !showsMenuAsPrimaryAction {
            sendActions(for: .primaryActionTriggered)
        }
        sendActions(for: .touchUpInside)
        pressHandler?(self)
    }
    
    func updateSelectedState(animated: Bool) {
        func animations() {
            colorBackground.backgroundColor = adjustedBackgroundColor
            imageView.tintColor = adjustedImageColor
            blurBackground.alpha = isSelected ? 0 : 1
            colorBackground.alpha = isSelected ? 1 : 0
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: animations)
        } else {
            animations()
        }
    }
    
    func updateHighlightedState(animated: Bool) {
        func animations() {
            alpha = isHighlighted ? 0.7 : 1
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: animations)
        } else {
            animations()
        }
    }
    
    func updateLoadingState(animated: Bool) {
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
    
    func updateEnabledState(animated: Bool) {
        func animations() {
            alpha = isEnabled ? 1 : 0.6
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: animations)
        } else {
            animations()
        }
    }
    
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
        addSubview(magicButton)
        magicButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Activate constraints
        NSLayoutConstraint.activate([
            magicButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            magicButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            magicButton.topAnchor.constraint(equalTo: topAnchor),
            magicButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: imageViewSizeRatio),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: imageViewSizeRatio),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
}

public extension CCButton {
    @objc enum SelectionStyle: UInt {
        /**
         Applies styling so that background of the button is filled with color.
         */
        case highlightBackground
        
        /**
         Applies styling so that image of the button is tinted with color.
         */
        case highlightImage
    }
}
