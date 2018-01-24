//
//  CreatePinController.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

/*
{
    id: "5",
    user_id: "24",
    lake_id: "0",
    name: "lake",
    lon: "12.32",
    lat: "332.32",
    created: "2018-01-08 05:22:17",
    active: "-1",
    type: "opportunity",
    edit_new: "New",
    zone: "15",
    township: "town",
    detail: "detail",
    id2: "5",
    user_id2: "24",
    lake_id2: "0",
    name2: "lake",
    lon2: "0",
    lat2: "0",
    created2: "2018-01-08 05:22:17",
    active2: "-1",
    type2: "opportunity",
    zone2: "14",
    township2: "t",
    detail2: "detail"
}
*/

import UIKit
import GoogleMaps
import GooglePlaces
import KRProgressHUD
import PopOverMenu
import AZDropdownMenu
import JHTAlertController

protocol CreatePinDelegate {
    func resetContentsAndLakeMarker(contents: Contents)
}

class CreatePinController: UIViewController {
    
    var polylines = [GMSPolyline]()
    var zoneMarkers = [GMSMarker]()
    var gmsPaths = [GMSPath]()
    
    let reachAbility = Reachability()!
    var contents: Contents?
    var lakeMarker: LakeMarker?
    
    var currentLocation = CLLocationCoordinate2D(latitude: 40.0, longitude: -70.0)
    var currentMarkerLocation = CLLocationCoordinate2D(latitude: 40.0, longitude: -70.0)
    
    var titleLabel: UILabel!
    var alertController: JHTAlertController?
    
    var parseStatus = ParseStatus.Zone
    
    var eName: String = String()
    var zoneName = String()
    var coordinate = String()
    var zones = [Zone]()
    
    var townshipName = String()
    var townshipCoordinate = String()
    var townships = [Township]()
    
    lazy var showBorderSwitch: UISwitch = {
        let borderSwitch = UISwitch()
        borderSwitch.onTintColor = StyleGuideManager.fishLegitDefultBlueColor
        borderSwitch.backgroundColor = .gray
        borderSwitch.layer.cornerRadius = 16
        borderSwitch.translatesAutoresizingMaskIntoConstraints = false
        borderSwitch.addTarget(self, action: #selector(handleShowZoneBorderSwitch(sender:)), for: .valueChanged)
        return borderSwitch
    }()
    
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
        
        self.handleCreateMarker()
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

//MARK: handle zone borders feedback
extension CreatePinController {
    
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

//MARK: handle segement
extension CreatePinController {
    @objc fileprivate func handelMapType() {
        
        if mapTypeSegement.selectedSegmentIndex == 0 {
            googleMapView.mapType = .normal
        } else {
            googleMapView.mapType = .satellite
            
        }
    }
}

//MARK: handle keyboard
extension CreatePinController: UITextFieldDelegate {
    
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
extension CreatePinController {
    
    fileprivate func handleShowResetLocationAlert() {

        guard let currentMarker = self.lakeMarker else {
            self.showJHTAlertDefaultWithIcon(message: "No Marker/Pin created.\nDo you want to create Marker/Pin?", firstActionTitle: "No", secondActionTitle: "Yes", action: { (action) in

                self.handleCreateMarker()
            })
            return
        }

        let title = currentMarker.place.lakeName
        self.handleShowTextFieldAlert(title: title, marker: currentMarker)
    }
    
    fileprivate func handleShowTextFieldAlert(title: String, marker: LakeMarker) {
        
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
                
                self.resetFakeLakeWith(latStr: latStr, lonStr: lonStr, marker: marker)
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
            
            let lonStr = String(marker.place.coordinate.latitude)
            textField.text = lonStr
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
            
            let latStr = String(marker.place.coordinate.longitude)
            textField.text = latStr
        }
        
        alertController?.addAction(cancelAction)
        alertController?.addAction(okAction)
        
        present(alertController!, animated: true, completion: nil)
        
    }
    
    private func resetFakeLakeWith(latStr: String, lonStr: String, marker: LakeMarker) {

        guard let lat = Double(latStr) else { return }
        guard let lon = Double(lonStr) else { return }

        let lakePlace = self.resetLakePlaceWith(lat: lat, lon: lon, marker: marker)
        let lakeMarker = self.setMarkerWith(place: lakePlace)
        
        self.contents?.latitude = lat
        self.contents?.longitude = lon

        self.resetLakeMarkerWith(marker: lakeMarker)
        self.focusLakeMarker()
    }
    
    fileprivate func resetLakePlaceWith(lat: Double, lon: Double, marker: LakeMarker) -> LakePlace {
        
        let place = marker.place
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
        
        let lakePlace = LakePlace(lakeName: place.lakeName , townshipName: place.townshipName , opportunity: place.opportunity , exception: place.exception, coordinate: coordinate , distance: 10.0 , type: place.type, typeId: "0", species: place.species)
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
            textField.text = String(textField.text![index...])
        } else {
            textField.text = String(format: "-%@", textField.text!)
        }

    }
    
}


//MARK: handle create content, update content
extension CreatePinController {
    
    fileprivate func handleCreateMarker() {
        
        //get centerCoordinate from center point
        /*
        let centerPoint = self.googleMapView.center
        let centerCoordinate = googleMapView.projection.coordinate(for: centerPoint)
        */
 
        currentMarkerLocation = self.currentLocation
        
        let contents = Contents()
        contents.lakeName = "Unknown Lake"
        contents.latitude = currentMarkerLocation.latitude
        contents.longitude = currentMarkerLocation.longitude
        contents.townshipName = self.handleGetTownship()
        contents.zoneName = self.handleGetZone()
        self.contents = contents
        
        let lakePlace = self.setLakePlaceWith(contents: contents)
        let lakeMarker = self.setMarkerWith(place: lakePlace)
        
        self.resetLakeMarkerWith(marker: lakeMarker)
        self.focusLakeMarker()
    }
    
    fileprivate func handleUpdatingContents() {
        
        guard let contents = self.contents else {
            self.showJHTAlertDefaultWithIcon(message: "No Marker/Pin created.\nDo you want to create Marker/Pin?", firstActionTitle: "No", secondActionTitle: "Yes", action: { (action) in
                
                self.handleCreateMarker()
            })
            return
        }
        let layout = UICollectionViewFlowLayout()
        let createContentController = CreateContentController(collectionViewLayout: layout)
        createContentController.contents = contents
        createContentController.createPinDelegate = self
        let navController = UINavigationController(rootViewController: createContentController)
        
        present(navController, animated: true, completion: nil)
    }
    
}

//MARK: handle setting marker
extension CreatePinController {
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
    
    fileprivate func focusLakeMarker() {
        if let marker = self.lakeMarker {
            self.googleMapView.animate(toLocation: marker.place.coordinate)
            self.currentMarkerLocation = marker.place.coordinate
        } else {
            self.googleMapView.animate(toLocation: currentLocation)
        }
        let zoom = self.calculateZoomLevel(radius: 100)
        googleMapView.animate(toZoom: Float(zoom))
    }
    
    fileprivate func resetLakeMarkerWith(marker: LakeMarker) {
        self.googleMapView.clear()
        marker.map = self.googleMapView
        handleShowZoneBorders()
        self.lakeMarker = marker
    }
    
    fileprivate func calculateZoomLevel(radius: Double) -> Int {
        
        let scale: Double = radius * 50
        let zoomLevel = Int(19 - log(scale) / log(2))
        return zoomLevel < 0 ? 0 : zoomLevel > 20 ? 20 : zoomLevel
    }
}


//MARK: reset contents, marker when dismiss createcontent controller
extension CreatePinController: CreatePinDelegate {
    
    func resetContentsAndLakeMarker(contents: Contents) {
        
        self.contents = contents
        let lakePlace = self.setLakePlaceWith(contents: contents)
        let lakeMarker = self.setMarkerWith(place: lakePlace)
        
        self.resetLakeMarkerWith(marker: lakeMarker)
        self.focusLakeMarker()
    }
    
}

//MARK: handle detect zone and township
extension CreatePinController {
    
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
extension CreatePinController: XMLParserDelegate {
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

//MARK: handle popover menu
extension CreatePinController: UIAdaptivePresentationControllerDelegate {
    
    @objc fileprivate func handlePopoverMenu(sender: UIBarButtonItem) {
        
        let menus = ["Marker/Pin Data"]
        let popoverMenuController = PopOverViewController.instantiate()
        popoverMenuController.setTitles(menus)
        popoverMenuController.setSeparatorStyle(.singleLine)
        popoverMenuController.popoverPresentationController?.barButtonItem = sender
        popoverMenuController.preferredContentSize = CGSize(width: 170, height: 45)
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


//MARK: handle google mapdelegate
extension CreatePinController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        
        guard let currentMarker = self.lakeMarker else { return }
        
        self.resetCurrentMarkerWith(currentMarker: currentMarker, marker: marker)
    }
    
    private func resetCurrentMarkerWith(currentMarker: LakeMarker, marker: GMSMarker) {
        
        KRProgressHUD.show()
        
        let lakePlace = self.resetLakePlaceWith(lat: marker.position.latitude, lon: marker.position.longitude, marker: currentMarker)
        let tempMarker = self.setMarkerWith(place: lakePlace)
        self.lakeMarker = tempMarker
        
        self.currentMarkerLocation = tempMarker.place.coordinate
        
        self.contents?.latitude = marker.position.latitude
        self.contents?.longitude = marker.position.longitude
        
        perform(#selector(setTownshipZone), with: nil, afterDelay: 1.0)
    }
    
    @objc private func setTownshipZone() {
        self.contents?.townshipName = self.handleGetTownship()
        self.contents?.zoneName = self.handleGetZone()
        
        KRProgressHUD.dismiss()
    }
}


//MARK: handle dismiss, submit
extension CreatePinController {
    
    @objc fileprivate func handleDismissController() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    fileprivate func handleSubmit() {
        
        guard let userId = UserDefaults.standard.getUserId() else { return }
        guard let contents = self.contents else {
            self.showJHTAlerttOkayWithIcon(message: "No Marker/Pin to submit.")
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
        
        
        let requestStr = String(format: WebService.createPinSubmit.rawValue, userId, lakeName, lon, lat, type, zoneId, townshipId, detail)
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
extension CreatePinController {
    
    @objc fileprivate func handleShowZoneBorderSwitch(sender: UISwitch) {
        let isShown = sender.isOn
        
        UserDefaults.standard.setIsShownZoneBordersForNewPin(value: isShown)
        
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
            
            //            let zoneMarker = self.marker(forZone: "1", position: CLLocationCoordinate2D(latitude: 44, longitude: -78))
            //            zoneMarker.map = self.googleMapView
            //            self.zoneMarkers.append(zoneMarker)
            
            self.showAlert(warnigString: "Zone Boundary Borders On")
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
        
        return UserDefaults.standard.isShownZoneBordersForNewPin()
    }
    
}

//MARK: handle views, vars
extension CreatePinController {
    
    fileprivate func setupViews() {
        setupNavbar()
        setGoogleMap()
        setupSegments()
        setupSwitch()
        handleShowZoneBorders()
        setInvalidCommandLabel()
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
        titleLabel.text = "Create Pin"
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
