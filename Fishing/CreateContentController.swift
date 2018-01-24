//
//  CreateContentController.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import KRProgressHUD

class CreateContentController: UICollectionViewController {
    
    let cellId = "cellId"
    var contents: Contents?
    let reachAbility = Reachability()!
    
    var createPinDelegate: CreatePinDelegate?
    var editPinDelegate: EditPinDelegate?
    
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
        
        cell.createContentController = self
        
        if let _ = self.createPinDelegate {
            cell.status = .createPin
        } else if let _ = self.editPinDelegate {
            cell.status = .editPin
        }
        
        if let contents = self.contents {
            cell.contents = contents
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    
}

//MARK: handle dismiss, done, save, submit
extension CreateContentController {
    
    func handleSubmit() {
        
        if !(checkInvalid()) {
            return
        }
        
        if let _ = self.createPinDelegate {
            self.handleSubmitNewPin()
        }
        
        if let _ = self.editPinDelegate {
            self.handleSubmitEditPin()
        }
    }
    
    @objc fileprivate func handleSubmitEditPin() {
        guard let userId = UserDefaults.standard.getUserId() else { return }

        guard let contents = self.setContents() else {
            self.showJHTAlerttOkayWithIcon(message: "You typed wrong infomation.")
            return
        }
        
        if reachAbility.connection == .none {
            self.showJHTAlerttOkayWithIcon(message: "The Internet connection appears to be offline.")
            return
        }

        guard let lakeName = contents.lakeName,
            let longitude = contents.longitude,
            let latitude = contents.latitude,
            let type = contents.kind,
            let zone = contents.zoneName,
            let township = contents.townshipName,
            let detail = contents.detail,
            let typeId = contents.typeId else { return }
        
        var species = ""
        if type == LakeType.opportunity.rawValue {
            let speciesName = contents.species ?? ""
            species = getIdWithSpeciesName(speciesName: speciesName)
        }
        
        let lakesId = getIdWithName(name: lakeName, tableName: "lakes")
        
        let lon = String(format: "%f", longitude)
        let lat = String(format: "%f", latitude)
        
        var townshipId = township
        if township != "Unknown Township" {
            townshipId = getIdStringWithName(name: township, tableName: "townships")
        } else {
            townshipId = "0"
        }
        
        var zoneId = zone
        if zone != "Unknown Zone" {
            let character = CharacterSet(charactersIn: "ZONE")
            zoneId = zone.trimmingCharacters(in: character)
        } else {
            zoneId = "0"
        }

        let oldPin = self.handleGetOldData(type: type, typeId: typeId)



        guard let oldLat = oldPin.lat, let oldLon = oldPin.lon, let oldTownship = oldPin.township, let oldZone = oldPin.zone else { return }

//        http://fishlegit.ca/api/get.php?api_pass=blpVcWtjY2IwSWFOTkxncDMxWlVPdz09&act=editpinsubmit&id=%d&user_id=%@&lake_id=%@&name=%@&lon=%@&lat=%@&type=%@&township=%@&type_id=%@&zone=%@&old_lat=%@&old_lon=%@&old_township=%@&old_zone=%@species=%@&detail=%@"
        
        let requestStr = String(format: WebService.editPinSubmit.rawValue, lakesId, userId, lakesId, lakeName, lon, lat, type, townshipId, typeId, zoneId, oldLat, oldLon, oldTownship, oldZone, species, detail)

        print("requestStr: ", requestStr)
        guard let urlStr = requestStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
            return
        }
        guard let requestUrl = URL(string: urlStr) else {
            self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
            return
        }

        KRProgressHUD.show()

        URLSession.shared.dataTask(with: requestUrl) { (data, response, error) in

            if error != nil {
                print("error: ", error!)
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                }
                return
            }

            let dataAsString = String(data: data, encoding: .utf8)
            print(dataAsString!)

            do {
                let pin = try JSONDecoder().decode(Pin.self, from: data)
                print(pin)

                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    
                    self.showJHTAlerttOkayWithIconForAction(message: "Success!\nWe will notify you when it is approved.", action: { (action) in
                        self.dismiss(animated: true) {
                            
                            if let createPinDelegate = self.createPinDelegate {
                                createPinDelegate.resetContentsAndLakeMarker(contents: contents)
                            }
                            
                            if let editPinDelegate = self.editPinDelegate {
                                editPinDelegate.resetContentsAndLakeMarker(contents: contents)
                            }
                        }
                    })
                }


            } catch let jsonErr {
                print("Error serializing error: ", jsonErr)
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                }
            }
            }.resume()
    }
    
    fileprivate func handleSubmitNewPin() {
        
        guard let userId = UserDefaults.standard.getUserId() else { return }
        guard let contents = self.setContents() else {
            self.showJHTAlerttOkayWithIcon(message: "You typed wrong infomation.")
            return
        }
        
        if reachAbility.connection == .none {
            self.showJHTAlerttOkayWithIcon(message: "The Internet connection appears to be offline.")
            return
        }
        
        guard let lakeName = contents.lakeName,
            let longitude = contents.longitude,
            let latitude = contents.latitude,
            let type = contents.kind,
            let zone = contents.zoneName,
            let township = contents.townshipName,
            let detail = contents.detail else { return }
        
        var species = ""
        if type == LakeType.opportunity.rawValue {
            let speciesName = contents.species ?? ""
            species = getIdWithSpeciesName(speciesName: speciesName)
        }
        
        let lakesId = getIdWithName(name: lakeName, tableName: "lakes")
        
        let lon = String(format: "%f", longitude)
        let lat = String(format: "%f", latitude)
        
        var townshipId = township
        if township != "Unknown Township" {
            townshipId = getIdStringWithName(name: township, tableName: "townships")
        } else {
            townshipId = "0"
        }
        
        var zoneId = zone
        if zone != "Unknown Zone" {
            let character = CharacterSet(charactersIn: "ZONE")
            zoneId = zone.trimmingCharacters(in: character)
        } else {
            zoneId = "0"
        }
        
        let requestStr = String(format: WebService.createPinSubmit.rawValue, userId, String(lakesId), lakeName, lon, lat, type, species, zoneId, townshipId, detail)
        guard let urlStr = requestStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
            return
        }
        guard let requestUrl = URL(string: urlStr) else {
            self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
            return
        }
        
        print("create pin: ", requestStr)
        
        KRProgressHUD.show()
        
        URLSession.shared.dataTask(with: requestUrl) { (data, response, error) in
            
            if error != nil {
                print("error: ", error!)
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                }
                return
            }
            
            let dataAsString = String(data: data, encoding: .utf8)
            print(dataAsString!)
            
            do {
                let pin = try JSONDecoder().decode(Pin.self, from: data)
                print(pin)
                
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    
                    self.showJHTAlerttOkayWithIconForAction(message: "Success!\nWe will notify you when it is approved.", action: { (action) in
                        self.dismiss(animated: true) {
                            
                            if let createPinDelegate = self.createPinDelegate {
                                createPinDelegate.resetContentsAndLakeMarker(contents: contents)
                            }
                            
                            if let editPinDelegate = self.editPinDelegate {
                                editPinDelegate.resetContentsAndLakeMarker(contents: contents)
                            }
                        }
                    })
                }
                
                
            } catch let jsonErr {
                print("Error serializing error: ", jsonErr)
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                }
            }
            }.resume()
        
    }
    
    private func handleGetOldData(type: String, typeId: String) -> OldPin {
        
        SCSQLite.initWithDatabase("fishy.sqlite3")
        
        var query = ""
        
        if type == LakeType.opportunity.rawValue {
            query = "SELECT lat, lon, townships, zones FROM features where id=" + typeId
        } else {
            query = "SELECT lat, lon, townships, zone FROM exceptions where id=" + typeId
        }
        
        let array = SCSQLite.selectRowSQL(query)! as NSArray
        let dictionary = array[0] as! NSDictionary
        let lon = dictionary.value(forKey: "lon") as? String
        let lat = dictionary.value(forKey: "lat") as? String
        let township = dictionary.value(forKey: "townships") as? String
        
        var zone: String?
        if type == LakeType.opportunity.rawValue {
            
            if let zoneInt = dictionary.value(forKey: "zones") as? Int {
                zone = String(describing: zoneInt)
            }
            
        } else {
            zone = dictionary.value(forKey: "zone") as? String
        }
        
        let oldPin = OldPin(lon: lon == "" ? "0" : lon, lat: lat == "" ? "0" : lat, township: township == "" ? "0" : township, zone: zone == "" ? "0" : zone)
        return oldPin
    }
    
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
        
        if cell.kindTextField.text == LakeType.opportunity.rawValue {
            if let species = cell.speciesTextField.text {
                contents.species = species
            }
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
        
        if let currentContents = self.contents {
            contents.typeId = currentContents.typeId
        }
        
        return contents
    }
    
    private func getIdWithSpeciesName(speciesName: String) -> String {
        let id = getIdWithName(name: speciesName, tableName: "species")
        
        return String(id)
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
        
        if cell.kindTextField.text == LakeType.opportunity.rawValue {
            if (cell.speciesTextField.text?.isEmpty)! {
                self.showJHTAlerttOkayWithIcon(message: "You missed selecting species!")
                return false
            }
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
        titleLabel.text = "Marker/Pin Data"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        navigationItem.titleView = titleLabel
        
        let backImage = UIImage(named: AssetName.close.rawValue)?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(handleDismissController))
        navigationItem.leftBarButtonItem = backButton
        
//        let moreImage = UIImage(named: AssetName.done.rawValue)?.withRenderingMode(.alwaysOriginal)
//        let moreButton = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(handleSaveContent))
//        navigationItem.rightBarButtonItem = moreButton
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
