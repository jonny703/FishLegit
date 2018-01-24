//
//  SliderView.swift
//  Fishing
//
//  Created by John Nik on 23/09/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import WOWMarkSlider

protocol SliderViewDelegate: class {
    
    func didClickSearhButton(distance: Int)
    
}


class SliderView: UIView, WOWMarkSliderDelegate {
    
    var value: Int = 25
    var delegate: SliderViewDelegate!
    
    let showNearestSlider: WOWMarkSlider = {
        
        let slider = WOWMarkSlider()
        slider.markColor = .red
//        slider.markPositions = [0, 25, 50, 75, 99]
        slider.lineCap = .square
        slider.height = 10.0
        slider.markWidth = 3.0
        slider.minimumValue = 0
        slider.maximumValue = 125
        slider.value = 100
        slider.selectedBarColor = .darkGray
        slider.unselectedBarColor = .white
        slider.handlerColor = .black
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
        
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "100 Km"
//        label.sizeToFit()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    
    }()
    
    lazy var searchButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.tintColor = .white
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSearchButton), for: .touchUpInside)
        return button
        
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        
        showNearestSlider.delegate = self
        
        addSubview(showNearestSlider)
        addSubview(searchButton)
        addSubview(distanceLabel)
        
        showNearestSlider.leftAnchor.constraint(equalTo: leftAnchor, constant: 25).isActive = true
        showNearestSlider.rightAnchor.constraint(equalTo: rightAnchor, constant: -25).isActive = true
        showNearestSlider.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        showNearestSlider.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        
        searchButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        searchButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        searchButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        
        distanceLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        distanceLabel.bottomAnchor.constraint(equalTo: searchButton.topAnchor, constant: 0).isActive = true
        distanceLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        distanceLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    @objc func handleSearchButton() {
        delegate.didClickSearhButton(distance: value)
    }
    
    func markSlider(slider: WOWMarkSlider, dragged to: Float) {
        
        value = Int(to)
        distanceLabel.text = String(describing: value) + " Km"
        
        
    }
    
    func startDragging(slider: WOWMarkSlider) {
        
    }
    
    func endDragging(slider: WOWMarkSlider) {
        
        value = Int(slider.value)
        distanceLabel.text = String(format: "%d Km", value)
        
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
