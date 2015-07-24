//
//  Theme.swift
//  Minesweeper
//
//  Created by Thomas Durand on 24/07/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import HexColors

class Theme {
    static var backgroundColor: UIColor {
        return UIColor(hexString: "#ECF0F1")
    }
    
    static var unrevealedTileColor: UIColor {
        return UIColor(hexString: "#337ab7")
    }
    
    static var revealedTileColor: UIColor {
        return UIColor.whiteColor()
    }
    
    static var solvedMineTileColor: UIColor {
        return UIColor(hexString: "#5cb85c")
    }
    
    static var unsolvedMineTileColor: UIColor {
        return UIColor(hexString: "#5bc0de")
    }
    
    static var explodedMineTileColor: UIColor {
        return UIColor(hexString: "#d9534f")
    }
    
    static var markedTileColor: UIColor {
        return UIColor(hexString: "#f0ad4e")
    }
    
    static func fontColorWithMines(nbMines: Int) -> UIColor {
        switch nbMines {
        case 1:
            return UIColor(hexString: "#007AFF")
        case 2:
            return UIColor(hexString: "#4CD964")
        case 3:
            return UIColor(hexString: "#FF3B30")
        case 4:
            return UIColor(hexString: "#C644FC")
        case 5:
            return UIColor(hexString: "#FF9500")
        case 6:
            return UIColor(hexString: "#81F3FD")
        case 8:
            return UIColor(hexString: "#C7C7CC")
        default:
            return UIColor.blackColor()
        }
    }
}
