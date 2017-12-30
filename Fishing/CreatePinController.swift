//
//  CreatePinController.swift
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

protocol CreatePinDelegate {
    func resetContentsAndLakeMarker(contents: Contents)
}

class CreatePinController: UIViewController {
    let reachAbility = Reachability()!
    var contents: Contents?
    var lakeMarker: LakeMarker?
    
    var currentLocation = CLLocationCoordinate2D(latitude: 40.0, longitude: -70.0)
    
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
            self.showJHTAlertDefaultWithIcon(message: "No created contents.\nDo you want to create contents?", firstActionTitle: "No", secondActionTitle: "Yes", action: { (action) in

                self.handleGoingCreateContentController()
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
            textField.text = String(textField.text![index...])
        } else {
            textField.text = String(format: "-%@", textField.text!)
        }

    }
    
}


//MARK: handle create content, update content
extension CreatePinController {
    
    fileprivate func handleCreateMarker() {
        
        let centerPoint = self.googleMapView.center
        let centerCoordinate = googleMapView.projection.coordinate(for: centerPoint)
        
        
        let contents = Contents()
        contents.lakeName = "unknown"
        contents.latitude = centerCoordinate.latitude
        contents.longitude = centerCoordinate.longitude
        self.contents = contents
        
        let lakePlace = self.setLakePlaceWith(contents: contents)
        let lakeMarker = self.setMarkerWith(place: lakePlace)
        
        self.resetLakeMarkerWith(marker: lakeMarker)
        self.focusLakeMarker()
    }
    
    fileprivate func handleGoingCreateContentController() {
        
        let layout = UICollectionViewFlowLayout()
        let createContentController = CreateContentController(collectionViewLayout: layout)
        createContentController.createPinDelegate = self
        let navController = UINavigationController(rootViewController: createContentController)
        
        present(navController, animated: true, completion: nil)
        
    }
    
    fileprivate func handleUpdatingContents() {
        
        guard let contents = self.contents else {
            self.showJHTAlertDefaultWithIcon(message: "No created contents.\nDo you want to create contents?", firstActionTitle: "No", secondActionTitle: "Yes", action: { (action) in
                
                self.handleGoingCreateContentController()
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
        
        
        let lakePlace = LakePlace(lakeName: lakeName, townshipName: townshipName, opportunity: opportunity, exception: exception, coordinate: coordinate, distance: 10, type: type)
        
        return lakePlace
    }
    
    fileprivate func focusLakeMarker() {
        if let marker = self.lakeMarker {
            self.googleMapView.animate(toLocation: marker.place.coordinate)
            
        } else {
            self.googleMapView.animate(toLocation: currentLocation)
        }
        let zoom = self.calculateZoomLevel(radius: 100)
        googleMapView.animate(toZoom: Float(zoom))
    }
    
    fileprivate func resetLakeMarkerWith(marker: LakeMarker) {
        self.googleMapView.clear()
        marker.map = self.googleMapView
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
    @objc func handleZoneAndTownship() {
        
        zones.removeAll()
        determineZoneKmlWith(currentLocation: currentLocation)
        
        townships.removeAll()
        determineTwonshipKmlWith(currentLocation: currentLocation)
        handleDetectWhickTownship()
    }
    
    fileprivate func determineTwonshipKmlWith(currentLocation: CLLocationCoordinate2D) {
        
        for i in 0 ..< townshipKml.count {
            let coordinate = townshipKml[i]
            
            let path = self.pathFromCoordinateArray(coordinates: coordinate)
            
            if GMSGeometryContainsLocation(currentLocation, path, true) {
                self.parseStatus = .Township
                self.handleKmlWith(index: i + 1)
                
            } else {
                let text = "You are in unknown Township"
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
                
            } else {
                let currentZone = "0"
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
    
    func handleDetectWhickTownship() {
        
        print("count", townships.count)
        
        for i in 0 ..< townships.count {
            let coordinate = townships[i].townshipCoordinates
            
            let path = self.pathFromCoordinateArray(coordinates: coordinate)
            
            if GMSGeometryContainsLocation(currentLocation, path, true) {
                
                let text = "You are in " + townships[i].townshipName
                
                let currentTownship = getIdStringWithName(name: townships[i].townshipName, tableName: "townships")
                
                return
                
            } else {
                
                let text = "You are in unknown Township"
            }
        }
        
    }
    
    func handleDetectWhichZone(withZone zone: Zone) {
        
        if GMSGeometryContainsLocation(currentLocation, zone.gmsPath, true) {
            
            let text = "You are in " + zone.zoneName
            
            let character = CharacterSet(charactersIn: "ZONE")
            let currentZone = zone.zoneName.trimmingCharacters(in: character)
            return
            
        } else {
            
            let text = "You are in unknown ZONE"
            let currentZone = "0"
        }
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
        
        let menus = ["Create Marker/Pin", "Edit Marker/Pin", "Reset Location", "Submit"]
        let popoverMenuController = PopOverViewController.instantiate()
        popoverMenuController.setTitles(menus)
        popoverMenuController.setSeparatorStyle(.singleLine)
        popoverMenuController.popoverPresentationController?.barButtonItem = sender
        popoverMenuController.preferredContentSize = CGSize(width: 170, height: 180)
        popoverMenuController.presentationController?.delegate = self
        popoverMenuController.completionHandler = { selectRow in
            
            switch (selectRow) {
            case 0:
                self.handleCreateMarker()
                break
            case 1:
                self.handleUpdatingContents()
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
        let lakePlace = self.resetLakePlaceWith(lat: marker.position.latitude, lon: marker.position.longitude, marker: currentMarker)
        let tempMarker = self.setMarkerWith(place: lakePlace)
        self.lakeMarker = tempMarker
        
        self.contents?.latitude = marker.position.latitude
        self.contents?.longitude = marker.position.longitude
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
            self.showJHTAlerttOkayWithIcon(message: "No contents to submit.")
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
        
        let requestStr = String(format: WebService.createPinSubmit.rawValue, userId, lakeName, lon, lat, type, zone, township, detail)
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
extension CreatePinController {
    
    fileprivate func setupViews() {
        setupNavbar()
        setGoogleMap()
        setupSegments()
        
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
