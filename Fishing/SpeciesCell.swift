//
//  SpeciesCell.swift
//  Fishing
//
//  Created by John Nik on 12/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class SpeciesCell: UITableViewCell {
    
    let lakeLabel: UILabel = {
        let label = UILabel()
        label.text = "Lake:"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let opportunityLabel: UILabel = {
        let label = UILabel()
        label.text = "Zone:"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let exceptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Township:"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    var lakeLabelHeightAncher: NSLayoutConstraint?
    var opportunityLabelHeightAncher: NSLayoutConstraint?
    var exceptionLabelHeightAncher: NSLayoutConstraint?
    
    func setupViews() {
        
        addSubview(lakeLabel)
        addSubview(opportunityLabel)
        addSubview(exceptionLabel)
        
        lakeLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        lakeLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        lakeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        lakeLabelHeightAncher = lakeLabel.heightAnchor.constraint(equalToConstant: 50)
        lakeLabelHeightAncher?.isActive = true

        opportunityLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        opportunityLabel.topAnchor.constraint(equalTo: lakeLabel.bottomAnchor).isActive = true
        opportunityLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        opportunityLabelHeightAncher = opportunityLabel.heightAnchor.constraint(equalToConstant: 50)
        opportunityLabelHeightAncher?.isActive = true
        
        exceptionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        exceptionLabel.topAnchor.constraint(equalTo: opportunityLabel.bottomAnchor).isActive = true
        exceptionLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        exceptionLabelHeightAncher = exceptionLabel.heightAnchor.constraint(equalToConstant: 50)
        exceptionLabelHeightAncher?.isActive = true

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
