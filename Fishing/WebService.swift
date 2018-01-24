//
//  WebService.swift
//  Fishing
//
//  Created by John Nik on 11/13/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

//*IMPORTANT: New api location will be here: http://fishlegit.ca/api/  MEANS: http://fishlegit.ca/api/ replaces demo.soundsoftware.ca/apifishy/

enum WebService: String {
    case signUp = "http://fishlegit.ca/api/get.php?api_pass=blpVcWtjY2IwSWFOTkxncDMxWlVPdz09&act=signup&email=%@&password=%@"
    case login = "http://fishlegit.ca/api/get.php?api_pass=blpVcWtjY2IwSWFOTkxncDMxWlVPdz09&act=login&email=%@&password=%@"
    case createPinSubmit = "http://fishlegit.ca/api/get.php?api_pass=blpVcWtjY2IwSWFOTkxncDMxWlVPdz09&act=newpinsubmit&user_id=%@&lake_id=%@&name=%@&lon=%@&lat=%@&type=%@&species=%@&zone=%@&township=%@&detail=%@"
    case editPinSubmit = "http://fishlegit.ca/api/get.php?api_pass=blpVcWtjY2IwSWFOTkxncDMxWlVPdz09&act=editpinsubmit&id=%d&user_id=%@&lake_id=%d&name=%@&lon=%@&lat=%@&type=%@&township=%@&type_id=%@&zone=%@&old_lat=%@&old_lon=%@&old_township=%@&old_zone=%@species=%@&detail=%@"
    
    case sync = "http://fishlegit.ca/api/get.php?api_pass=blpVcWtjY2IwSWFOTkxncDMxWlVPdz09&act=synclocale&user_id=%@"
}
