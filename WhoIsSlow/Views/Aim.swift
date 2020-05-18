//
//  Aim.swift
//  WhoIsSlow
//
//  Created by Anton Miroshnyk on 5/15/20.
//  Copyright © 2020 Anton Miroshnyk. All rights reserved.
//

import UIKit

class Aim: UIView {
    
    func removeFromSuperviewAnimated(isSuccessful: Bool? = nil) {
        animateRemoving(isSuccessful: isSuccessful)
        super.removeFromSuperview()
    }
        
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.textColor = .systemBackground
        return label
    }()
    
    init(size: CGFloat) {
        super.init(frame: .zero)
        frame.size = .init(width: size, height: size)
        backgroundColor = .link
        layer.cornerRadius = size / 2
        
        addSubview(label)
        label.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateRemoving(isSuccessful: Bool? = nil) {
        guard let superview = self.superview else {
            return
        }
        
        let shadow = UIView()
        if let isSuccessful = isSuccessful {
            shadow.backgroundColor = isSuccessful ? .systemGreen : .systemRed
        } else {
            shadow.backgroundColor = self.backgroundColor
        }
        shadow.frame.size = self.frame.size
        shadow.layer.cornerRadius = self.frame.size.width / 2
        shadow.center = self.center
        superview.insertSubview(shadow, at: 0)
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            shadow.alpha = 0
        }) { (_) in
            shadow.removeFromSuperview()
        }
    }
    
}
