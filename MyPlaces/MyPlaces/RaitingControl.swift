//
//  RaitingControl.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 02.12.2020.
//

import UIKit

@IBDesignable class RaitingControl: UIStackView {
    
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
    
    @objc private func raitingBtnTapped(btn: UIButton) {
        //MARK: todo
    }
    
    private func setUpButtons() {
        for _ in 0..<buttonsCount {
            let btn = UIButton()
            btn.backgroundColor = .red
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: buttonsSize.width).isActive = true
            btn.heightAnchor.constraint(equalToConstant: buttonsSize.height).isActive = true
            btn.addTarget(self, action: #selector(raitingBtnTapped(btn:)), for: .touchUpInside)
            self.addArrangedSubview(btn)
            btnList.append(btn)
        }
    }
    
    private func removeButtons() {
        for btn in btnList {
            self.removeArrangedSubview(btn)
            btn.removeFromSuperview()
        }
        btnList.removeAll()
    }
    
}
