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
        return UIColor.hx_color(withHexRGBAString: "#FAFAFAFF")!
    }
    
    static var gameOverBorderColor: UIColor {
        return UIColor.hx_color(withHexRGBAString: "#DDDDDDFF")!
    }
    
    static var unrevealedTileColor: UIColor {
        return UIColor.flatSkyBlueDark
    }
    
    static var revealedTileColor: UIColor {
        return UIColor.white
    }
    
    static var solvedMineTileColor: UIColor {
        return UIColor.hx_color(withHexRGBAString: "#5CB85CFF")!
    }
    
    static var unsolvedMineTileColor: UIColor {
        return UIColor.flatYellow
    }
    
    static var explodedMineTileColor: UIColor {
        return UIColor.flatRed
    }
    
    static var markedTileColor: UIColor {
        return UIColor.hx_color(withHexRGBAString: "#f0AD4EFF")!
    }
    
    static func fontColorWithMines(_ nbMines: Int) -> UIColor {
        switch nbMines {
        case 1:
            return UIColor.hx_color(withHexRGBAString: "#007AFFFF")!
        case 2:
            return UIColor.hx_color(withHexRGBAString: "#4CD964FF")!
        case 3:
            return UIColor.hx_color(withHexRGBAString: "#FF3B30FF")!
        case 4:
            return UIColor.hx_color(withHexRGBAString: "#C644FCFF")!
        case 5:
            return UIColor.hx_color(withHexRGBAString: "#FF9500FF")!
        case 6:
            return UIColor.hx_color(withHexRGBAString: "#81F3FDFF")!
        case 8:
            return UIColor.hx_color(withHexRGBAString: "#C7C7CCFF")!
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
