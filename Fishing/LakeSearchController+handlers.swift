//
//  LakeSearchController+handlers.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

//MARK handle side tableview
extension LakeSearchController {
    @objc func handleShowHideSpeciesView() {
        
        if self.specisShowHideStatus == .show {
            self.hideSpeciesViewHide()
        } else {
            tableView.isHidden = true
            searchController.dismiss(animated: false, completion: nil)
            sliderViw.isHidden = true
            containerZoneInfoView.isHidden = true
            zoneInfoLabel.isHidden = true
            isShownZoneInfo = false
            self.showSpeciesViewShow()
        }
        
    }
    
    func showSpeciesViewShow() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let y = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height + self.secondNavigationBar.frame.height
            print(y)
            self.speciesContainerView.frame = CGRect(x: self.view.frame.width - self.speciesContainerView.frame.width, y:  self.secondNavigationBar.frame.height, width: self.speciesContainerView.frame.width, height: self.speciesContainerView.frame.height)
        }) { (completed: Bool) in
            self.specisShowHideStatus = .show
            self.arrowButton.setImage(UIImage(named: "right_arrow"), for: .normal)
        }
        
    }
    
    func hideSpeciesViewHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.speciesContainerView.frame = CGRect(x: self.view.frame.width - self.arrowButton.frame.width, y: self.secondNavigationBar.frame.height, width: self.speciesContainerView.frame.width, height: self.speciesContainerView.frame.height)
        }) { (completed: Bool) in
            self.specisShowHideStatus = .hide
            self.arrowButton.setImage(UIImage(named: "left_arrow"), for: .normal)
        }
    }
}


extension LakeSearchController: HADropDownDelegate {
    
    func didSelectItem(dropDown: HADropDown, at index: Int) {
        
        
        if dropDown == zoneSelectField {
            
            selectedZone = zoneNames[index]
            
            if selectedSpecies != "" {
                zoneInfoTextView.text = fetchZoneInfoWith(selectedZone: selectedZone, selectedSpecies: selectedSpecies)
            } else {
                zoneInfoTextView.text = ""
            }
            
        } else {
            
            selectedSpecies = String(getIdWithName(name: species[index], tableName: "species"))
            if selectedZone != "" {
                zoneInfoTextView.text = fetchZoneInfoWith(selectedZone: selectedZone, selectedSpecies: selectedSpecies)
            } else {
                zoneInfoTextView.text = ""
            }
            
        }
    }
}
