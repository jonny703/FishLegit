//
//  CreateContentCell.swift
//  Fishing
//
//  Created by John Nik on 11/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

let PlaceHolderText = "Type detail here..."

enum CreateContentCellStatus {
    case createPin
    case editPin
}

class CreateContentCell: UICollectionViewCell {
    
    var createContentController: CreateContentController?
    var status: CreateContentCellStatus? {
        
        didSet {
            if self.status == .createPin {
                self.lakeNameTextField.isUserInteractionEnabled = true
                self.speciesTextField.isUserInteractionEnabled = true
            } else {
                self.lakeNameTextField.isUserInteractionEnabled = false
                self.speciesTextField.isUserInteractionEnabled = false
            }
        }
    }
    
    var speciesTextFieldHeightConstraint: NSLayoutConstraint?
    var detailTextViewHeightConstraint: NSLayoutConstraint?
    
    var titleLabel: UILabel!
    var filteredArray = [String]()
    
    var contents: Contents? {
        
        didSet {
            
            if let lakeName = contents?.lakeName {
                
                if lakeName == "Unknown Lake" {
                    lakeNameTextField.placeholder = "Choose Lake"
                } else {
                    lakeNameTextField.text = lakeName
                }
            }
            
            if let zoneName = contents?.zoneName {
                zoneTextField.text = zoneName
            }
            if let townshipName = contents?.townshipName {
                townshipTextField.text = townshipName
            }
            if let kind = contents?.kind, kind != "" {
                kindTextField.text = kind
                
                self.kindTextField.isUserInteractionEnabled = false
                self.handleSpeciesDetailInCase(kind: kind)
            }
            if let species = contents?.species {
                speciesTextField.text = species
            }
            if let latitude = contents?.latitude {
                latitudeTextField.text = String(latitude)
            }
            if let longitude = contents?.longitude {
                longitudeTextField.text = String(longitude)
            }
            if let detail = contents?.detail {
                detailTextView.text = detail
                detailTextView.textColor = .black
            }
            
        }
    }
    
    lazy var lakeNameTextField: ToplessTextField = {
        let textField = ToplessTextField()
        textField.placeholder = "Type Lake"
        textField.isUserInteractionEnabled = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .black
        textField.delegate = self
        textField.addTarget(self, action: #selector(handleSearchPopList), for: .touchDown)
        return textField
    }()
    
    lazy var zoneTextField: ToplessTextField = {
        let textField = ToplessTextField()
        textField.placeholder = "Select Zone"
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .black
        textField.delegate = self
        
//        textField.addTarget(self, action: #selector(showMenu(sender:)), for: .touchDown)
        
        return textField
    }()
    
    lazy var townshipTextField: ToplessTextField = {
        let textField = ToplessTextField()
        textField.placeholder = "Select Township"
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .black
        textField.delegate = self
        
//        textField.addTarget(self, action: #selector(showMenu(sender:)), for: .touchDown)
        
        return textField
    }()
    
    lazy var kindTextField: ToplessTextField = {
        let textField = ToplessTextField()
        textField.placeholder = "Select Kind"
        textField.isUserInteractionEnabled = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .black
        textField.delegate = self
        
        textField.addTarget(self, action: #selector(showMenu(sender:)), for: .touchDown)
        
        return textField
    }()
    
    lazy var speciesTextField: ToplessTextField = {
        let textField = ToplessTextField()
        textField.placeholder = "Select Species"
        textField.isUserInteractionEnabled = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .black
        textField.delegate = self
        
        textField.addTarget(self, action: #selector(showMenu(sender:)), for: .touchDown)
        
        return textField
    }()
    
    lazy var latitudeTextField: ToplessTextField = {
        let textField = ToplessTextField()
        textField.isUserInteractionEnabled = false
        textField.placeholder = "Latitude(-90<Latitude<+90)"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .black
        
        textField.keyboardType = .decimalPad
        textField.tag = 0
        let accesorry = self.setInputAccessoryView(tag: 0)
        textField.inputAccessoryView = accesorry
        return textField
    }()
    
    lazy var longitudeTextField: ToplessTextField = {
        let textField = ToplessTextField()
        textField.isUserInteractionEnabled = false
        textField.placeholder = "Longitude(-180<Longitude<+180)"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderColor = .black
        
        textField.keyboardType = .decimalPad
        textField.tag = 1
        let accesorry = self.setInputAccessoryView(tag: 1)
        textField.inputAccessoryView = accesorry
        return textField
    }()
    
    let detailTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textAlignment = .left
        textView.layer.cornerRadius = 6
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.black.cgColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    lazy var submitButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = StyleGuideManager.fishLegitDefultBlueColor
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        self.setupViews()
        setupVars()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupVars() {
        SCSQLite.initWithDatabase("fishy.sqlite3")
        let query = "SELECT id, name FROM lakes"
        let array = SCSQLite.selectRowSQL(query)! as NSArray
        filteredArray.removeAll()
        
        for i in 0  ..< (array.count)  {
            let dictionary = array[i] as! NSDictionary
            let nameLake = dictionary.value(forKey: "name") as? String
            let idLake = dictionary.value(forKey: "id") as? Int
            if let name = nameLake {
                if idLake != nil {
                    filteredArray.append(name)
                }
            }
        }
        filteredArray = filteredArray.sorted()
    }
}

//MARK: handle search lake
extension CreateContentCell {
    
    @objc fileprivate func handleSearchPopList() {
        
        SRPopView.sharedManager().shouldShowAutoSearchBar = true
        
        SRPopView.show(withButton: titleLabel, andArray: filteredArray, andHeading: "FishLegit") { (lakeName) in
            
            guard let lakeName = lakeName else { return }
            self.lakeNameTextField.text = lakeName
            
        }
    }
}

//MARK: handle submit
extension CreateContentCell {
    
    @objc fileprivate func handleSubmit() {
        
        self.endEditing(true)
        self.createContentController?.handleSubmit()
    }
    
}

//MARK: handle setup views
extension CreateContentCell {
    
    fileprivate func setupViews() {
        addSubview(lakeNameTextField)
        addSubview(zoneTextField)
        addSubview(townshipTextField)
        addSubview(kindTextField)
        addSubview(speciesTextField)
        addSubview(latitudeTextField)
        addSubview(longitudeTextField)
        addSubview(detailTextView)
        addSubview(submitButton)
        
        lakeNameTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        lakeNameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        lakeNameTextField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        lakeNameTextField.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        
        zoneTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        zoneTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        zoneTextField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        zoneTextField.topAnchor.constraint(equalTo: lakeNameTextField.bottomAnchor, constant: 0).isActive = true
        
        townshipTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        townshipTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        townshipTextField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        townshipTextField.topAnchor.constraint(equalTo: zoneTextField.bottomAnchor, constant: 0).isActive = true
        
        kindTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        kindTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        kindTextField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        kindTextField.topAnchor.constraint(equalTo: townshipTextField.bottomAnchor, constant: 0).isActive = true
        
        speciesTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        speciesTextFieldHeightConstraint = speciesTextField.heightAnchor.constraint(equalToConstant: 40)
        speciesTextFieldHeightConstraint?.isActive = true
        speciesTextField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        speciesTextField.topAnchor.constraint(equalTo: kindTextField.bottomAnchor, constant: 0).isActive = true
        
        latitudeTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        latitudeTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        latitudeTextField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        latitudeTextField.topAnchor.constraint(equalTo: speciesTextField.bottomAnchor, constant: 0).isActive = true
        
        longitudeTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        longitudeTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        longitudeTextField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        longitudeTextField.topAnchor.constraint(equalTo: latitudeTextField.bottomAnchor, constant: 0).isActive = true
        
        detailTextView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        detailTextViewHeightConstraint = detailTextView.heightAnchor.constraint(equalToConstant: 150)
        detailTextViewHeightConstraint?.isActive = true
        detailTextView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        detailTextView.topAnchor.constraint(equalTo: longitudeTextField.bottomAnchor, constant: 10).isActive = true
        
        detailTextView.delegate = self
        detailTextView.text = PlaceHolderText
        detailTextView.textColor = UIColor.lightGray
        
        submitButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        submitButton.topAnchor.constraint(equalTo: detailTextView.bottomAnchor, constant: 10).isActive = true
    }
}

//MARK: handle picker title, array
extension CreateContentCell {
    
    private func setArrayWith(typeStr: String) -> [String] {
        
        var names = [String]()
        
        SCSQLite.initWithDatabase("fishy.sqlite3")
        let query = "SELECT id, name FROM \(typeStr)"
        
        let array = SCSQLite.selectRowSQL(query)! as NSArray
        
        for i in 0  ..< (array.count)  {
            let dictionary = array[i] as! NSDictionary
            let nameLake = dictionary.value(forKey: "name") as? String
            let idLake = dictionary.value(forKey: "id") as? Int
            if let name = nameLake {
                if idLake != nil {
                    names.append(name)
                }
            }
        }
        
        names = names.sorted()
        return names
    }
    
    fileprivate func setPickerTitleWith(sender: ToplessTextField) -> String {
        var title = ""
        if sender == zoneTextField {
            title = "Select Zone"
        } else if sender == kindTextField {
            title = "Select Kind"
        } else if sender == townshipTextField {
            title = "Select Township"
        } else if sender == speciesTextField {
            title = "Select Species"
        }
        
        return title
    }
    
    fileprivate func setPickerArrayWith(sender: ToplessTextField) -> [String] {
        var array = [String]()
        if sender == zoneTextField {
            array = ["Zone1", "Zone2", "Zone3", "Zone4", "Zone5", "Zone6", "Zone7", "Zone8", "Zone9", "Zone10", "Zone11", "Zone12", "Zone13", "Zone14", "Zone15", "Zone16", "Zone17", "Zone18", "Zone19", "Zone20"]
        } else if sender == kindTextField {
            array = [LakeType.opportunity.rawValue, LakeType.exception.rawValue]
        } else if sender == townshipTextField {
            array = self.setArrayWith(typeStr: "townships")
        } else if sender == speciesTextField {
            array = self.setArrayWith(typeStr: "species")
        }
        return array
    }
    
    fileprivate func setPickerWith(title: String, array: [String], sender: ToplessTextField) -> ActionSheetStringPicker {
        
        let picker = ActionSheetStringPicker(title: title, rows: array, initialSelection: 0, doneBlock: { (nil, index, value) in
            
            if let lakeName = value as? String {
                sender.text = lakeName
                
                self.handleSpeciesDetailInCase(kind: lakeName)
            }
            
        }, cancel: { (cancelPicker) in
            return
        }, origin: sender)
        
        let doneImage = UIImage(named: AssetName.checked.rawValue)?.withRenderingMode(.alwaysOriginal)
        let doneButton = UIBarButtonItem(image: doneImage, style: .plain, target: nil, action: nil)
        
        let cancelImage = UIImage(named: AssetName.cancelPicker.rawValue)?.withRenderingMode(.alwaysOriginal)
        let cancelButton = UIBarButtonItem(image: cancelImage, style: .plain, target: nil, action: nil)
        
        picker?.setDoneButton(doneButton)
        picker?.setCancelButton(cancelButton)
        
        return picker!
        
    }
    
    private func handleSpeciesDetailInCase(kind: String) {
        
        if kind == LakeType.opportunity.rawValue {
            self.speciesTextFieldHeightConstraint?.constant = 40
//            self.detailTextViewHeightConstraint?.constant = 0
        } else if kind == LakeType.exception.rawValue {
            self.speciesTextFieldHeightConstraint?.constant = 0
//            self.detailTextViewHeightConstraint?.constant = 150
        }
    }
}


//MARK: handle textfield Picker
extension CreateContentCell: UITextFieldDelegate {
    @objc fileprivate func showMenu(sender: ToplessTextField) {
        
        self.endEditing(true)
        
        let title = self.setPickerTitleWith(sender: sender)
        let array = self.setPickerArrayWith(sender: sender)
        let picker = self.setPickerWith(title: title, array: array, sender: sender)
        
        picker.show()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == latitudeTextField || textField == longitudeTextField {
            return true
        } else {
            return false
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == latitudeTextField || textField == longitudeTextField {
            return true
        } else {
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

//MARK: handle decimal number pad
extension CreateContentCell {
    fileprivate func setInputAccessoryView(tag: Int) -> UIView {
        let inputAccesorryView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        inputAccesorryView.backgroundColor = StyleGuideManager.keyboardBackgroundColor
        let width = DEVICE_WIDTH / 3 - 5
        let minusButton = UIButton(frame: CGRect(x: 0, y: 5, width: width, height: 30))
        minusButton.setTitle("-", for: .normal)
        minusButton.setTitleColor(.black, for: .normal)
        minusButton.backgroundColor = .clear
        minusButton.tag = tag
        minusButton.addTarget(self, action: #selector(changeNumberSing(sender: )), for: .touchUpInside)
        
        let returnButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - width, y: 0, width: width, height: 40))
        returnButton.setTitle("Return", for: .normal)
        returnButton.setTitleColor(.black, for: .normal)
        returnButton.backgroundColor = .clear
        returnButton.tag = 10 + tag
        returnButton.addTarget(self, action: #selector(dismissKeyboard(sender:)), for: .touchUpInside)
        
        inputAccesorryView.addSubview(minusButton)
        inputAccesorryView.addSubview(returnButton)
        
        return inputAccesorryView
    }
    
    @objc private func dismissKeyboard(sender: UIButton) {
        var textField: UITextField
        if sender.tag == 10 {
            textField = self.latitudeTextField
        } else if sender.tag == 11 {
            textField = self.longitudeTextField
        } else {
            return
        }
        
        textField.resignFirstResponder()
    }
    
    @objc private func changeNumberSing(sender: UIButton) {
        var textField: UITextField
        if sender.tag == 0 {
            textField = self.latitudeTextField
        } else if sender.tag == 1 {
            textField = self.longitudeTextField
        } else {
            return
        }
        
        if (textField.text?.hasPrefix("-"))! {
            guard let index = textField.text?.index((textField.text?.startIndex)!, offsetBy: 1) else { return }
//            textField.text = textField.text?.substring(from: index!)
            textField.text = String(textField.text![index...])
        } else {
            textField.text = String(format: "-%@", textField.text!)
        }
        
    }
}

//MARK: textView delegate to use placeholder

extension CreateContentCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = PlaceHolderText
            textView.textColor = UIColor.lightGray
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if range.length == 0 {
            if text == "\n" {
                textView.text = String(format: "%@\n", textView.text)
                return false
            }
        }
        
        
        return true
    }
}
