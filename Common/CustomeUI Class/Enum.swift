//
//  Enum.swift
//  
//
//  Created by  on 04/07/20.
//  Copyright © 2020 . All rights reserved.
//

import Foundation

enum NavigationBarType: Int {
    case withLogo = 0, withTitle = 1, clearType = 2, clearBlack = 3
}

enum LoginType: Int {
    case Email = 1, FB = 2, Google = 3 , Insta = 4
}

enum LoginPagType: Int {
    case setting , other, profile, create , change, notification, explore
}


enum ListType: Int {
    case foryou , following , details
}

enum fontType: String {
    case Hello_Valentina = "Hello Valentica"
    case SFProDisplay_Medium = "SFProDisplay-Medium"
    case SFProText_Regular = "SFProText-Regular"
    case SFProDisplay_Regular = "SFProDisplay-Regular"
    case SFProDisplay_Bold = "SFProDisplay-Bold"
    case SFDIsplay_Semibold = "SFProDisplay-Semibold"
}

