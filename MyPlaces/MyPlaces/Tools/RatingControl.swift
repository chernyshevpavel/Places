//
//  RaitingControl.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 02.12.2020.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    var rating = 0 {
        didSet {
            updateButtonsState()
        }
    }
    
    private var btnList: [UIButton] = []
    
    @IBInspectable var buttonsSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            removeButtons()
            setUpButtons()
        }
    }
    @IBInspectable var buttonsCount: Int = 5 {
        didSet {
            removeButtons()
            setUpButtons()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setUpButtons()
    }
    
    @objc private func ratingBtnTapped(btn: UIButton) {
        guard let index = btnList.firstIndex(of: btn) else { return }
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    private func setUpButtons() {
        
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0..<buttonsCount {
            let btn = UIButton()
            //Set the button image
            btn.setImage(emptyStar, for: .normal)
            btn.setImage(filledStar, for: .selected)
            btn.setImage(highlightedStar, for: .highlighted)
            btn.setImage(highlightedStar, for: [.highlighted, .selected])
            
            //add constraints
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: buttonsSize.width).isActive = true
            btn.heightAnchor.constraint(equalToConstant: buttonsSize.height).isActive = true
            
            btn.addTarget(self, action: #selector(ratingBtnTapped(btn:)), for: .touchUpInside)
            self.addArrangedSubview(btn)
            btnList.append(btn)
        }
        updateButtonsState()
    }
    
    private func removeButtons() {
        for btn in btnList {
            self.removeArrangedSubview(btn)
            btn.removeFromSuperview()
        }
        btnList.removeAll()
    }
    
    private func updateButtonsState() {
        for (index, btn) in btnList.enumerated() {
            btn.isSelected = index < rating
        }
    }
    
}
