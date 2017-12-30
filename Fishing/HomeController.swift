//
//  HomeController.swift
//  Fishing
//
//  Created by PAC on 02/06/2017.
//  Copyright © 2017 PAC. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import KRProgressHUD
import AFMActionSheet

class HomeController: UIViewController, HADropDownDelegate {
    
    var currentLocation: CLLocation?
    
    var parseStatusForZone: ParseStatusForZone = .zone
    
    let defaultLocation =  CLLocation(latitude: 41.8902,longitude:  12.4922)
    
    let dataProvider = GoogleDataProvider()
    
    var gmsPaths = [GMSPath]()
    var species = [String]()
    var eName: String = String()
    var zoneName = String()
    var coordinate = String()
    var zones = [Zone]()
    
    var currentZone = ""

    var sepecyIndex = 0
    
    var isSelectedSpecy = false
    
    var disclaimerView = DisclaimerView.initView()
    
    lazy var showDisclaimerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Disclaimer", for: .normal)
        button.setTitleColor(.white, for: .normal)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 27)
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        }
        
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.showAgreeAlertMessage), for: .touchUpInside)
        return button
    }()
    
    lazy var speciesSelectField: HADropDown = {
        let field = HADropDown()
        field.title = "Select species"
        field.titleColor = .white
        
        field.layer.borderColor = UIColor.clear.cgColor
        field.items = ["cat", "mouse"]
        field.isUserInteractionEnabled = true
        field.delegate = self
        if UI_USER_INTERFACE_IDIOM() == .pad {
            field.font = UIFont.systemFont(ofSize: 32)
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            field.font = UIFont.systemFont(ofSize: 25)
        }
        
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
        
    }()

    let zoneLabel: UILabel = {
        
        let label = UILabel()
        label.text = "You are in unknown zone"
        label.textColor = .white
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            label.font = UIFont.systemFont(ofSize: 50)
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            label.font = UIFont.systemFont(ofSize: 26)
        }
        
        
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    let zoneInfoTextView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        if UI_USER_INTERFACE_IDIOM() == .pad {
            textView.font = UIFont.systemFont(ofSize: 25)
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            textView.font = UIFont.systemFont(ofSize: 16)
        }
        
        return textView
    }()
    
    let numbersTextView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.textColor = .white
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        if UI_USER_INTERFACE_IDIOM() == .pad {
            textView.font = UIFont.systemFont(ofSize: 30)
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            textView.font = UIFont.systemFont(ofSize: 20)
        }
        return textView
    }()
    
    lazy var lakeSearchButton: UIButton = {
        
        let button = UIButton(type: .system)
        let image = UIImage(named: "finger")
        button.setImage(image, for: .normal)
        button.setTitle("Go to map", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        if UI_USER_INTERFACE_IDIOM() == .pad {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 55)
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        }
        
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(goingToLakeSearchController), for: .touchUpInside)
        return button
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.more.rawValue)?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
        return button
    }()
    
    let thumbnailImageView: UIImageView = {
        let thumbnailImageView = UIImageView()
        thumbnailImageView.image = UIImage(named: "thumbnail")
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        return thumbnailImageView
    }()
    
    @objc func goingToLakeSearchController() {
        let lakeSearchController = LakeSearchController()
        
        if isSelectedSpecy == true {
            lakeSearchController.selectedSpecy = species[sepecyIndex]
            lakeSearchController.selectedControllerStatus = .Species
        } else {
            lakeSearchController.selectedControllerStatus = .Distance
        }
        
        lakeSearchController.currentLocation = (self.currentLocation?.coordinate)!
        lakeSearchController.myLocation = (self.currentLocation?.coordinate)!
        lakeSearchController.currentZone = self.currentZone
        lakeSearchController.gmsPaths = self.gmsPaths
        
        navigationController?.pushViewController(lakeSearchController, animated: true)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundAndDisclaimerButton()
        
        userAgreeWithAgreement()
        setupViews()
        handleZonesKml()
        handleTownshipKmls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationItems()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//MARK: handle more, logout

extension HomeController {
    
    @objc fileprivate func handleMore() {
        
        let actionSheet = AFMActionSheetController(style: .actionSheet, transitioningDelegate: AFMActionSheetTransitioningDelegate())
        
        let disclaimerAction = AFMAction(title: "Show Disclaimer", enabled: true) { (action) in
            self.handleShowDisclaimerController()
        }
        let logoutAction = AFMAction(title: "Log out", enabled: true) { (action) in
            self.handleLogout()
        }
        let cancelAction = AFMAction(title: "Cancel", handler: nil)
        
        
        
        actionSheet.add(disclaimerAction)
        actionSheet.add(logoutAction)
        actionSheet.add(cancelling: cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @objc fileprivate func handleLogout() {
        
        self.showJHTAlertDefaultWithIcon(message: "Are you sure you want to Log out?", firstActionTitle: "No", secondActionTitle: "Yes") { (action) in
            
            UserDefaults.standard.setIsLoggedIn(value: false)
            
            let loginController = LoginController()
            self.present(loginController, animated: true, completion: nil)
        }
    }
    
}

//MARK: handle disclamer
extension HomeController: DisclaimerViewDelegate {
    fileprivate func userAgreeWithAgreement() {
        
        if isAgreed() {
            self.getCurrentLocation()
        } else {
            showAgreeAlertMessage()
        }
    }
    
    fileprivate func isAgreed() -> Bool {
        return UserDefaults.standard.isAgreed()
    }
    @objc fileprivate func showAgreeAlertMessage() {
        
        disclaimerView = DisclaimerView.initWith(title: "FishLegit", content: AgreeMessages, delegate: self)
        self.view.addSubview(disclaimerView)
        
    }
    
    @objc fileprivate func handleShowDisclaimerController() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let dislaimerController = DisclaimerViewController()
            
            self.navigationController?.pushViewController(dislaimerController, animated: true)
        }
    }
    
    
    
    func acceptDisclaimer(index: Int) {
        
        print("acceptDisclaimer index: \(index)")
        
        UserDefaults.standard.setAgreed(true)
        
        disclaimerView.removeFromSuperview()
        showDisclaimerButton.isHidden = true
        self.getCurrentLocation()
    }
    
    func cancelDisclaimer(index: Int) {
        
        print("cancelDisclaimer index: \(index)")
        
        UserDefaults.standard.setAgreed(false)
        
        disclaimerView.removeFromSuperview()
        showDisclaimerButton.isHidden = false
    }
    
    private func getCurrentLocation() {
        
        KRProgressHUD.set(style: .black)
        KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
        KRProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            
            if let usersLocation = LocationManager.sharedInstance.userLocation {
                
                self.currentLocation = usersLocation
                print("myLocation", self.currentLocation!)
            } else {
                self.currentLocation = self.defaultLocation
                print("defaultLocation", self.currentLocation!)
            }
            
            self.lakeSearchButton.isHidden = false
            self.speciesSelectField.isHidden = false
            self.thumbnailImageView.isHidden = false
            
            self.zones.removeAll()
            
            self.determineZoneKmlWith(currentLocation: (self.currentLocation?.coordinate)!)
            self.handleDetectWhichZone()
            self.handleZoneForBordersKml()
            KRProgressHUD.dismiss()
        })
    }
}

//MARK: handel setupviews
extension HomeController {
    func setupViews() {
        
        
        setupZoneLabel()
        setupSpeciesSelectField()
        setupLakeSearchButton()
        setupZoneInfoTextView()
        setupNumbersTextView()
        setupThumbnail()
        setupMoreButton()
    }
    
    private func setupMoreButton() {
        view.addSubview(moreButton)
        
        moreButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: zoneLabel.centerYAnchor).isActive = true
        moreButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
    }
    
    private func setupThumbnail() {
        
        
        
        view.addSubview(thumbnailImageView)
        thumbnailImageView.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.5).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.5).isActive = true
        thumbnailImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        thumbnailImageView.bottomAnchor.constraint(equalTo: lakeSearchButton.topAnchor, constant: -DEVICE_WIDTH * 0.013).isActive = true
        
        thumbnailImageView.isHidden = true
        
    }
    
    func setupNavigationItems() {
        
        
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func setupBackgroundAndDisclaimerButton() {
        setupBackground()
        setupDisclaimerButton()
    }
    
    private func setupDisclaimerButton() {
        
        view.addSubview(showDisclaimerButton)
        
        showDisclaimerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        showDisclaimerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -DEVICE_WIDTH / 2 + 15).isActive = true
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            showDisclaimerButton.widthAnchor.constraint(equalToConstant: 220).isActive = true
            showDisclaimerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            showDisclaimerButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
            showDisclaimerButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        
        showDisclaimerButton.isHidden = true
    }
    
    private func setupBackground() {
        
        view.backgroundColor = .blue
        
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImageView)
        
        backgroundImageView.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH).isActive = true
        backgroundImageView.heightAnchor.constraint(equalToConstant: DEVICE_HEIGHT).isActive = true
        backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    private func setupSpeciesSelectField() {
        view.addSubview(speciesSelectField)
        speciesSelectField.layer.borderColor = UIColor.clear.cgColor
        
        speciesSelectField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        speciesSelectField.topAnchor.constraint(equalTo: zoneLabel.bottomAnchor, constant: 0).isActive = true
        if UI_USER_INTERFACE_IDIOM() == .pad {
            speciesSelectField.widthAnchor.constraint(equalToConstant: 350).isActive = true
            speciesSelectField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            speciesSelectField.widthAnchor.constraint(equalToConstant: 250).isActive = true
            speciesSelectField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        species = fetchSpeciesName() as! [String]
        speciesSelectField.items = species
        
        speciesSelectField.isHidden = true
    }
    
    private func setupLakeSearchButton() {
        view.addSubview(lakeSearchButton);
        
        lakeSearchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        if UI_USER_INTERFACE_IDIOM() == .pad {
            lakeSearchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
            lakeSearchButton.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.57).isActive = true
            lakeSearchButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            lakeSearchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
            lakeSearchButton.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.57).isActive = true
            lakeSearchButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        lakeSearchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        lakeSearchButton.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.57).isActive = true
        lakeSearchButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        lakeSearchButton.isHidden = true
    }
    
    private func setupZoneLabel() {
        view.addSubview(zoneLabel)
        
        zoneLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        zoneLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            zoneLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
            zoneLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            zoneLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            zoneLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        }
        
    }
    
    private func setupZoneInfoTextView() {
        
        view.addSubview(zoneInfoTextView)
        
        zoneInfoTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        zoneInfoTextView.topAnchor.constraint(equalTo: speciesSelectField.bottomAnchor, constant: 0).isActive = true
        if UI_USER_INTERFACE_IDIOM() == .pad {
            zoneInfoTextView.widthAnchor.constraint(equalToConstant: 350).isActive = true
            zoneInfoTextView.heightAnchor.constraint(equalToConstant: 250).isActive = true
            
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            zoneInfoTextView.widthAnchor.constraint(equalToConstant: 250).isActive = true
            zoneInfoTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        }
        zoneInfoTextView.isHidden = true
//        zoneInfoTextView.backgroundColor = .red
    }
    
    private func setupNumbersTextView() {
        
        view.addSubview(numbersTextView)
        
        numbersTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        numbersTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        if UI_USER_INTERFACE_IDIOM() == .pad {
            numbersTextView.widthAnchor.constraint(equalToConstant: 350).isActive = true
            numbersTextView.heightAnchor.constraint(equalToConstant: 160).isActive = true
            
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            numbersTextView.widthAnchor.constraint(equalToConstant: 250).isActive = true
            numbersTextView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        }
        numbersTextView.isHidden = true
        
    }

}


//MARK: handle hadrpdown
extension HomeController {
    func getExceptions(withzone zone: String) -> Int {
        var num = 0;
        let query = String(format: "Select count(*) as count from exceptions where zone=%@", zone)
        let array = SCSQLite.selectRowSQL(query)! as NSArray
        if array.count > 0 {
            let dictionary = array[0] as! NSDictionary
            num = dictionary.value(forKey: "count") as! Int
        }

        return num
    }
    
    
    
    func getOpportunities(withzone zone: String) -> Int {
        
        var num = 0;
        
        var query = String()
        
        if isSelectedSpecy == true {
            query = String(format: "Select count(*) as count from features a INNER JOIN species b ON a.species = b.id where a.zones=%d And b.name=\'%@\'", Int(zone)!, species[sepecyIndex])
        } else {
            query = String(format: "Select count(*) as count from features where zones=%@", zone)
        }
        
        
        let array = SCSQLite.selectRowSQL(query)! as NSArray
        
        if array.count > 0 {
            let dictionary = array[0] as! NSDictionary
            num = dictionary.value(forKey: "count") as! Int
        }
        
        return num
        
    }
    
    func fetchSpeciesName() -> NSArray {
        var zonesArray = [String]()
        SCSQLite.initWithDatabase("fishy.sqlite3")
        let query = "SELECT id, name FROM species"
        let array = SCSQLite.selectRowSQL(query)! as NSArray
        
        for i in 0  ..< (array.count)  {
            let dictionary = array[i] as! NSDictionary
            let name = dictionary.value(forKey: "name") as! String
            zonesArray.append(name)
        }
        
        return zonesArray.sorted(by: {$0 < $1}) as NSArray
        
    }
    
    func didSelectItem(dropDown: HADropDown, at index: Int) {
        
        
        if dropDown == speciesSelectField {
            
            let selectedSpecies = String(getIdWithName(name: species[index], tableName: "species"))
            if self.currentZone != "" {
                
                zoneInfoTextView.isHidden = false
                zoneInfoTextView.text = fetchZoneInfoWith(selectedZone: self.currentZone, selectedSpecies: selectedSpecies)
            } else {
                zoneInfoTextView.text = ""
                zoneInfoTextView.isHidden = true
            }
            
            
            self.isSelectedSpecy = true
            self.sepecyIndex = index
            
            handleExceptionsAndOpportunities()
        }
    }

}

//MARK: handleZoneInfo

extension HomeController: XMLParserDelegate {
    
    func determineZoneKmlWith(currentLocation: CLLocationCoordinate2D) {
        
        for i in 0 ..< zonesKml.count {
            let coordinate = zonesKml[i]
            
            let path = self.pathFromCoordinateArray(coordinates: coordinate)
            
            if GMSGeometryContainsLocation(currentLocation, path, true) {
                self.handleKmlWith(index: i + 1)
                self.parseStatusForZone = .zone
            } else {
                let text = "You are in unknown ZONE"
                
                self.zoneLabel.text = text
                currentZone = "0"
            }
        }
    }

    
    fileprivate func handleZoneForBordersKml() {
        
        for i in 1..<18 {
            self.parseStatusForZone = .zoneForBorders
            if let path = Bundle.main.url(forResource: "nz\(i)", withExtension: "kml")   {
                if let parser = XMLParser(contentsOf: path) {
                    parser.delegate = self
                    parser.parse()
                }
            }
        }
        
    }
    
    func handleKmlWith(index: Int) {
        
        if let path = Bundle.main.url(forResource: "z\(index)", withExtension: "kml")   {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }

    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        eName = elementName
        
        if elementName == "Placemark" {
            zoneName = String()
            coordinate = String()
            
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "coordinates"{
            
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
            
            if self.parseStatusForZone == .zone {
                self.zones.append(zone)
            } else {
                self.gmsPaths.append(path)
            }
            
            
            

        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (!string.isEmpty) {
            if eName == "name" {
                
                zoneName += string
                
                
            } else if eName == "coordinates" {
                coordinate += string
            }
        }
        
    }
    
    func handleExceptionsAndOpportunities() {
        self.numbersTextView.isHidden = false
        
        let numExceptions = self.getExceptions(withzone: self.currentZone)
        let numOpportunities = self.getOpportunities(withzone: self.currentZone)
        
        numbersTextView.text = String(numExceptions) + "\n" + " Exceptions" + "\n" + String(numOpportunities) + "\n" + " Opportunities"
        
    }
    
    func handleDetectWhichZone() {
        
        for i in 0 ..< zones.count {
            
            let path = zones[i].gmsPath
            
            if GMSGeometryContainsLocation((self.currentLocation?.coordinate)!, path, true) {
                
                let text = "You are in " + zones[i].zoneName
                self.zoneLabel.text = text
                
                let character = CharacterSet(charactersIn: "ZONE")
                currentZone = zones[i].zoneName.trimmingCharacters(in: character)
                
                handleExceptionsAndOpportunities()
                
                return
                
            } else {
                
                let text = "You are in unknown ZONE"
                self.zoneLabel.text = text
                
                currentZone = "0"
            }
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

//MARK: handle  kml layer
extension HomeController {
    
    func handleTownshipKmls() {
        
        if let filepath = Bundle.main.path(forResource: "town_ios", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                var lines: [String] = []
                contents.enumerateLines { line, _ in
                    lines.append(line)
                }
                
                for i in 0 ..< lines.count {
                    var tempTownshipCordinatesArr = lines[i].components(separatedBy: ",")
                    
                    
                    var township: [String] = []
                    for j in 0 ..< tempTownshipCordinatesArr.count {
                        tempTownshipCordinatesArr[0] = tempTownshipCordinatesArr[0].replacingOccurrences(of: "{", with: "")
                        tempTownshipCordinatesArr[4] = tempTownshipCordinatesArr[4].replacingOccurrences(of: "}", with: "")
                        township.append(tempTownshipCordinatesArr[j])
                    }
                    township.removeLast()
                    townshipsWithMaxMin.append(township)
                }
                
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        
        for i in 0 ..< townshipsWithMaxMin.count {
            
            let township = [CLLocationCoordinate2D(latitude: Double(townshipsWithMaxMin[i][3])!, longitude: Double(townshipsWithMaxMin[i][1])!),CLLocationCoordinate2D(latitude: Double(townshipsWithMaxMin[i][3])!, longitude: Double(townshipsWithMaxMin[i][2])!), CLLocationCoordinate2D(latitude: Double(townshipsWithMaxMin[i][4])!, longitude: Double(townshipsWithMaxMin[i][2])!),  CLLocationCoordinate2D(latitude: Double(townshipsWithMaxMin[i][4])!, longitude: Double(townshipsWithMaxMin[i][1])!)]
            townshipKml.append(township)
        }
        
    }
    
    func handleZonesKml() {
        
        let zone1 = [CLLocationCoordinate2D(latitude: 54.0001144, longitude: -82.1971512),CLLocationCoordinate2D(latitude: 54.0001144, longitude: -91.7422485), CLLocationCoordinate2D(latitude: 56.8593636, longitude: -91.7422485),  CLLocationCoordinate2D(latitude: 56.8593636, longitude: -82.1971512)]
        zonesKml.append(zone1)
        
        let zone2 = [CLLocationCoordinate2D(latitude: 50.0963326, longitude: -85.8396912),CLLocationCoordinate2D(latitude: 50.0963326, longitude: -95.1536713), CLLocationCoordinate2D(latitude: 55.0946503, longitude: -95.1536713),  CLLocationCoordinate2D(latitude: 55.0946503, longitude: -85.8396912)]
        zonesKml.append(zone2)
        
        let zone3 = [CLLocationCoordinate2D(latitude: 49.6148071, longitude: -80.4279938),CLLocationCoordinate2D(latitude: 49.6148071, longitude: -86.6083603), CLLocationCoordinate2D(latitude: 54.0001183, longitude: -86.6083603),  CLLocationCoordinate2D(latitude: 54.0001183, longitude: -80.4279938)]
        zonesKml.append(zone3)
        
        let zone4 = [CLLocationCoordinate2D(latitude: 49.0618401, longitude: -89.1507721), CLLocationCoordinate2D(latitude: 49.0618401, longitude: -95.1536331), CLLocationCoordinate2D(latitude: 51.8874893, longitude: -95.1536331), CLLocationCoordinate2D(latitude: 51.8874893, longitude: -89.1507721)]
        zonesKml.append(zone4)
        
        
        let zone5 = [CLLocationCoordinate2D(latitude: 48.0437775, longitude: -90.8512497),CLLocationCoordinate2D(latitude: 48.0437775, longitude: -95.1536026), CLLocationCoordinate2D(latitude: 50.3519287, longitude: -95.1536026),  CLLocationCoordinate2D(latitude: 50.3519287, longitude: -90.8512497)]
        zonesKml.append(zone5)
        
        let zone6 = [CLLocationCoordinate2D(latitude: 47.985527, longitude: -87.4354401), CLLocationCoordinate2D(latitude: 47.985527, longitude: -91.0735702), CLLocationCoordinate2D(latitude: 50.3316193, longitude: -91.0735702), CLLocationCoordinate2D(latitude: 50.3316193, longitude: -87.4354401)]
        zonesKml.append(zone6)
        
        
        let zone7 = [CLLocationCoordinate2D(latitude: 47.750042, longitude: -82.9542999),CLLocationCoordinate2D(latitude: 47.750042, longitude: -88.2771072), CLLocationCoordinate2D(latitude: 50.2586594, longitude: -88.2771072),  CLLocationCoordinate2D(latitude: 50.2586594, longitude: -82.9542999)]
        zonesKml.append(zone7)
        
        
        let zone8 = [CLLocationCoordinate2D(latitude: 47.467144, longitude: -84.1146164), CLLocationCoordinate2D(latitude: 51.4662743, longitude: -84.1146164), CLLocationCoordinate2D(latitude: 47.467144, longitude: -79.5164261), CLLocationCoordinate2D(latitude: 51.4662743, longitude: -79.5164261)]
        zonesKml.append(zone8)
        
        
        let zone9 = [CLLocationCoordinate2D(latitude: 46.4528618, longitude: -84.3475113),CLLocationCoordinate2D(latitude: 46.4528618, longitude: -89.580101), CLLocationCoordinate2D(latitude: 49.0158043, longitude: -89.580101),  CLLocationCoordinate2D(latitude: 49.0158043, longitude: -84.3475113)]
        zonesKml.append(zone9)
        
        
        let zone10 = [CLLocationCoordinate2D(latitude: 45.5149879, longitude: -80.1818313),CLLocationCoordinate2D(latitude: 45.5149879, longitude: -85.9588547), CLLocationCoordinate2D(latitude: 47.9658623, longitude: -85.9588547),  CLLocationCoordinate2D(latitude: 47.9658623, longitude: -80.1818313)]
        zonesKml.append(zone10)
        
        
        let zone11 = [CLLocationCoordinate2D(latitude: 45.8964577, longitude: -78.2868423),CLLocationCoordinate2D(latitude: 45.8964577, longitude: -80.836319), CLLocationCoordinate2D(latitude: 47.7320251, longitude: -80.836319),  CLLocationCoordinate2D(latitude: 47.7320251, longitude: -78.2868423)]
        zonesKml.append(zone11)
        
        
        let zone12 = [CLLocationCoordinate2D(latitude: 45.3503342, longitude: -74.3811417),CLLocationCoordinate2D(latitude: 45.3503342, longitude: -79.678299), CLLocationCoordinate2D(latitude: 47.5633125, longitude: -79.678299),  CLLocationCoordinate2D(latitude: 47.5633125, longitude: -74.3811417)]
        zonesKml.append(zone12)
        
        
        let zone13 = [CLLocationCoordinate2D(latitude: 42.9985886, longitude: -81.262352),CLLocationCoordinate2D(latitude: 42.9985886, longitude: -83.597168), CLLocationCoordinate2D(latitude: 45.919529, longitude: -83.597168),  CLLocationCoordinate2D(latitude: 45.919529, longitude: -81.262352)]
        zonesKml.append(zone13)
        
        
        let zone14 = [CLLocationCoordinate2D(latitude: 44.4698753, longitude: -79.5783615),CLLocationCoordinate2D(latitude: 44.4698753, longitude: -84.3628769), CLLocationCoordinate2D(latitude: 46.5502281, longitude: -84.3628769),  CLLocationCoordinate2D(latitude: 46.5502281, longitude: -79.5783615)]
        zonesKml.append(zone14)
        
        
        let zone15 = [CLLocationCoordinate2D(latitude: 44.5222626, longitude: -76.3152618),CLLocationCoordinate2D(latitude: 44.5222626, longitude: -80.7753296), CLLocationCoordinate2D(latitude: 46.273571, longitude: -80.7753296),  CLLocationCoordinate2D(latitude: 46.273571, longitude: -76.3152618)]
        zonesKml.append(zone15)
        
        
        let zone16 = [CLLocationCoordinate2D(latitude: 41.9093857, longitude: -78.9081268),CLLocationCoordinate2D(latitude: 41.9093857, longitude: -83.1172943), CLLocationCoordinate2D(latitude: 45.2665863, longitude: -83.1172943),  CLLocationCoordinate2D(latitude: 45.2665863, longitude: -78.9081268)]
        zonesKml.append(zone16)
        
        
        let zone17 = [CLLocationCoordinate2D(latitude: 43.7945442, longitude: -77.547493),CLLocationCoordinate2D(latitude: 43.7945442, longitude: -79.2381668), CLLocationCoordinate2D(latitude: 44.7832565, longitude: -79.2381668),  CLLocationCoordinate2D(latitude: 44.7832565, longitude: -77.547493)]
        zonesKml.append(zone17)
        
        
        let zone18 = [CLLocationCoordinate2D(latitude: 44.0477371, longitude: -74.3433838),CLLocationCoordinate2D(latitude: 44.0477371, longitude: -77.9475098), CLLocationCoordinate2D(latitude: 45.6431465, longitude: -77.9475098),  CLLocationCoordinate2D(latitude: 45.6431465, longitude: -74.3433838)]
        zonesKml.append(zone18)
        
        
        let zone19 = [CLLocationCoordinate2D(latitude: 41.6765556, longitude: -78.9059448),CLLocationCoordinate2D(latitude: 41.6765556, longitude: -83.1496964), CLLocationCoordinate2D(latitude: 43.0795212, longitude: -83.1496964),  CLLocationCoordinate2D(latitude: 43.0795212, longitude: -78.9059448)]
        zonesKml.append(zone19)
        
        
        let zone20 = [CLLocationCoordinate2D(latitude: 43.0772095, longitude: -74.3196487),CLLocationCoordinate2D(latitude: 43.0772095, longitude: -79.890625), CLLocationCoordinate2D(latitude: 45.2054634, longitude: -79.890625),  CLLocationCoordinate2D(latitude: 45.2054634, longitude: -74.3196487)]
        zonesKml.append(zone20)
        
    }

}

















