//
//  KeyButton.swift
//

import UIKit

@IBDesignable
class KeyButton: UIButton {
    @IBInspectable var bgColor: UIColor = .systemGroupedBackground {
        didSet {
            self.setNeedsLayout()
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 4

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let bglayer = self.layer as? CAShapeLayer else {
            return
        }
        bglayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadius).cgPath
        bglayer.fillColor = self.bgColor.cgColor

        if self.state == .highlighted {
            bglayer.shadowColor = UIColor.clear.cgColor
        } else {
            bglayer.shadowColor = UIColor.darkGray.cgColor
            bglayer.shadowPath = bglayer.path
            bglayer.shadowOffset = CGSize(width: 0, height: 1)
            bglayer.shadowOpacity = 0.8
            bglayer.shadowRadius = 0.5
        }
    }
}
