//
//  DisclaimerController.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.

import UIKit

class DisclaimerViewController: UIViewController {
    
    
    let titleLabel: UILabel = {
        
        let label = UILabel()
        label.text = "Disclaimer"
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    let textView: UITextView = {
        
        let textView = UITextView()
        textView.text = AgreeMessages
        textView.isEditable = false
        textView.isSelectable = false
        textView.isUserInteractionEnabled = false
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.textAlignment = .center
        textView.textColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        
        view.backgroundColor = .white
        
        setupViews()
        
        
    }
    
    func setupViews() {
        
        view.addSubview(titleLabel)
        view.addSubview(textView)
        
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    
}
