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
        return UIColor.hx_colorWithHexString("#ECF0F1")
    }
    
    static var gameOverBackgroundColor: UIColor {
        return UIColor.hx_colorWithHexString("#FAFAFA")
    }
    
    static var gameOverBorderColor: UIColor {
        return UIColor.hx_colorWithHexString("#DDDDDD")
    }
    
    static var unrevealedTileColor: UIColor {
        return UIColor.hx_colorWithHexString("#337AB7")
    }
    
    static var revealedTileColor: UIColor {
        return UIColor.whiteColor()
    }
    
    static var solvedMineTileColor: UIColor {
        return UIColor.hx_colorWithHexString("#5CB85C")
    }
    
    static var unsolvedMineTileColor: UIColor {
        return UIColor.hx_colorWithHexString("#5BC0dE")
    }
    
    static var explodedMineTileColor: UIColor {
        return UIColor.hx_colorWithHexString("#D9534F")
    }
    
    static var markedTileColor: UIColor {
        return UIColor.hx_colorWithHexString("#f0AD4E")
    }
    
    static func fontColorWithMines(nbMines: Int) -> UIColor {
        switch nbMines {
        case 1:
            return UIColor.hx_colorWithHexString("#007AFF")
        case 2:
            return UIColor.hx_colorWithHexString("#4CD964")
        case 3:
            return UIColor.hx_colorWithHexString("#FF3B30")
        case 4:
            return UIColor.hx_colorWithHexString("#C644FC")
        case 5:
            return UIColor.hx_colorWithHexString("#FF9500")
        case 6:
            return UIColor.hx_colorWithHexString("#81F3FD")
        case 8:
            return UIColor.hx_colorWithHexString("#C7C7CC")
        default:
            return UIColor.blackColor()
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
        let size: CGSize = CGSizeMake(300, 170)
        return CGRectMake(-size.width/2, -size.height/2, size.width, size.height)
    }
    
    static var gameLostSize: CGRect {
        let size: CGSize = CGSizeMake(250, 100)
        return CGRectMake(-size.width/2, -size.height/2, size.width, size.height)
    }
}
