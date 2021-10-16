//
//  ViewController.swift
//  CCButtonExample
//
//  Created by Adam Wienconek on 10/02/2021.
//

import UIKit
import CCButton

class ViewController: UIViewController {
    
    @IBOutlet private var buttons: [CCButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleButtons(animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        toggleButtons(animated: false)
        toggleButtons(animated: true)
    }
    
    private func toggleButtons(animated: Bool) {
        guard animated else {
            buttons.forEach({
                $0.isSelected.toggle()
                $0.selectionStyle = .highlightImage
            })
            return
        }
        for (idx, button) in buttons.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.7 * Double(idx + 1))) {
                button.isSelected.toggle()
            }
        }
    }

    @IBAction func cloudPressed(_ sender: CCButton) {
        sender.isLoading.toggle()
    }
}

