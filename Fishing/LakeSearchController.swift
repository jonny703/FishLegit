//
//  LakeSearchController.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MessageUI
import KRProgressHUD
import WOWMarkSlider
import PopOverMenu

class LakeSearchController: UIViewController, XMLParserDelegate {
    
    let cellId = "cellId"
    let speciesCellId = "speciesCellId"
    
    var currentLocation = CLLocationCoordinate2D(latitude: 40.0, longitude: -70.0)
    var myLocation = CLLocationCoordinate2D(latitude: 40.0, longitude: -70.0)
    
    var selectedControllerStatus: SearchControllerStatus = .Distance
    var specisShowHideStatus = SpeciesViewStatus.hide
    var parseStatus = ParseStatus.Zone
    
    enum SelectedButtonTag: Int {
        case SearchLake
        case SearchTownship
        case SearchSpecies
    }
    var selectedButtonState: SelectedButtonTag?
    var canEdit = false
    
    var polylines = [GMSPolyline]()
    var zoneMarkers = [GMSMarker]()
    var gmsPaths = [GMSPath]()
    var markers = [LakeMarker]()
    var lakeInfos = [LakeInfo]()
    var zoneNames = [String]()
    var species = [String]()
    var unfilteredArray = ["gegne", "dfdse", "tese", "dfger", "fdfeew", "sfsdfswfe", "efse"].sorted()
    var filteredArray = [String]()
    
    var countKml = 0
    var searchRadius: Double = 100
    var selectedSpecy = ""
    var selectedZone = ""
    var selectedSpecies = ""
    var currentZone = "15"
    var currentTownship = "0"
    var selectedSpecyName = String()
    var isShownZoneInfo = true
    
    var eName: String = String()
    var zoneName = String()
    var coordinate = String()
    var zones = [Zone]()
    
    var townshipName = String()
    var townshipCoordinate = String()
    var townships = [Township]()
    
    var tableViewConstraint: NSLayoutConstraint!
    var inTownshipLabelWidth: NSLayoutConstraint!
    var zoneInfoLabelHeightAncher: NSLayoutConstraint?
    
    let dataProvider = GoogleDataProvider()
    let searchController = UISearchController(searchResultsController: nil)
    
    let reachAbility = Reachability()!
    
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
    
    let sliderViw: SliderView = {
        
        let view = SliderView()
        view.backgroundColor = StyleGuideManager.fishLegitDefultBlueColor
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let speciesContainerView: UIView = {
        
        let view = UIView()
        view.alpha = 0.8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let speciesTableTitle: UILabel = {
        let label = UILabel()
        label.text = "25 Km"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    
    }()
    
    lazy var arrowButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "left_arrow"), for: .normal)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleShowHideSpeciesView), for: .touchUpInside)
        return button
    }()
    
    lazy var speciesTableView: UITableView = {
        var tableView = UITableView();
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView;
    }()
    
    lazy var tableView: UITableView = {
        
        var tableView = UITableView();
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView;
    }()
    
    let mapCenterPinIamgeView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "mapMakerMan")
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let mapTypeSegement: UISegmentedControl = {
        
        let segement = UISegmentedControl(items: ["Normal", "Satellite"])
        segement.translatesAutoresizingMaskIntoConstraints = false
        segement.tintColor = StyleGuideManager.fishLegitDefultBlueColor
        segement.selectedSegmentIndex = 0
        segement.addTarget(self, action: #selector(handelMapType), for: .valueChanged)
        return segement
    }()
    
    let containerZoneInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        return view
    }()
    
    lazy var zoneSelectField: HADropDown = {
        let field = HADropDown()
        field.title = "Select zone"
        field.items = ["cat", "mouse"]
        field.isUserInteractionEnabled = true
        field.delegate = self
        field.layer.cornerRadius = 4
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.borderWidth = 1

        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    lazy var speciesSelectField: HADropDown = {
        let field = HADropDown()
        field.title = "Select species"
        field.items = ["cat", "mouse"]
        field.isUserInteractionEnabled = true
        field.delegate = self
        field.layer.cornerRadius = 4
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.borderWidth = 1
        field.translatesAutoresizingMaskIntoConstraints = false
        return field

    }()
    
    let zoneInfoTextView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 4
        textView.layer.masksToBounds = true
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()
    
    
    
    let zoneInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "No species selected"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .lightGray
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let zoneInfoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    let secondNavigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = StyleGuideManager.fishLegitDefultBlueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 0
        let title = NSLocalizedString("Show Nearest\n        " + String(100) + "Km", comment: "")
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(searchLakes), for: .touchUpInside)
        button.sizeToFit()
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "wed"
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let inTownshipLabel: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("You are in somewhere", for: .normal)
        button.tintColor = .white
        button.backgroundColor = StyleGuideManager.fishLegitDefultBlueColor
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleShowAndHideZoneInfo), for: .touchUpInside
        )
        return button
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
        KRProgressHUD.show()
        
        perform(#selector(handleSets), with: nil, afterDelay: 1.0)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @objc func goingBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

//MARK: setupViews
extension LakeSearchController {
    
    @objc func handleSets() {
        self.view = googleMapView
        
        setupAllViews()
        
        setGoogleMap()
        fetchData()
        KRProgressHUD.dismiss()
    }
    
    private func setupAllViews() {
        
        
        setupSecondNavigationBar()
        setupViews()
        setupSwitch()
        setupTableView()
        setupSpeciesContanierView()
        setupZoneInfoView()
        setupZoneInfoLabel()
        setupShowNearestSlider()
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
    
    private func setupShowNearestSlider() {
        
        sliderViw.delegate = self
        
        view.addSubview(sliderViw)
        
        sliderViw.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.8).isActive = true
        sliderViw.heightAnchor.constraint(equalToConstant: 200).isActive = true
        sliderViw.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        sliderViw.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        sliderViw.isHidden = true
        
    }
    
    func setupSecondNavigationBar() {
        view.addSubview(secondNavigationBar)
        
        secondNavigationBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        secondNavigationBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        secondNavigationBar.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        secondNavigationBar.heightAnchor.constraint(equalToConstant: (self.navigationController?.navigationBar.frame.height)!).isActive = true
        
        secondNavigationBar.addSubview(searchButton)
        
        searchButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        searchButton.heightAnchor.constraint(equalTo: secondNavigationBar.heightAnchor).isActive = true
        searchButton.leftAnchor.constraint(equalTo: secondNavigationBar.leftAnchor, constant: 10).isActive = true
        searchButton.centerYAnchor.constraint(equalTo: secondNavigationBar.centerYAnchor).isActive = true
        
        secondNavigationBar.addSubview(inTownshipLabel)
        
        inTownshipLabel.centerYAnchor.constraint(equalTo: secondNavigationBar.centerYAnchor, constant: 0).isActive = true
        inTownshipLabel.rightAnchor.constraint(equalTo: secondNavigationBar.rightAnchor, constant: -5).isActive = true
        inTownshipLabelWidth = inTownshipLabel.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.5)
        inTownshipLabelWidth.isActive = true
        inTownshipLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    func setupZoneInfoLabel() {
        
        view.addSubview(zoneInfoLabel)
        
        zoneInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        zoneInfoLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        zoneInfoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        zoneInfoLabelHeightAncher = zoneInfoLabel.heightAnchor.constraint(equalToConstant: 40)
        zoneInfoLabelHeightAncher?.isActive = true
        
        zoneInfoLabel.isHidden = false
    }
    
    func setupZoneInfoView() {
        
        view.addSubview(containerZoneInfoView)
        
        containerZoneInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerZoneInfoView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerZoneInfoView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        containerZoneInfoView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        containerZoneInfoView.addSubview(zoneSelectField)
        
        zoneSelectField.topAnchor.constraint(equalTo: containerZoneInfoView.topAnchor, constant: 10).isActive = true
        zoneSelectField.leftAnchor.constraint(equalTo: containerZoneInfoView.leftAnchor, constant: 10).isActive = true
        zoneSelectField.rightAnchor.constraint(equalTo: containerZoneInfoView.rightAnchor, constant: -10).isActive = true
        zoneSelectField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        containerZoneInfoView.addSubview(speciesSelectField)
        
        speciesSelectField.topAnchor.constraint(equalTo: zoneSelectField.bottomAnchor, constant: 10).isActive = true
        speciesSelectField.leftAnchor.constraint(equalTo: containerZoneInfoView.leftAnchor, constant: 10).isActive = true
        speciesSelectField.rightAnchor.constraint(equalTo: containerZoneInfoView.rightAnchor, constant: -10).isActive = true
        speciesSelectField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        containerZoneInfoView.addSubview(zoneInfoTextView)
        
        zoneInfoTextView.topAnchor.constraint(equalTo: speciesSelectField.bottomAnchor, constant: 10).isActive = true
        zoneInfoTextView.leftAnchor.constraint(equalTo: containerZoneInfoView.leftAnchor, constant: 10).isActive = true
        zoneInfoTextView.rightAnchor.constraint(equalTo: containerZoneInfoView.rightAnchor, constant: -10).isActive = true
        zoneInfoTextView.bottomAnchor.constraint(equalTo: containerZoneInfoView.bottomAnchor, constant: -10).isActive = true
        
        zoneNames = fetchZoneName() as! [String]
        species = fetchSpeciesName() as! [String]
        zoneSelectField.items = zoneNames
        speciesSelectField.items = species
        
        containerZoneInfoView.isHidden = true
    }
    
    func setupSpeciesContanierView() {
        
        view.addSubview(speciesContainerView)
        
        speciesContainerView.topAnchor.constraint(equalTo: secondNavigationBar.bottomAnchor).isActive = true
        speciesContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        speciesContainerView.widthAnchor.constraint(equalToConstant: 225).isActive = true
        speciesContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 200).isActive = true
        
        //        speciesContainerView.frame = CGRect(x: 200, y: 50, width: 225, height: view.frame.height)
        
        speciesContainerView.addSubview(arrowButton)
        
        arrowButton.centerYAnchor.constraint(equalTo: speciesContainerView.centerYAnchor).isActive = true
        arrowButton.leftAnchor.constraint(equalTo: speciesContainerView.leftAnchor).isActive = true
        arrowButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        arrowButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        speciesContainerView.addSubview(speciesTableTitle)
        
        speciesTableTitle.topAnchor.constraint(equalTo: speciesContainerView.topAnchor).isActive = true
        speciesTableTitle.leftAnchor.constraint(equalTo: speciesContainerView.leftAnchor, constant: 25).isActive = true
        speciesTableTitle.rightAnchor.constraint(equalTo: speciesContainerView.rightAnchor).isActive = true
        speciesTableTitle.heightAnchor.constraint(equalToConstant: 50).isActive  = true
        
        speciesContainerView.addSubview(speciesTableView)
        
        
        speciesTableView.topAnchor.constraint(equalTo: speciesTableTitle.bottomAnchor).isActive = true
        speciesTableView.bottomAnchor.constraint(equalTo: speciesContainerView.bottomAnchor).isActive = true
        speciesTableView.leftAnchor.constraint(equalTo: arrowButton.rightAnchor).isActive = true
        speciesTableView.rightAnchor.constraint(equalTo: speciesContainerView.rightAnchor).isActive = true
        
        speciesTableView.register(SpeciesCell.self, forCellReuseIdentifier: speciesCellId)
        
    }
    
    func setupTableView() {
        
        filteredArray = unfilteredArray
        view.addSubview(tableView)
        
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        tableViewConstraint = tableView.heightAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.125 * 5 + searchController.searchBar.frame.size.height)
        tableViewConstraint.isActive = true
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.isHidden = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    func setupNavigationItems() {
        view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = false
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        titleLabel.text = "FishLegit"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        navigationItem.titleView = titleLabel
        
        let searchImage = UIImage(named: "search")
        let searchLakeButton = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handlePopoverMenu(sender:)))
        searchLakeButton.tintColor = .white
        self.navigationItem.rightBarButtonItems = [searchLakeButton]
        
        let backImage = UIImage(named: AssetName.back.rawValue)?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(goingBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 24)]
    }
    
    @objc func searchLakes() {
        tableView.isHidden = true
        searchController.dismiss(animated: false, completion: nil)
        containerZoneInfoView.isHidden = true
        zoneInfoLabel.isHidden = true
        isShownZoneInfo = false
        
        sliderViw.isHidden = false
        
        if self.specisShowHideStatus == .show {
            self.handleShowHideSpeciesView()
        }
    }
    
    func searchPlaces() {
        sliderViw.isHidden = true
        tableView.isHidden = true
        searchController.dismiss(animated: false, completion: nil)
        containerZoneInfoView.isHidden = true
        zoneInfoLabel.isHidden = true
        isShownZoneInfo = false
        if self.specisShowHideStatus == .show {
            handleShowHideSpeciesView()
        }
    }
    
    func setupViews() {
        view.addSubview(mapTypeSegement)
        
        mapTypeSegement.widthAnchor.constraint(equalToConstant: 120).isActive = true
        mapTypeSegement.heightAnchor.constraint(equalToConstant: 30).isActive = true
        mapTypeSegement.topAnchor.constraint(equalTo: secondNavigationBar.bottomAnchor, constant: 10).isActive = true
        mapTypeSegement.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        
    }
}

//MARK: handle zone borders feedback
extension LakeSearchController {
    
    func setInvalidCommandLabel() {
        view.addSubview(invalidCommandLabel)
        
        invalidCommandLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        invalidCommandLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        invalidCommandLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
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

//MARK: handle shown zone borders
extension LakeSearchController {
    
    @objc fileprivate func handleShowZoneBorderSwitch(sender: UISwitch) {
        let isShown = sender.isOn
        
        UserDefaults.standard.setIsShownZoneBorders(value: isShown)
        
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
        
        return UserDefaults.standard.isShownZoneBorders()
    }
    
}

//MARK: create marker
extension LakeSearchController {
    func createMarker(titleMarker: String, iconMarker: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees, kind: String) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.icon = iconMarker
        marker.map = googleMapView
        marker.isDraggable = true
        
        let zoom = self.calculateZoomLevel(radius: searchRadius)
        
        if kind == SearchStatus.Other {
            googleMapView.animate(toLocation: marker.position)
            googleMapView.animate(toZoom: Float(zoom))
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.focusLakeForSearch()
            })
        }
    }
    
    fileprivate func marker(forZone zoneName: String, position: CLLocationCoordinate2D) -> GMSMarker {
        
        let marker = GMSMarker()
        marker.position = position
        marker.title = zoneName
        
        let label = self.label(withZoneName: zoneName)
        let icon = self.image(fromView: label)
        marker.icon = icon
        marker.isDraggable = false
        
        return marker
    }
}

//MARK: setup googlemap, vars
extension LakeSearchController {
    
    fileprivate func setGoogleMap() {
        googleMapView.isMyLocationEnabled = true
        googleMapView.settings.myLocationButton = true
    }
    
    fileprivate func fetchZoneName() -> NSArray {
        var zonesArray = [Int]()
        SCSQLite.initWithDatabase("fishy.sqlite3")
        let query = "SELECT distinct(zone) FROM zones_sandl order by zone"
        let array = SCSQLite.selectRowSQL(query)! as NSArray
        
        for i in 0  ..< (array.count)  {
            
            let dictionary = array[i] as! NSDictionary
            let zone = dictionary.value(forKey: "zone") as! String
            zonesArray.append(Int(zone)!)
        }
        zonesArray.sort(by: {$0 < $1})
        var stringZones = [String]()
        for i in 0  ..< (zonesArray.count)  {
            stringZones.append(String(zonesArray[i]))
        }
        
        return stringZones as NSArray
        
    }
    
    fileprivate func fetchSpeciesName() -> NSArray {
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
}

//MARK: handle zone marker
extension LakeSearchController {
    
    private func image(fromView view: UIView) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
    
    private func label(withZoneName name: String) -> UILabel {
        let label = UILabel()
        label.isOpaque = false
        label.text = name
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        label.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        label.layer.cornerRadius = 10
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.5
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }
}

//MARK: handle fetch
extension LakeSearchController {
    
    fileprivate func calculateZoomLevel(radius: Double) -> Int {
        
        let scale: Double = radius * 50
        let zoomLevel = Int(19 - log(scale) / log(2))
        return zoomLevel < 0 ? 0 : zoomLevel > 20 ? 20 : zoomLevel
    }
    
    fileprivate func fetchLakesWith(kind: String, id: Int, coordinate: CLLocationCoordinate2D, radius: Double, name: String) {
        
        googleMapView.clear()
        
        
        self.handleShowZoneBorders()
        
        dataProvider.fetchLakesWithKind(kind: kind, id: id, currentTownship: currentTownship, coordinate: coordinate, radius: radius) { (places) in
            
            self.lakeInfos.removeAll()
            self.markers.removeAll()
            
            for place: LakePlace in places {
                
                let marker = LakeMarker(place: place, type: place.type, isDraggable: false)
                
                if Int(place.distance) != 40000 {
                    marker.map = self.googleMapView
                }
                
                marker.title = place.lakeName
                if place.type == LakeType.opportunity.rawValue {
                    marker.snippet = place.opportunity
                } else {
                    marker.snippet = place.exception
                }
                
                
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
                
                self.lakeInfos.append(lakeInfo)
                self.markers.append(marker)
                
            }
            
            if kind == SearchStatus.Other {
                
                self.speciesTableTitle.text = "Show Nearest"
            } else {
                self.speciesTableTitle.text = name
            }
            self.speciesTableView.reloadData()
        }
        
        let image = UIImage(named: "pin_self")
        
        
        if kind != SearchStatus.Other {
            createMarker(titleMarker: "Me", iconMarker: image!, latitude: coordinate.latitude, longitude: coordinate.longitude, kind: SearchStatus.Lake)
            
            
        } else {
            
            self.createMarker(titleMarker: "Me", iconMarker: image!, latitude: coordinate.latitude, longitude: coordinate.longitude, kind: SearchStatus.Other)
        }
    }
    
    
    fileprivate func fetchData() {
        townships.removeAll()
        determineTwonshipKmlWith(currentLocation: currentLocation)
        handleDetectWhickTownship()
        
        if (selectedControllerStatus == .Distance) {
            fetchLakesWith(kind: SearchStatus.Other, id: 0, coordinate: currentLocation, radius: searchRadius, name: "")
        } else {
            let id = getIdWithName(name: selectedSpecy, tableName: "species")
            fetchLakesWith(kind: SearchStatus.Species, id: id, coordinate: currentLocation, radius: searchRadius, name: selectedSpecy)
        }
        
        self.handleZoneInfo()
    }
    
    @objc fileprivate func handleFetchAllLake() {
        fetchLakesWith(kind: SearchStatus.Other, id: 0, coordinate: currentLocation, radius: 40000, name: "")
        KRProgressHUD.dismiss()
    }
    
    fileprivate func handleZoneInfoLabelWith(currenZone: String, selectedSpecy: String, selectedName: String) {
        
        let zoneInfo = fetchZoneInfoWith(selectedZone: currenZone, selectedSpecies: selectedSpecy)
        
        var zoneInfoText = selectedName + "\n" + zoneInfo as NSString
        
        if currentZone == "0" {
            zoneInfoText = selectedName + "\n" + "You are not currently in a zone" as NSString
            
        }
        
        let myMutableString = NSMutableAttributedString(string: zoneInfoText as String, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)])
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(r: 48, g: 63, b: 159), range: NSRange(location:0,length:selectedName.count))
        
        zoneInfoLabel.attributedText = myMutableString
        
        let height = estimateFrameForText(text: zoneInfoLabel.text!, width: Int(DEVICE_WIDTH), fontSize: 13).height
        zoneInfoLabelHeightAncher?.constant = height + 10
        
        zoneInfoLabel.isHidden = false
        tableView.isHidden = true
        searchController.dismiss(animated: false, completion: nil)
        sliderViw.isHidden = true
        containerZoneInfoView.isHidden = true
    }
    
    @objc fileprivate func focusLakeForSearch() {
        if lakeInfos.count > 0 {
            
            if lakeInfos[0].radius == "true" {
                self.googleMapView.animate(toLocation: lakeInfos[0].coordinate!)
            } else {
                googleMapView.animate(toLocation: currentLocation)
            }
            
        } else {
            googleMapView.animate(toLocation: currentLocation)
        }
        let zoom = self.calculateZoomLevel(radius: searchRadius)
        KRProgressHUD.dismiss()
        googleMapView.animate(toZoom: Float(zoom))
    }
    
    fileprivate func determineTwonshipKmlWith(currentLocation: CLLocationCoordinate2D) {
        
        for i in 0 ..< townshipKml.count {
            let coordinate = townshipKml[i]
            
            let path = self.pathFromCoordinateArray(coordinates: coordinate)
            
            if GMSGeometryContainsLocation(currentLocation, path, true) {
                self.parseStatus = .Township
                self.handleKmlWith(index: i + 1)
                //                return
                
            } else {
                let text = "You are in unknown Township"
                let width = self.estimateFrameForText(text: text, width: Int(DEVICE_WIDTH), fontSize: 14).width + 15
                
                inTownshipLabel.setTitle(text, for: .normal)
                inTownshipLabelWidth.constant = width
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
                currentZone = "0"
                
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
}

//MARK: handle estimate, map type
extension LakeSearchController {
    
    @objc fileprivate func handelMapType() {
        
        if mapTypeSegement.selectedSegmentIndex == 0 {
            googleMapView.mapType = .normal
        } else {
            googleMapView.mapType = .satellite
            
        }
    }
    
    fileprivate func estimateFrameForText(text: String, width: Int, fontSize: Int) -> CGRect {
        
        let size = CGSize(width: width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)
        
    }
}

//MARK: handle zone and township

extension LakeSearchController {
    
    func handleZoneInfo() {
        if currentZone == "0" {
            zoneInfoLabel.text = "You are not currently in a zone"
        } else {
            zoneInfoLabel.text = "No species selected"
        }
        let height = estimateFrameForText(text: zoneInfoLabel.text!, width: Int(DEVICE_WIDTH), fontSize: 13).height
        zoneInfoLabelHeightAncher?.constant = height + 10
        
        if selectedSpecy != "" {
            let id = getIdWithName(name: selectedSpecy, tableName: "species")
            handleZoneInfoLabelWith(currenZone: currentZone, selectedSpecy: String(id), selectedName: selectedSpecy)
        }
        
    }
    
    @objc func handleShowAndHideZoneInfo() {
        
        self.handleZoneInfo()
        if isShownZoneInfo == false {
            zoneInfoLabel.isHidden = false
            
            isShownZoneInfo = true
        } else {
            zoneInfoLabel.isHidden = true
            isShownZoneInfo = false
        }
        tableView.isHidden = true
        searchController.dismiss(animated: false, completion: nil)
        sliderViw.isHidden = true
        containerZoneInfoView.isHidden = true
        
    }
    
    @objc func handleZoneAndTownship() {
        
        zones.removeAll()
        determineZoneKmlWith(currentLocation: currentLocation)
        
        townships.removeAll()
        determineTwonshipKmlWith(currentLocation: currentLocation)
        handleDetectWhickTownship()
        
        self.handleZoneInfo()
        
        if selectedSpecy == "" {
            fetchLakesWith(kind: SearchStatus.Other, id: 0, coordinate: currentLocation, radius: searchRadius, name: "")
        } else {
            let id = getIdWithName(name: selectedSpecy, tableName: "species")
            fetchLakesWith(kind: SearchStatus.Species, id: id, coordinate: currentLocation, radius: searchRadius, name: selectedSpecy)
        }
        
        KRProgressHUD.dismiss()
    }
    
    func handleDetectWhickTownship() {
        
        print("count", townships.count)
        
        for i in 0 ..< townships.count {
            let coordinate = townships[i].townshipCoordinates
            
            let path = self.pathFromCoordinateArray(coordinates: coordinate)
            
            if GMSGeometryContainsLocation(currentLocation, path, true) {
                
                let text = "You are in " + townships[i].townshipName
                
                self.currentTownship = getIdStringWithName(name: townships[i].townshipName, tableName: "townships")
                
                let width = self.estimateFrameForText(text: text, width: Int(DEVICE_WIDTH), fontSize: 14).width + 10
                
                inTownshipLabel.setTitle(text, for: .normal)
                inTownshipLabelWidth.constant = width
                
                return
                
            } else {
                
                let text = "You are in unknown Township"
                let width = self.estimateFrameForText(text: text, width: Int(DEVICE_WIDTH), fontSize: 14).width + 15
                
                inTownshipLabel.setTitle(text, for: .normal)
                inTownshipLabelWidth.constant = width
            }
        }
        
    }
    
    func handleDetectWhichZone(withZone zone: Zone) {
        
        if GMSGeometryContainsLocation(currentLocation, zone.gmsPath, true) {
            
            let text = "You are in " + zone.zoneName
            let width = self.estimateFrameForText(text: text, width: Int(DEVICE_WIDTH), fontSize: 14).width + 10
            
            inTownshipLabel.setTitle(text, for: .normal)
            inTownshipLabelWidth.constant = width
            
            let character = CharacterSet(charactersIn: "ZONE")
            currentZone = zone.zoneName.trimmingCharacters(in: character)
            return
            
        } else {
            
            let text = "You are in unknown ZONE"
            let width = self.estimateFrameForText(text: text, width: Int(DEVICE_WIDTH), fontSize: 14).width + 15
            
            inTownshipLabel.setTitle(text, for: .normal)
            inTownshipLabelWidth.constant = width
            currentZone = "0"
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

//MARK: handle popover menu items just like add, edit pins and sync etc
extension LakeSearchController {
    
    fileprivate func handleSearchTableViewWith(typeStr: String) {
        tableView.isHidden = false
        
        if typeStr == "lakes" {
            searchController.searchBar.placeholder = "Search by Lake"
        } else if typeStr == "twohnships" {
            searchController.searchBar.placeholder = "Search by Township"
        } else if typeStr == "species" {
            searchController.searchBar.placeholder = "Search by Species"
        }
        
        SCSQLite.initWithDatabase("fishy.sqlite3")
        let query = "SELECT id, name FROM \(typeStr)"
        let array = SCSQLite.selectRowSQL(query)! as NSArray
        
        unfilteredArray.removeAll()
        filteredArray.removeAll()
        
        for i in 0  ..< (array.count)  {
            let dictionary = array[i] as! NSDictionary
            let nameLake = dictionary.value(forKey: "name") as? String
            let idLake = dictionary.value(forKey: "id") as? Int
            if let name = nameLake {
                if idLake != nil {
                    unfilteredArray.append(name)
                }
            }
        }
        unfilteredArray = unfilteredArray.sorted()
        unfilteredArray.insert("All", at: 0)
        filteredArray = unfilteredArray
        tableView.reloadData()
        
    }
    
    fileprivate func handleZoneInfoView() {
        containerZoneInfoView.isHidden = false
    }
    
    fileprivate func handleRemoveSearchView() {
        
        sliderViw.isHidden = true
        tableView.isHidden = true
        searchController.dismiss(animated: false, completion: nil)
        containerZoneInfoView.isHidden = true
        zoneInfoLabel.isHidden = true
        isShownZoneInfo = false
        if self.specisShowHideStatus == .show {
            handleShowHideSpeciesView()
        }
    }
    
    @objc fileprivate func handleAddPin() {
        let createPinController = CreatePinController()
        createPinController.currentLocation = myLocation
        createPinController.currentMarkerLocation = myLocation
        createPinController.gmsPaths = self.gmsPaths
        let navController = UINavigationController(rootViewController: createPinController)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleEditPin(marker: LakeMarker) {
        
        let editController = EditPinController()
        editController.currentLocation = myLocation
        editController.currentMarkerLocation = myLocation
        editController.gmsPaths = self.gmsPaths
        editController.currentMarker = marker
        self.canEdit = false
        let navController = UINavigationController(rootViewController: editController)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc fileprivate func setCanEdit() {
        
        self.showAlert(warnigString: "Please choose a Marker/Pin to edit")
        
        self.canEdit = true
    }
    
    @objc fileprivate func handleSync() {
        
        guard let userId = UserDefaults.standard.getUserId() else { return }
        
        if reachAbility.connection == .none {
            self.showJHTAlerttOkayWithIcon(message: "The Internet connection appears to be offline.")
            return
        }
        
        let requestStr = String(format: WebService.sync.rawValue, userId)
        
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
            print("string: ", dataAsString!)
            
            if dataAsString == "\t{}" {
                
                DispatchQueue.main.async {
                    KRProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Database Up to Date.")
                }
                
            } else {
                do {
                    let infos = try JSONDecoder().decode(Infos.self, from: data)
                    print(infos)
                    
                    let success = self.handleSqliteDB(infos: infos)
                    
                    if success {
                        DispatchQueue.main.async {
                            KRProgressHUD.dismiss()
                            self.showJHTAlerttOkayWithIcon(message: "Success!\nFishLegit was updated!")
                        }
                    } else {
                        DispatchQueue.main.async {
                            KRProgressHUD.dismiss()
                            self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                        }
                    }
                } catch let jsonErr {
                    print("Error serializing error: ", jsonErr)
                    DispatchQueue.main.async {
                        KRProgressHUD.dismiss()
                        self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                    }
                }
            }
        }.resume()
    }
    
    private func handleSqliteDB(infos: Infos) -> Bool {
        
        var success = false
        
        if let newPins = infos.new_pins {
            
            for newPin in newPins {
                if let exceptions = newPin.exceptions, let exceptionsDic = exceptions.dictionary  {
                    success = SQLiteHelper.insert(inTable: "exceptions", params: exceptionsDic)
                    
                    print("new_exceptions: ", success)
                }
                
                if let features = newPin.features, let featuresDic = features.dictionary {
                    success = SQLiteHelper.insert(inTable: "features", params: featuresDic)
                    print("new_features: ", success)
                }
                
                if let lakes = newPin.lakes, let id = lakes.id, let name = lakes.name {
                    let lakesDic = ["id": id, "name": name]
                    success = SQLiteHelper.insert(inTable: "lakes", params: lakesDic)
                    print("new_lakes: ", success)
                }
                
                if let zonesSandl = newPin.zones_sandl, let zonesSandlDic = zonesSandl.dictionary {
                    _ = SQLiteHelper.insert(inTable: "zones_sandl", params: zonesSandlDic)
                    print("new_zones_sandl: ", success)
                }
            }
            
        }
        
        if let editPins = infos.edit_pins {
            
            for editPin in editPins {
                if let exceptions = editPin.exceptions, let exceptionsDic = exceptions.dictionary {
                    guard let id = exceptions.id else { return false }
                    let whereDic = ["id": id]
                    success = SQLiteHelper.update(inTable: "exceptions", params: exceptionsDic, where: whereDic)
                    print("edit_exceptions: ", success)
                }
                
                if let features = editPin.features, let featuresDic = features.dictionary {
                    guard let id = features.id else { return false }
                    let whereDic = ["id": id]
                    success = SQLiteHelper.update(inTable: "features", params: featuresDic, where: whereDic)
                    print("edit_features: ", success)
                }
                
                if let lakes = editPin.lakes, let id = lakes.id, let name = lakes.name {
                    let lakesDic = ["id": id, "name": name]
                    let whereDic = ["id": id]
                    success = SQLiteHelper.update(inTable: "lakes", params: lakesDic, where: whereDic)
                    print("edit_lakes: ", success)
                }
                
                if let zonesSandl = editPin.zones_sandl, let zonesSandlDic = zonesSandl.dictionary {
                    guard let id = zonesSandl.id else { return false }
                    let whereDic = ["id": id]
                    _ = SQLiteHelper.update(inTable: "zones_sandl", params: zonesSandlDic, where: whereDic)
                    print("edit_zones_sandle: ", success)
                }
            }
        }
        
        return success
        
    }
    
    
    
}

extension LakeSearchController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return filteredArray.count
        } else {
            return lakeInfos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            
            cell.textLabel?.text = filteredArray[indexPath.row]
            
            return cell
        } else if tableView == self.speciesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesCellId, for: indexPath) as! SpeciesCell
            
            let lakeHeight = estimateFrameForText(text: lakeInfos[indexPath.row].lake!, width: 192, fontSize: 18).height + 15
            let opportunityHeight = estimateFrameForText(text: lakeInfos[indexPath.row].opportunity!, width: 192, fontSize: 15).height + 5
            
            cell.lakeLabelHeightAncher?.constant = lakeHeight
            cell.opportunityLabelHeightAncher?.constant = opportunityHeight
            cell.exceptionLabelHeightAncher?.constant = 0
            
            cell.lakeLabel.text = lakeInfos[indexPath.row].lake
            cell.opportunityLabel.text = lakeInfos[indexPath.row].opportunity
            
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            tableView.isHidden = true
            searchController.dismiss(animated: false, completion: nil)
            
            let name = filteredArray[indexPath.row]
            
            if selectedButtonState == .SearchLake {
                
                if name == "All" {
                    KRProgressHUD.show()
                    perform(#selector(handleFetchAllLake), with: nil, afterDelay: 0.5)
                } else {
                    let id = getIdWithName(name: name, tableName: "lakes")
                    fetchLakesWith(kind: SearchStatus.Lake, id: id, coordinate: currentLocation, radius: 40000, name: name)
                    perform(#selector(focusLakeForSearch), with: nil, afterDelay: 1.0)
                }
                
                
            } else if selectedButtonState == .SearchTownship {
                
                if name == "All" {
                    KRProgressHUD.show()
                    perform(#selector(handleFetchAllLake), with: nil, afterDelay: 0.5)
                } else {
                    let id = getIdWithName(name: name, tableName: "townships")
                    fetchLakesWith(kind: SearchStatus.Township, id: id, coordinate: currentLocation, radius: 40000, name: name)
                    perform(#selector(focusLakeForSearch), with: nil, afterDelay: 1.0)
                }
                
                
            } else {
                
                if name == "All" {
                    KRProgressHUD.show()
                    perform(#selector(handleFetchAllLake), with: nil, afterDelay: 0.5)
                } else {
                    let id = getIdWithName(name: name, tableName: "species")
                    selectedSpecy = name
                    isShownZoneInfo = true
                    KRProgressHUD.show()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        
                        self.handleZoneInfoLabelWith(currenZone: self.currentZone, selectedSpecy: String(id), selectedName: name)
                        self.fetchLakesWith(kind: SearchStatus.Species, id: id, coordinate: self.currentLocation, radius: self.searchRadius, name: name)
                    })
                    
                    perform(#selector(self.focusLakeForSearch), with: nil, afterDelay: 2.0)
                }
            }
            
        } else {
            
            if lakeInfos[indexPath.row].radius == "true" {
                self.googleMapView.animate(toLocation: lakeInfos[indexPath.row].coordinate!)
                self.googleMapView.selectedMarker = markers[indexPath.row]
                handleShowHideSpeciesView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.tableView {
            return DEVICE_WIDTH * 0.125
        } else {
            
            let lakeHeight = estimateFrameForText(text: lakeInfos[indexPath.row].lake!, width: 192, fontSize: 18).height + 15
            let opportunityHeight = estimateFrameForText(text: lakeInfos[indexPath.row].opportunity!, width: 192, fontSize: 15).height + 5
            
            return lakeHeight + opportunityHeight
        }
        
    }
}

extension LakeSearchController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredArray = unfilteredArray.filter {
                team in return team.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredArray = unfilteredArray
        }
        tableView.reloadData()
        print(tableView.contentSize.height)
        
        if tableView.contentSize.height < DEVICE_WIDTH * 0.125 * 5 + searchController.searchBar.frame.size.height {
            tableViewConstraint.constant = tableView.contentSize.height + searchController.searchBar.frame.size.height - DEVICE_WIDTH * 0.125
        } else {
            tableViewConstraint.constant = DEVICE_WIDTH * 0.125 * 5 + searchController.searchBar.frame.size.height
        }
    }
    
}

//MARK: handle nearest slider
extension LakeSearchController: SliderViewDelegate {
    
    func didClickSearhButton(distance: Int) {
        
        searchRadius = Double(distance)
        sliderViw.isHidden = true
        KRProgressHUD.show()
        
        perform(#selector(handleDistanceChosen), with: nil, afterDelay: 0.5)
        
    }
    
    @objc func handleDistanceChosen() {
        
        let zoom = self.calculateZoomLevel(radius: searchRadius)
        
        let title = NSLocalizedString("Show Nearest\n        " + String(Int(searchRadius)) + "Km", comment: "")
        searchButton.setTitle(title, for: .normal)
        
        fetchLakesWith(kind: SearchStatus.Other, id: 0, coordinate: currentLocation, radius: searchRadius, name: "")
        
        KRProgressHUD.dismiss()
        googleMapView.animate(toZoom: Float(zoom))
    }
    
}



extension LakeSearchController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("tapped marker")
        
        if marker.isKind(of: LakeMarker.self), let selectedMarker = marker as? LakeMarker {
            
            selectedMarker.isDraggable = true
            self.handleEditPin(marker: selectedMarker)
        }
        
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        KRProgressHUD.show()
        
        currentLocation = myLocation
        
        perform(#selector(handleZoneAndTownship), with: nil, afterDelay: 0.5)
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        tableView.isHidden = true
        searchController.dismiss(animated: false, completion: nil)
        sliderViw.isHidden = true
        containerZoneInfoView.isHidden = true
        
        if self.specisShowHideStatus == .show {
            handleShowHideSpeciesView()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        
        KRProgressHUD.show()
        currentLocation = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
        
        perform(#selector(handleZoneAndTownship), with: nil, afterDelay: 1.0)
    }
}

//MARK: handle xml parser
extension LakeSearchController {
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

//MARK: handle email report
extension LakeSearchController: MFMailComposeViewControllerDelegate {
    fileprivate func handleSendingEmail() {
        
        let mailComposeController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["dev@fishlegit.ca"])
        mailComposerVC.setSubject("FishLegit is awesome!")
        mailComposerVC.setMessageBody("Great App ever!", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        
        showAlertMessage(vc: self, titleStr: "Could Not Send Email", messageStr: "Your device could not send e-mail.  Please check e-mail configuration and try again.")
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK: handle popover menu
extension LakeSearchController: UIAdaptivePresentationControllerDelegate {
    
    @objc fileprivate func handlePopoverMenu(sender: UIBarButtonItem) {
        
        handleRemoveSearchView()
        setupPopoverMenu(sender: sender)
        
    }
    
    private func setupPopoverMenu(sender: UIBarButtonItem) {
        let menus = ["Search by Species", "Zone Information", "Create Pin", "Edit Pin", "Sync", "Report a bug"]
        let popoverMenuController = PopOverViewController.instantiate()
        popoverMenuController.setTitles(menus)
        popoverMenuController.setSeparatorStyle(.singleLine)
        popoverMenuController.popoverPresentationController?.barButtonItem = sender
        popoverMenuController.preferredContentSize = CGSize(width: 180, height: 270)
        popoverMenuController.presentationController?.delegate = self
        popoverMenuController.completionHandler = { selectRow in
            
            switch (selectRow) {
            case 0:
                self.handleSearchTableViewWith(typeStr: "species")
                self.selectedButtonState = .SearchSpecies
                break
            case 1:
                self.handleZoneInfoView()
                break
            case 2:
                self.handleAddPin()
                break
            case 3:
                self.setCanEdit()
                break
            case 4:
                self.handleSync()
                break
            case 5:
                self.handleSendingEmail()
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






















