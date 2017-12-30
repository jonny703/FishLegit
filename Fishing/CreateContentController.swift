//
//  CreateContentController.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class CreateContentController: UICollectionViewController {
    
    let cellId = "cellId"
    var contents: Contents?
    
    var createPinDelegate: CreatePinDelegate?
    
    var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
}

//MARK: handle collectionview
extension CreateContentController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CreateContentCell
        
        if let contents = self.contents {
            cell.contents = contents
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    
}


//MARK: handle dismiss, done, save
extension CreateContentController {
    
    @objc fileprivate func handleDismissController() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc fileprivate func handleSaveContent() {
        
        if !(checkInvalid()) {
            return
        }
        
        guard let contents = self.setContents() else {
            self.showJHTAlerttOkayWithIcon(message: "You typed wrong locaton info.")
            return
        }
        
        dismiss(animated: true) {
            self.createPinDelegate?.resetContentsAndLakeMarker(contents: contents)
        }
    }
    
    private func setContents() -> Contents? {
        let cell = self.setCreateContentsCell()
        let contents = Contents()
        
        if let lakeName = cell.lakeNameTextField.text {
            contents.lakeName = lakeName
        }
        if let zoneName = cell.zoneTextField.text {
            contents.zoneName = zoneName
        }
        if let townshipName = cell.townshipTextField.text {
            contents.townshipName = townshipName
        }
        if let kind = cell.kindTextField.text {
            contents.kind = kind
        }
        if let species = cell.speciesTextField.text {
            contents.species = species
        }
        if let latitudeStr = cell.latitudeTextField.text {
            guard let latitude = Double(latitudeStr) else { return nil }
            contents.latitude = latitude
        }
        if let longitudeStr = cell.longitudeTextField.text {
            guard let longitude = Double(longitudeStr) else { return nil }
            contents.longitude = longitude
        }
        if let detail = cell.detailTextView.text {
            contents.detail = detail
        }
        return contents
    }
    
}

//MARK: check invalid
extension CreateContentController {
    
    fileprivate func setCreateContentsCell() -> CreateContentCell {
        let indexPath = IndexPath(item: 0, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as! CreateContentCell
        return cell
    }
    
    fileprivate func checkInvalid() -> Bool {
        
        let cell = self.setCreateContentsCell()
        
        if (cell.lakeNameTextField.text?.isEmpty)! {
            self.showJHTAlerttOkayWithIcon(message: "You missed typing lake name!")
            return false
        }
        if (cell.zoneTextField.text?.isEmpty)! {
            self.showJHTAlerttOkayWithIcon(message: "You missed selecting zone!")
            return false
        }
        if (cell.townshipTextField.text?.isEmpty)! {
            self.showJHTAlerttOkayWithIcon(message: "You missed selecting township!")
            return false
        }
        if (cell.kindTextField.text?.isEmpty)! {
            self.showJHTAlerttOkayWithIcon(message: "You missed selecting kind!")
            return false
        }
        if (cell.speciesTextField.text?.isEmpty)! {
            self.showJHTAlerttOkayWithIcon(message: "You missed selecting species!")
            return false
        }
        if (cell.latitudeTextField.text?.isEmpty)! {
            self.showJHTAlerttOkayWithIcon(message: "You missed typing latitude!")
            return false
        }
        if (cell.longitudeTextField.text?.isEmpty)! {
            self.showJHTAlerttOkayWithIcon(message: "You missed typing longitude!")
            return false
        }
        if (cell.detailTextView.text?.isEmpty)! || cell.detailTextView.text == PlaceHolderText {
            self.showJHTAlerttOkayWithIcon(message: "You missed typing lake detail!")
            return false
        }
        
        return true
        
    }
    
}

//MARK: setup views
extension CreateContentController {
    
    fileprivate func setupViews() {
        setupNavbar()
        setupCollectionView()
    }
    
    private func setupNavbar() {
        navigationController?.isNavigationBarHidden = false
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        titleLabel.text = "Create Content"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        navigationItem.titleView = titleLabel
        
        let backImage = UIImage(named: AssetName.close.rawValue)?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(handleDismissController))
        navigationItem.leftBarButtonItem = backButton
        
        let moreImage = UIImage(named: AssetName.done.rawValue)?.withRenderingMode(.alwaysOriginal)
        let moreButton = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(handleSaveContent))
        navigationItem.rightBarButtonItem = moreButton
    }
    
    private func setupCollectionView() {
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
        }
        
        collectionView?.backgroundColor = .white
        collectionView?.keyboardDismissMode = .interactive
        
        collectionView?.register(CreateContentCell.self, forCellWithReuseIdentifier: cellId)
    }
    
}
