//
//  EditPinController.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//
/*
{
    id: "6",
    user_id: "24",
    lake_id: "17",
    name: "lake",
    lon: "12.32",
    lat: "332.32",
    created: "2018-01-08 05:43:10",
    active: "-1",
    type: "opportunity",
    edit_new: "Edit",
    zone: "",
    township: "town",
    detail: "",
    id2: "6",
    user_id2: "24",
    lake_id2: "17",
    name2: "lake",
    lon2: "",
    lat2: "",
    created2: "2018-01-08 05:43:10",
    active2: "-1",
    type2: "opportunity",
    zone2: "",
    township2: "",
    detail2: ""
}
*/

import UIKit
import GoogleMaps
import GooglePlaces
import KRProgressHUD
import PopOverMenu
import AZDropdownMenu
import JHTAlertController

let kOFFSET_FOR_KEYBOARD: CGFloat = 135.0

protocol EditPinDelegate {
    func resetContentsAndLakeMarker(contents: Contents)
}

class EditPinController: UIViewController {
    
    var polylines = [GMSPolyline]()
    var zoneMarkers = [GMSMarker]()
    var gmsPaths = [GMSPath]()
    
    let reachAbility = Reachability()!
    
    var filteredArray = [String]()
    var resultsArray = [String]()
    var markers = [LakeMarker]()
    var lakeInfos = [LakeInfo]()
    
    var contents: Contents?
    
    var currentLocation = CLLocationCoordinate2D(latitude: 40.0, longitude: -70.0)
    var currentMarkerLocation = CLLocationCoordinate2D(latitude: 40.0, longitude: -70.0)
    var currentZone = "Unknown Zone"
    var currentTownship = "Unknown Township"
    
    var currentMarker: LakeMarker?
    var currentIndex: Int?
    var currentLakeId: Int?
    
    let dataProvider = GoogleDataProvider()
    var alertController: JHTAlertController?
    
    var parseStatus = ParseStatus.Zone
    
    var eName: String = String()
    var zoneName = String()
    var coordinate = String()
    var zones = [Zone]()
    
    var townshipName = String()
    var townshipCoordinate = String()
    var townships = [Township]()
    
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
    
    lazy var showBorderSwitch: UISwitch = {
        let borderSwitch = UISwitch()
        borderSwitch.onTintColor = StyleGuideManager.fishLegitDefultBlueColor
        borderSwitch.backgroundColor = .gray
        borderSwitch.layer.cornerRadius = 16
        borderSwitch.translatesAutoresizingMaskIntoConstraints = false
        borderSwitch.addTarget(self, action: #selector(handleShowZoneBorderSwitch(sender:)), for: .valueChanged)
        return borderSwitch
    }()
    
    let mapTypeSegement: UISegmentedControl = {
        
        let segement = UISegmentedControl(items: ["Normal", "Satellite"])
        segement.translatesAutoresizingMaskIntoConstraints = false
        segement.tintColor = StyleGuideManager.fishLegitDefultBlueColor
        segement.selectedSegmentIndex = 0
        segement.addTarget(self, action: #selector(handelMapType), for: .valueChanged)
        return segement
    }()
    
    let invalidCommandLabel: UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        label.backgroundColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        return label
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupVars()
        
        self.handleSetMarker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupJoyStick()
        self.addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObserver()
    }
}

extension EditPinController: JoystickDelegate {
    func handleJoyStick(angle: CGFloat, displacement: CGFloat) {
        
//        print("joystick point", angle, displacement)
        
        let x = sin(angle * CGFloat.pi / 180.0) * displacement * 0.001
        let y = cos(angle * CGFloat.pi / 180.0) * displacement * 0.001
        
        self.currentMarker?.place.coordinate.longitude += Double(x)
        self.currentMarker?.place.coordinate.latitude += Double(y)
        
        print("joystick point", self.currentMarker?.place.coordinate.longitude, self.currentMarker?.place.coordinate.latitude)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.001)
        self.currentMarker?.position = (self.currentMarker?.place.coordinate)!
        CATransaction.commit()
        
        if displacement == 0.0 {
            KRProgressHUD.show()
            guard let contents = self.setContents() else { return }
            self.contents = contents
            self.currentMarkerLocation = (self.currentMarker?.place.coordinate)!
            
            self.contents?.latitude = self.currentMarker?.position.latitude
            self.contents?.longitude = self.currentMarker?.position.longitude
            
            self.perform(#selector(setTownshipZone), with: nil, afterDelay: 1.0)
            self.googleMapView.clear()
            self.currentMarker?.map = self.googleMapView
//            self.focusLakeMarker()
            return
        }
        
        
    }
    
    
}

extension EditPinController {
    
    fileprivate func handleSetMarker() {
        
        KRProgressHUD.show()
        perform(#selector(setCurrentTownshipZone), with: nil, afterDelay: 1)
        
        guard let marker = self.currentMarker else { return }
        guard let contents = self.setContents() else { return }
        self.contents = contents
        
        self.googleMapView.clear()
        marker.map = self.googleMapView
        self.handleShowZoneBorders()
        self.focusLakeMarker()
    }
    
    @objc private func setCurrentTownshipZone() {
        self.townshipName = self.handleGetTownship()
        self.zoneName = self.handleGetZone()
        
        KRProgressHUD.dismiss()
    }
}

//MARK: handle zone borders feedback
extension EditPinController {
    
    func setInvalidCommandLabel() {
        view.addSubview(invalidCommandLabel)
        
        invalidCommandLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        invalidCommandLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        invalidCommandLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        invalidCommandLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        invalidCommandLabel.alpha = 0
    }
    
    func showAlert(warnigString: String) {
        
        invalidCommandLabel.text = warnigString
        fadeViewInThenOut(view: invalidCommandLabel, delay: 3)
        
    }
    
    func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
        
        let animationDuration = 0.25
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 1
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
                view.alpha = 0
            }, completion: nil)
        }
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
        self.handleShowZoneBorders()
        tempMarker.map = self.googleMapView
        
        self.currentMarker = tempMarker
        
        self.focusLakeForSearch(index: index)
    }
    
    fileprivate func resetLakePlaceWith(lat: Double, lon: Double, marker: LakeMarker) -> LakePlace {
        
        let place = marker.place
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
        
        let lakePlace = LakePlace(lakeName: place.lakeName , townshipName: place.townshipName , opportunity: place.opportunity , exception: place.exception, coordinate: coordinate , distance: 10.0 , type: place.type, typeId: place.typeId, species: place.species)
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
                    self?.handleShowZoneBorders()
                    self?.focusLakeForSearch(index: indexPath.row)
                } else {
//                    self?.handleShowAlertForNoLocation(marker: marker, index: indexPath.row)
                    
                    self?.handleSetMarkerForNoLocation(marker: marker, index: indexPath.row)
                }
                
            }
        }
        
        return menu
    }
    
    private func handleShowAlertForNoLocation(marker: LakeMarker, index: Int) {
        let title = "This lake has no location info."
        self.handleShowTextFieldAlert(title: title, marker: marker, index: index)
    }
    
    private func handleSetMarkerForNoLocation(marker: LakeMarker, index: Int) {
        let centerPoint = self.googleMapView.center
        let centerCoordinate = googleMapView.projection.coordinate(for: centerPoint)
        currentMarkerLocation = centerCoordinate
        
        let latStr = String(currentMarkerLocation.latitude)
        let lonStr = String(currentMarkerLocation.longitude)
        
        self.resetFakeLakeWith(latStr: latStr, lonStr: lonStr, marker: marker, index: index)
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

extension EditPinController: EditPinDelegate {
    func resetContentsAndLakeMarker(contents: Contents) {
        
        self.contents = contents
        let lakePlace = self.setLakePlaceWith(contents: contents)
        let lakeMarker = self.setMarkerWith(place: lakePlace)
        
        self.resetLakeMarkerWith(marker: lakeMarker)
        self.focusLakeMarker()
        
    }
    
    fileprivate func resetLakeMarkerWith(marker: LakeMarker) {
        self.googleMapView.clear()
        marker.map = self.googleMapView
        handleShowZoneBorders()
        self.currentMarker = marker
    }
    
    fileprivate func setLakePlaceWith(contents: Contents) -> LakePlace {
        
        var lakeName = ""
        var townshipName = ""
        var opportunity = ""
        var exception = ""
        var coordinate = CLLocationCoordinate2D(latitude: 45, longitude: -80)
        var type = LakeType.opportunity.rawValue
        
        if let lake = contents.lakeName {
            lakeName = lake
        }
        if let township = contents.townshipName {
            townshipName = township
        }
        
        if let detail = contents.detail {
            if contents.kind == LakeType.opportunity.rawValue {
                opportunity = "Opportunity: " + detail
            } else {
                exception = "Exception: " + detail
            }
        }
        if let latitude = contents.latitude, let longitude = contents.longitude {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        if let lakeType = contents.kind {
            type = lakeType
        }
        
        let lakePlace = LakePlace(lakeName: lakeName, townshipName: townshipName, opportunity: opportunity, exception: exception, coordinate: coordinate, distance: 10, type: type, typeId: "0", species: contents.species)
        
        return lakePlace
    }
}

//MARK: update content
extension EditPinController {
    fileprivate func handleUpdatingContents() {
        
        guard let contents = self.contents else {
            return
        }
        
        contents.townshipName = self.townshipName
        contents.zoneName = self.zoneName
        
        let layout = UICollectionViewFlowLayout()
        let createContentController = CreateContentController(collectionViewLayout: layout)
        createContentController.contents = contents
        createContentController.editPinDelegate = self
        let navController = UINavigationController(rootViewController: createContentController)
        
        present(navController, animated: true, completion: nil)
    }
    
    private func setContents() -> Contents? {
        
        let contents = Contents()
        
        guard let lakeName = self.currentMarker?.place.lakeName else { return nil }
        guard let lat = self.currentMarker?.place.coordinate.latitude else { return nil }
        guard let lon = self.currentMarker?.place.coordinate.longitude else { return nil }
        guard let kind = self.currentMarker?.place.type else { return nil }
        guard let opportunity = self.currentMarker?.place.opportunity else { return nil }
        guard let exception = self.currentMarker?.place.exception else { return nil }
        guard let typId = self.currentMarker?.place.typeId else { return nil }
        
        contents.lakeName = lakeName
        contents.latitude = lat
        contents.longitude = lon
        contents.kind = kind
        contents.typeId = typId
        if kind == LakeType.opportunity.rawValue {
            contents.detail = opportunity
            contents.species = self.currentMarker?.place.species
        } else {
            contents.detail = exception
        }
        
        contents.townshipName = self.currentTownship
        contents.zoneName = self.currentZone
        
        return contents
    }
    
}

//MARK: handle popover menu
extension EditPinController: UIAdaptivePresentationControllerDelegate {
    
    @objc fileprivate func handlePopoverMenu(sender: UIBarButtonItem) {
        
        let menus = ["Marker/Pin Data"]
        let popoverMenuController = PopOverViewController.instantiate()
        popoverMenuController.setTitles(menus)
        popoverMenuController.setSeparatorStyle(.singleLine)
        popoverMenuController.popoverPresentationController?.barButtonItem = sender
        popoverMenuController.preferredContentSize = CGSize(width: 150, height: 45)
        popoverMenuController.presentationController?.delegate = self
        popoverMenuController.completionHandler = { selectRow in
            
            switch (selectRow) {
            case 0:
                self.handleUpdatingContents()
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
    
    fileprivate func focusLakeMarker() {
        if let marker = self.currentMarker {
            self.googleMapView.animate(toLocation: marker.place.coordinate)
            self.currentMarkerLocation = marker.place.coordinate
        } else {
            self.googleMapView.animate(toLocation: currentLocation)
        }
        let zoom = self.calculateZoomLevel(radius: 100)
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
    
//    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
//
//        guard let currentMarker = self.currentMarker else { return }
//        guard let currentIndex = self.currentIndex else { return }
//
//        self.resetCurrentMarkerWith(currentIndex: currentIndex, currentMarker: currentMarker, marker: marker)
//    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        
        guard let currentMarker = self.currentMarker else { return }
        
        self.resetCurrentMarkerWith(currentMarker: currentMarker, marker: marker)
    }
    
    private func resetCurrentMarkerWith(currentMarker: LakeMarker, marker: GMSMarker) {
        
        KRProgressHUD.show()
        
        let lakePlace = self.resetLakePlaceWith(lat: marker.position.latitude, lon: marker.position.longitude, marker: currentMarker)
        let tempMarker = self.setMarkerWith(place: lakePlace)
        self.currentMarker = tempMarker
        self.currentMarker?.position = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
        
        self.currentMarkerLocation = tempMarker.place.coordinate
        
        self.contents?.latitude = marker.position.latitude
        self.contents?.longitude = marker.position.longitude
        
        perform(#selector(setTownshipZone), with: nil, afterDelay: 1.0)
        
        self.googleMapView.clear()
        self.currentMarker?.map = self.googleMapView
    }
    
    @objc private func setTownshipZone() {
        self.contents?.townshipName = self.handleGetTownship()
        self.contents?.zoneName = self.handleGetZone()
        
        KRProgressHUD.dismiss()
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
        let typeId = currentMarker.place.typeId
//        let township = String(getIdWithName(name: currentMarker.place.townshipName, tableName: "townships"))
        
        let oldPin = self.handleGetOldData(type: type, typeId: typeId)
        
        let township = self.handleGetTownship()
        let zone = self.handleGetZone()
        
        var townshipId = "0"
        var zoneId = "0"
        
        if township != "Unknown Township" {
            townshipId = township
        }
        
        if zone != "Unknown Zone" {
            zoneId = zone
        }
        
        guard let oldLat = oldPin.lat, let oldLon = oldPin.lon, let oldTownship = oldPin.township, let oldZone = oldPin.zone else { return }
        
        let requestStr = String(format: WebService.editPinSubmit.rawValue, lakeId, userId, lakeName, lon, lat, type, townshipId, typeId, zoneId, oldLat, oldLon, oldTownship, oldZone)
        
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

//MARK: handle shown zone borders
extension EditPinController {
    
    @objc fileprivate func handleShowZoneBorderSwitch(sender: UISwitch) {
        let isShown = sender.isOn
        
        UserDefaults.standard.setIsShownZoneBordersForEditPin(value: isShown)
        
        handleShowZoneBorders()
    }
    
    
    
    private func handleShowZoneBorders() {
        
        if isShownZoneBorders() {
            for i in 0..<gmsPaths.count {
                let polyline = GMSPolyline(path: gmsPaths[i])
                
                polyline.strokeColor = .red
                polyline.strokeWidth = 1
                polyline.map = self.googleMapView
                
                self.polylines.append(polyline)
            }
            
            self.showAlert(warnigString: "Zone Boundary Borders On")
            
            //            let zoneMarker = self.marker(forZone: "1", position: CLLocationCoordinate2D(latitude: 44, longitude: -78))
            //            zoneMarker.map = self.googleMapView
            //            self.zoneMarkers.append(zoneMarker)
        } else {
            for polyline in polylines {
                polyline.map = nil
                
            }
            
            for zoneMarker in zoneMarkers {
                zoneMarker.map = nil
            }
            
            self.showAlert(warnigString: "Zone Boundary Borders Off")
        }
        
        
        
    }
    
    fileprivate func isShownZoneBorders() -> Bool {
        
        return UserDefaults.standard.isShownZoneBordersForEditPin()
    }
    
}

//MARK: handle detect zone and township
extension EditPinController {
    
    fileprivate func handleGetZone() -> String {
        zones.removeAll()
        determineZoneKmlWith(currentLocation: currentMarkerLocation)
        let currentZone = handleDetectWhichZone()
        
        return currentZone
    }
    
    fileprivate func handleGetTownship() -> String {
        townships.removeAll()
        determineTwonshipKmlWith(currentLocation: currentMarkerLocation)
        
        let currentTownship = handleDetectWhickTownship()
        return currentTownship
    }
    
    fileprivate func determineTwonshipKmlWith(currentLocation: CLLocationCoordinate2D) {
        
        for i in 0 ..< townshipKml.count {
            let coordinate = townshipKml[i]
            
            let path = self.pathFromCoordinateArray(coordinates: coordinate)
            
            if GMSGeometryContainsLocation(currentLocation, path, true) {
                self.parseStatus = .Township
                self.handleKmlWith(index: i + 1)
                
            }
        }
    }
    
    fileprivate func determineZoneKmlWith(currentLocation: CLLocationCoordinate2D) {
        
        for i in 0 ..< zonesKml.count {
            let coordinate = zonesKml[i]
            
            let path = self.pathFromCoordinateArray(coordinates: coordinate)
            
            if GMSGeometryContainsLocation(currentLocation, path, true) {
                self.parseStatus = .Zone
                self.handleKmlWith(index: i + 1)
            }
        }
    }
    
    fileprivate func handleKmlWith(index: Int) {
        
        if parseStatus == .Zone {
            if let path = Bundle.main.url(forResource: "z\(index)", withExtension: "kml")   {
                if let parser = XMLParser(contentsOf: path) {
                    parser.delegate = self
                    parser.parse()
                }
            }
        } else {
            if let path = Bundle.main.url(forResource: "t (\(index))", withExtension: "kml")   {
                if let parser = XMLParser(contentsOf: path) {
                    parser.delegate = self
                    parser.parse()
                }
            }
        }
    }
    
    func handleDetectWhickTownship() -> String {
        
        var currentTownship = "Unknown Township"
        
        if townships.count == 0 {
            return currentTownship
        }
        
        for i in 0 ..< townships.count {
            let coordinate = townships[i].townshipCoordinates
            
            let path = self.pathFromCoordinateArray(coordinates: coordinate)
            
            if GMSGeometryContainsLocation(currentMarkerLocation, path, true) {
                
                currentTownship  = townships[i].townshipName
            }
        }
        
        return currentTownship
    }
    
    func handleDetectWhichZone() -> String {
        
        var currentZone = "Unknown Zone"
        
        if zones.count == 0 {
            return currentZone
        }
        
        for zone in zones {
            if GMSGeometryContainsLocation(currentMarkerLocation, zone.gmsPath, true) {
                currentZone = zone.zoneName
            }
        }
        
        return currentZone
    }
    
    func locationFromCoordinate(coordinates: CLLocationCoordinate2D) -> CLLocation {
        return CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    
    func pathFromCoordinateArray(coordinates: [CLLocationCoordinate2D]) -> GMSPath {
        let path = GMSMutablePath()
        for coordinate in coordinates {
            path.add(self.locationFromCoordinate(coordinates: coordinate).coordinate)
        }
        return path
    }
}

//MARK: handle xml parser
extension EditPinController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        eName = elementName
        
        if elementName == "Placemark" {
            if parseStatus == .Zone {
                zoneName = String()
                coordinate = String()
            } else {
                townshipName = String()
                townshipCoordinate = String()
            }
            
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "coordinates"{
            
            if parseStatus == .Zone {
                let temp_coordinate = coordinate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                coordinate = ""
                
                let coordinateTownship = temp_coordinate
                var coordinateArray = [CLLocationCoordinate2D]()
                let array = coordinateTownship.components(separatedBy: " ")
                
                for i in 0 ..< array.count {
                    
                    let coordinateStr = array[i]
                    let array1 = coordinateStr.components(separatedBy: ",")
                    
                    let lon = array1[0]
                    let lat = array1[1]
                    
                    let coordinat = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                    coordinateArray.append(coordinat)
                }
                let path = self.pathFromCoordinateArray(coordinates: coordinateArray)
                let zone = Zone(zoneName: zoneName, gmsPath: path)
                zones.append(zone)
                
            } else {
                let array = townshipCoordinate.components(separatedBy: ",0")
                var coordinateArray = [CLLocationCoordinate2D]()
                for i in 0 ..< array.count - 1  {
                    
                    let coordinateStr = array[i]
                    let array1 = coordinateStr.components(separatedBy: ",")
                    
                    let lon = array1[0]
                    let lat = array1[1]
                    
                    let coordinat = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                    coordinateArray.append(coordinat)
                }
                let township = Township()
                township.townshipName = townshipName
                township.townshipCoordinates = coordinateArray
                townships.append(township)
                
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        //        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!string.isEmpty) {
            if eName == "name" {
                
                if parseStatus == .Zone {
                    zoneName += string
                } else {
                    townshipName += string
                }
                
                
            } else if eName == "coordinates" {
                if parseStatus == .Zone {
                    coordinate += string
                } else {
                    townshipCoordinate += string
                }
                
            }
        }
        
    }
}

//MARK: handle views, vars
extension EditPinController {
    
    fileprivate func setupViews() {
        setupNavbar()
        setGoogleMap()
        setupSegments()
        setupSwitch()
        setInvalidCommandLabel()
    }
    
    private func setupJoyStick() {
        
        let rect = view.frame
        var size = CGSize(width: 100.0, height: 100.0)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            size = CGSize(width: 180.0, height: 180.0)
        }
        let joystick1Frame = CGRect(origin: CGPoint(x: 20.0,
                                                    y: (rect.height - size.height - 25.0)),
                                    size: size)
        let joystick = JoyStickView(frame: joystick1Frame)

        joystick.delegate = self

        view.addSubview(joystick)

        joystick.movable = false
        joystick.alpha = 1.0
        joystick.baseAlpha = 0.5 // let the background bleed thru the base
        joystick.handleTintColor = StyleGuideManager.fishLegitDefultBlueColor // Colorize the handle
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
    
    private func setupSwitch() {
        
        view.addSubview(showBorderSwitch)
        
        showBorderSwitch.widthAnchor.constraint(equalToConstant: 50).isActive = true
        showBorderSwitch.heightAnchor.constraint(equalTo: mapTypeSegement.heightAnchor).isActive = true
        showBorderSwitch.centerYAnchor.constraint(equalTo: mapTypeSegement.centerYAnchor).isActive = true
        showBorderSwitch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        
        if isShownZoneBorders() {
            showBorderSwitch.isOn = true
        } else {
            showBorderSwitch.isOn = false
        }
        handleShowZoneBorders()
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
