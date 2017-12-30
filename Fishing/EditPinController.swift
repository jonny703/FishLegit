//
//  EditPinController.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import KRProgressHUD
import PopOverMenu
import AZDropdownMenu
import JHTAlertController

let kOFFSET_FOR_KEYBOARD: CGFloat = 135.0

class EditPinController: UIViewController {
    
    let reachAbility = Reachability()!
    
    var filteredArray = [String]()
    var resultsArray = [String]()
    var markers = [LakeMarker]()
    var lakeInfos = [LakeInfo]()
    
    var currentLocation = CLLocationCoordinate2D(latitude: 40.0, longitude: -70.0)
    var currentMarker: LakeMarker?
    var currentIndex: Int?
    var currentLakeId: Int?
    
    let dataProvider = GoogleDataProvider()
    var alertController: JHTAlertController?
    
    var titleLabel: UILabel!
    var resultDropdownMenu: AZDropdownMenu?
    
    lazy var googleMapView: GMSMapView = {
        
        var map = GMSMapView()
        
        let camera = GMSCameraPosition.camera(withLatitude: -7.9293122, longitude: 112.5879156, zoom: 100.0)
        
        map = GMSMapView.map(withFrame: CGRect.zero , camera: camera)
        map.settings.consumesGesturesInView = false
        map.delegate = self
        return map
        
    }()
    
    let mapTypeSegement: UISegmentedControl = {
        
        let segement = UISegmentedControl(items: ["Normal", "Satellite"])
        segement.translatesAutoresizingMaskIntoConstraints = false
        segement.tintColor = StyleGuideManager.fishLegitDefultBlueColor
        segement.selectedSegmentIndex = 0
        segement.addTarget(self, action: #selector(handelMapType), for: .valueChanged)
        return segement
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupVars()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObserver()
    }
}

//MARK: handle keyboard
extension EditPinController: UITextFieldDelegate {
    
    fileprivate func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc fileprivate func keyboardWillShow() {
        guard let rect = self.alertController?.view.frame else { return }
        if rect.origin.y >= 0 {
            self.setViewMoveUp(moveUp: true)
        }
    }
    
    @objc fileprivate func keyboardWillHide() {
        guard let rect = self.alertController?.view.frame else { return }
        if rect.origin.y < 0 {
            self.setViewMoveUp(moveUp: false)
        }
    }
    
    private func setViewMoveUp(moveUp: Bool) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        guard var rect = self.alertController?.view.frame else { return }
        if moveUp {
            rect.origin.y -= kOFFSET_FOR_KEYBOARD
            rect.size.height += kOFFSET_FOR_KEYBOARD
        } else {
            rect.origin.y += kOFFSET_FOR_KEYBOARD
            rect.size.height -= kOFFSET_FOR_KEYBOARD
        }
        self.alertController?.view.frame = rect
        UIView.commitAnimations()
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.tag == 1 {
            guard let rect = self.alertController?.view.frame else { return }
            if rect.origin.y >= 0 {
                self.setViewMoveUp(moveUp: true)
            }
        }
    }
}

//MARK: handle alerts
extension EditPinController {
    
    fileprivate func handleShowResetLocationAlert() {
        
        guard let currentMarker = self.currentMarker, let currentIndex = self.currentIndex else {
            self.showJHTAlertDefaultWithIcon(message: "No search results.\nDo you want to search a lake?", firstActionTitle: "No", secondActionTitle: "Yes", action: { (action) in
                
                self.handleSearchPopList()
            })
            return
        }
        
        let title = currentMarker.place.lakeName
        self.handleShowTextFieldAlert(title: title, marker: currentMarker, index: currentIndex)
    }
    
    fileprivate func handleShowTextFieldAlert(title: String, marker: LakeMarker, index: Int) {
        
        alertController = JHTAlertController(title: title, message: "You can type location.\nNote: -90<Latitude<+90\n           -180<Longitude<+180", preferredStyle: .alert)
        alertController?.titleViewBackgroundColor = .white
        alertController?.titleTextColor = .black
        alertController?.alertBackgroundColor = .white
        alertController?.messageFont = .systemFont(ofSize: 15)
        alertController?.messageTextColor = .black
        alertController?.setAllButtonBackgroundColors(to: .white)
        alertController?.dividerColor = .black
        alertController?.setButtonTextColorFor(.default, to: .red)
        alertController?.setButtonTextColorFor(.cancel, to: .black)
        alertController?.hasRoundedCorners = true
        
        let cancelAction = JHTAlertAction(title: "Later", style: .cancel,  handler: nil)
        let okAction = JHTAlertAction(title: "OK", style: .default) { (action) in
            
            self.currentMarker = marker
            self.currentIndex = index
            
            guard let latTextField = self.alertController?.textFields?.first else { return }
            guard let lonTextField = self.alertController?.textFields?[1] else { return }
            
            if let latStr = latTextField.text, let lonStr = lonTextField.text {
                
                if latStr.isEmpty {
                    self.handleShowMissedLocationAlert(str: "latitude")
                    return
                }
                if lonStr.isEmpty {
                    self.handleShowMissedLocationAlert(str: "longitude")
                    return
                }
                
                self.resetFakeLakeWith(latStr: latStr, lonStr: lonStr, marker: marker, index: index)
            }
            
        }
        
        alertController?.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Latitude"
            textField.backgroundColor = .white
            textField.textColor = .black
            textField.keyboardType = .decimalPad
            textField.borderStyle = .roundedRect
            textField.tag = 0
            
            let accesorry = self.setInputAccessoryView(tag: 0)
            textField.inputAccessoryView = accesorry
            
            if marker.place.distance != 40000 {
                let lonStr = String(marker.place.coordinate.latitude)
                textField.text = lonStr
            }
        }
        
        alertController?.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Longitude"
            textField.backgroundColor = .white
            textField.textColor = .black
            textField.keyboardType = .decimalPad
            textField.borderStyle = .roundedRect
            textField.tag = 1
            let accesorry = self.setInputAccessoryView(tag: 1)
            textField.inputAccessoryView = accesorry
            
            if marker.place.distance != 40000 {
                let latStr = String(marker.place.coordinate.longitude)
                textField.text = latStr
            }
        }
        
        alertController?.addAction(cancelAction)
        alertController?.addAction(okAction)
        
        present(alertController!, animated: true, completion: nil)
        
    }
    
    private func resetFakeLakeWith(latStr: String, lonStr: String, marker: LakeMarker, index: Int) {
        
        guard let lat = Double(latStr) else { return }
        guard let lon = Double(lonStr) else { return }
        
        let lakePlace = self.resetLakePlaceWith(lat: lat, lon: lon, marker: marker)
        
        let tempMarker = self.setMarkerWith(place: lakePlace)
        self.markers[index] = tempMarker
        
        let lakeInfo = self.setLakeInfoWith(place: lakePlace, radius: 10)
        self.lakeInfos[index] = lakeInfo
        
        let result = self.setResultStr(place: lakePlace)
        self.resultsArray[index] = result
        
        self.resultDropdownMenu = self.setResultsDropDownMenu(resultsArray: self.resultsArray)
        
        self.googleMapView.clear()
        tempMarker.map = self.googleMapView
        
        self.currentMarker = tempMarker
        
        self.focusLakeForSearch(index: index)
    }
    
    fileprivate func resetLakePlaceWith(lat: Double, lon: Double, marker: LakeMarker) -> LakePlace {
        
        let place = marker.place
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
        
        let lakePlace = LakePlace(lakeName: place.lakeName , townshipName: place.townshipName , opportunity: place.opportunity , exception: place.exception, coordinate: coordinate , distance: 10.0 , type: place.type )
        return lakePlace
        
    }
    
    private func handleShowMissedLocationAlert(str: String) {
        self.showJHTAlertDefaultWithIcon(message: "You missed typing \(str).\nDo you want to try again?", firstActionTitle: "No", secondActionTitle: "Yes", action: { (action) in
            self.handleShowResetLocationAlert()
        })
    }
    
    private func setInputAccessoryView(tag: Int) -> UIView {
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
            textField = (self.alertController?.textFields![0])!
        } else if sender.tag == 11 {
            textField = (self.alertController?.textFields![1])!
        } else {
            return
        }
        
        textField.resignFirstResponder()
    }
    
    @objc private func changeNumberSing(sender: UIButton) {
        var textField: UITextField
        if sender.tag == 0 {
            textField = (self.alertController?.textFields![0])!
        } else if sender.tag == 1 {
            textField = (self.alertController?.textFields![1])!
        } else {
            return
        }
        
        if (textField.text?.hasPrefix("-"))! {
            guard let index = textField.text?.index((textField.text?.startIndex)!, offsetBy: 1) else { return }
//            textField.text = textField.text?.substring(from: index)
            let text = String(textField.text![index...])
            textField.text = text
            
        } else {
            textField.text = String(format: "-%@", textField.text!)
        }
        
    }
    
}

//MARK: handle result dropdown menu
extension EditPinController {
    
    @objc fileprivate func handleShowResultDropdownMenu() {
        
        if self.resultsArray.isEmpty {
            
            self.showJHTAlertDefaultWithIcon(message: "No search results.\nDo you want to search a lake?", firstActionTitle: "No", secondActionTitle: "Yes", action: { (action) in
                
                self.handleSearchPopList()
            })
            return
        }
        
        if self.resultDropdownMenu?.isDescendant(of: self.view) == true {
            self.resultDropdownMenu?.hideMenu()
        } else {
            self.resultDropdownMenu?.showMenuFromRect(CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height, width: 100, height: 100))
        }
        
    }
    
    fileprivate func setResultsDropDownMenu(resultsArray: [String]) -> AZDropdownMenu {
        
        let menu = AZDropdownMenu(titles: resultsArray)
        menu.itemFontSize = 16.0
        menu.itemFontName = "Helvetica"
        menu.cellTapHandler = { [weak self] (indexPath: IndexPath) -> Void in
            
            if let marker = self?.markers[indexPath.row] {
                
                if Int(marker.place.distance) != 40000 {
                    
                    self?.currentMarker = marker
                    self?.currentIndex = indexPath.row

                    self?.googleMapView.clear()
                    marker.map = self?.googleMapView
                    self?.focusLakeForSearch(index: indexPath.row)
                } else {
                    let title = "This lake has no location info."
                    self?.handleShowTextFieldAlert(title: title, marker: marker, index: indexPath.row)
                }
                
            }
        }
        
        return menu
    }
}

//MARK: handle search lake
extension EditPinController {
    
    fileprivate func handleSearchPopList() {
        
        SRPopView.sharedManager().shouldShowAutoSearchBar = true
        
        SRPopView.show(withButton: titleLabel, andArray: filteredArray, andHeading: "FishLegit") { (lakeName) in
            
            guard let lakeName = lakeName else { return }
            self.handleSearchWith(lakeName: lakeName)
            
        }
    }
    
    private func handleSearchWith(lakeName: String) {
        let id = getIdWithName(name: lakeName, tableName: "lakes")
        self.fetchLakesWith(kind: SearchStatus.EditLake, id: id, coordinate: self.currentLocation, radius: 40000)
    }
}

//MARK: handle popover menu
extension EditPinController: UIAdaptivePresentationControllerDelegate {
    
    @objc fileprivate func handlePopoverMenu(sender: UIBarButtonItem) {
        
        let menus = ["Search Lake", "Search Results", "Reset Location", "Submit"]
        let popoverMenuController = PopOverViewController.instantiate()
        popoverMenuController.setTitles(menus)
        popoverMenuController.setSeparatorStyle(.singleLine)
        popoverMenuController.popoverPresentationController?.barButtonItem = sender
        popoverMenuController.preferredContentSize = CGSize(width: 150, height: 180)
        popoverMenuController.presentationController?.delegate = self
        popoverMenuController.completionHandler = { selectRow in
            
            switch (selectRow) {
            case 0:
                self.handleSearchPopList()
                break
            case 1:
                self.handleShowResultDropdownMenu()
                break
            case 2:
                self.handleShowResetLocationAlert()
                break
            case 3:
                self.handleSubmit()
                break
            default:
                break
            }
            
        }
        
        present(popoverMenuController, animated: true, completion: nil)
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}

//MARK: handle fetch
extension EditPinController {
    func fetchLakesWith(kind: String, id: Int, coordinate: CLLocationCoordinate2D, radius: Double) {
        
        dataProvider.fetchLakesWithKind(kind: kind, id: id, currentTownship: "", coordinate: coordinate, radius: radius) { (places) in
            
            self.lakeInfos.removeAll()
            self.markers.removeAll()
            self.resultsArray.removeAll()
            
            for place: LakePlace in places {
                
                self.currentLakeId = id
                
                let marker = self.setMarkerWith(place: place)
                let result = self.setResultStr(place: place)
                let lakeInfo = self.setLakeInfoWith(place: place, radius: radius)
                
                self.lakeInfos.append(lakeInfo)
                self.markers.append(marker)
                self.resultsArray.append(result)
            }
            
            self.resultDropdownMenu = self.setResultsDropDownMenu(resultsArray: self.resultsArray)
            self.handleShowResultDropdownMenu()
        }
    }
    
    fileprivate func setLakeInfoWith(place: LakePlace, radius: Double) -> LakeInfo {
        let lakeInfo = LakeInfo()
        lakeInfo.radius = String(radius) + " Km"
        if Int(place.distance) != 40000 {
            lakeInfo.lake = place.lakeName + ": " + String(Int(place.distance)) + "Km"
            lakeInfo.radius = "true"
        } else {
            lakeInfo.lake = place.lakeName + ": " + "Unknown"
            lakeInfo.radius = "fake"
        }
        
        if place.type == LakeType.opportunity.rawValue {
            lakeInfo.opportunity = place.opportunity
        } else {
            lakeInfo.opportunity = place.exception
        }
        lakeInfo.coordinate = place.coordinate
        
        return lakeInfo
    }
    
    fileprivate func setMarkerWith(place: LakePlace) -> LakeMarker {
        let marker = LakeMarker(place: place, type: place.type, isDraggable: true)
        
        marker.title = place.lakeName
        if place.type == LakeType.opportunity.rawValue {
            marker.snippet = place.opportunity
        } else {
            marker.snippet = place.exception
        }
        
        return marker
    }

    fileprivate func setResultStr(place: LakePlace) -> String {
        
        var result: String
        
        if place.type == LakeType.opportunity.rawValue {
            result = "Opportunity"
        } else {
            result = "Exception"
        }
        
        if Int(place.distance) != 40000 {
            
            result += " at " + place.coordinate.latitude.clean + ", " + place.coordinate.longitude.clean
        }
        
        if place.townshipName != "" {
            result += " in " + place.townshipName
        }
        
        return result
    }
    
    fileprivate func focusLakeForSearch(index: Int) {
        if lakeInfos.count > 0 {
            
            if lakeInfos[index].radius == "true" {
                self.googleMapView.animate(toLocation: lakeInfos[index].coordinate!)
            } else {
                googleMapView.animate(toLocation: currentLocation)
            }
            
        } else {
            googleMapView.animate(toLocation: currentLocation)
        }
        let zoom = self.calculateZoomLevel(radius: 100)
        KRProgressHUD.dismiss()
        googleMapView.animate(toZoom: Float(zoom))
    }
    
    fileprivate func calculateZoomLevel(radius: Double) -> Int {
        
        let scale: Double = radius * 50
        let zoomLevel = Int(19 - log(scale) / log(2))
        return zoomLevel < 0 ? 0 : zoomLevel > 20 ? 20 : zoomLevel
    }
}

//MARK: handle segement
extension EditPinController {
    @objc fileprivate func handelMapType() {
        
        if mapTypeSegement.selectedSegmentIndex == 0 {
            googleMapView.mapType = .normal
        } else {
            googleMapView.mapType = .satellite
            
        }
    }
}

//MARK: handle google mapdelegate
extension EditPinController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("tapped marker")
        
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
//        KRProgressHUD.show()
//        
//        currentLocation = myLocation
//        
//        perform(#selector(handleZoneAndTownship), with: nil, afterDelay: 0.5)
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
//        containerSearchView.isHidden = true
//        tableView.isHidden = true
//        searchController.dismiss(animated: false, completion: nil)
//        //        homeCircularSliderView.removeFromSuperview()
//        sliderViw.isHidden = true
//        containerZoneInfoView.isHidden = true
//
//        if self.specisShowHideStatus == .show {
//            handleShowHideSpeciesView()
//        }
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        
        guard let currentMarker = self.currentMarker else { return }
        guard let currentIndex = self.currentIndex else { return }
        
        self.resetCurrentMarkerWith(currentIndex: currentIndex, currentMarker: currentMarker, marker: marker)
    }
    
    private func resetCurrentMarkerWith(currentIndex: Int, currentMarker: LakeMarker, marker: GMSMarker) {
        let lakePlace = self.resetLakePlaceWith(lat: marker.position.latitude, lon: marker.position.longitude, marker: currentMarker)
        let tempMarker = self.setMarkerWith(place: lakePlace)
        self.markers[currentIndex] = tempMarker
        
        let lakeInfo = self.setLakeInfoWith(place: lakePlace, radius: 10)
        self.lakeInfos[currentIndex] = lakeInfo
        
        let result = self.setResultStr(place: lakePlace)
        self.resultsArray[currentIndex] = result
        
        self.resultDropdownMenu = self.setResultsDropDownMenu(resultsArray: self.resultsArray)
        
        self.currentMarker = tempMarker
    }
}

//MARK: handle dismiss, submit
extension EditPinController {
    
    @objc fileprivate func handleDismissController() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc fileprivate func handleSubmit() {
        guard let userId = UserDefaults.standard.getUserId() else { return }
        guard let lakeId = self.currentLakeId, let currentMarker = self.currentMarker else {
            self.showJHTAlerttOkayWithIcon(message: "No contents to submit.")
            return
        }
        
        if reachAbility.connection == .none {
            self.showJHTAlerttOkayWithIcon(message: "The Internet connection appears to be offline.")
            return
        }
        
        let lakeName = currentMarker.place.lakeName
        let longitude = currentMarker.place.coordinate.longitude
        let lon = String(format: "%f", longitude)
        let latitude = currentMarker.place.coordinate.latitude
        let lat = String(format: "%f", latitude)
        let type = currentMarker.place.type
        let township = String(getIdWithName(name: currentMarker.place.townshipName, tableName: "townships"))
        
        let requestStr = String(format: WebService.editPinSubmit.rawValue, lakeId, userId, lakeName, lon, lat, type, township)
        
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
                    self.showJHTAlerttOkayWithIcon(message: "Success!\nWe will notify you when it is approved.")
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
    
}

//MARK: handle views, vars
extension EditPinController {
    
    fileprivate func setupViews() {
        setupNavbar()
        setGoogleMap()
        setupSegments()
        
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
    
     private func setupSegments() {
        
        view.addSubview(mapTypeSegement)
        
        mapTypeSegement.widthAnchor.constraint(equalToConstant: 120).isActive = true
        mapTypeSegement.heightAnchor.constraint(equalToConstant: 30).isActive = true
        mapTypeSegement.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        mapTypeSegement.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        
    }
    
    private func setGoogleMap() {
        self.view = googleMapView
        
        googleMapView.isMyLocationEnabled = true
        googleMapView.settings.myLocationButton = true
        
        googleMapView.animate(toLocation: currentLocation)
        googleMapView.animate(toZoom: 10)
    }
    
    private func setupNavbar() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        titleLabel.text = "Edit Pin"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        navigationItem.titleView = titleLabel
        
        let backImage = UIImage(named: AssetName.close.rawValue)?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(handleDismissController))
        navigationItem.leftBarButtonItem = backButton
        
        let moreImage = UIImage(named: AssetName.moreSolid.rawValue)?.withRenderingMode(.alwaysOriginal)
        let moreButton = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(handlePopoverMenu(sender:)))
        navigationItem.rightBarButtonItem = moreButton
    }
    
}
