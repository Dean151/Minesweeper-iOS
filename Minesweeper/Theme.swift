//
//  Theme.swift
//  Minesweeper
//
//  Created by Thomas Durand on 24/07/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import ChameleonFramework
import HexColors

class Theme {
    static var backgroundColor: UIColor {
        return UIColor.flatWhite
    }
    
    static var gameOverBackgroundColor: UIColor {
        return UIColor(hexString: "#FAFAFA")!
    }
    
    static var gameOverBorderColor: UIColor {
        return UIColor(hexString: "#DDDDDD")!
    }
    
    static var unrevealedTileColor: UIColor {
        return UIColor.flatSkyBlueDark
    }
    
    static var revealedTileColor: UIColor {
        return UIColor.white
    }
    
    static var solvedMineTileColor: UIColor {
        return UIColor(hexString: "#5CB85C")!
    }
    
    static var unsolvedMineTileColor: UIColor {
        return UIColor.flatYellow
    }
    
    static var explodedMineTileColor: UIColor {
        return UIColor.flatRed
    }
    
    static var markedTileColor: UIColor {
        return UIColor(hexString: "#f0AD4E")!
    }
    
    static func fontColorWithMines(_ nbMines: Int) -> UIColor {
        switch nbMines {
        case 1:
            return UIColor(hexString: "#007AFF")!
        case 2:
            return UIColor(hexString: "#4CD964")!
        case 3:
            return UIColor(hexString: "#FF3B30")!
        case 4:
            return UIColor(hexString: "#C644FC")!
        case 5:
            return UIColor(hexString: "#FF9500")!
        case 6:
            return UIColor(hexString: "#81F3FD")!
        case 8:
            return UIColor(hexString: "#C7C7CC")!
        default:
            return UIColor.black
        }
    }
    
    static var scaleForModifyingTile: CGFloat {
        return 1.5
    }
    
    static var scaleForOveredTile: CGFloat {
        return 2
    }
    
    static var scaleForMarkingTile: CGFloat {
        return 6
    }
    
    static var alphaForOveredTile: CGFloat {
        return 0.8
    }
    
    static var maxTileSize: CGFloat {
        return 65
    }
    
    static var minSideBorder: CGFloat {
        return 10
    }
    
    static var gameWonSize: CGRect {
        let size: CGSize = CGSize(width: 300, height: 170)
        return CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
    }
    
    static var gameLostSize: CGRect {
        let size: CGSize = CGSize(width: 250, height: 100)
        return CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
    }
}
