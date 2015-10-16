//
//  KSPBannerViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 25/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit
import iAd
import IAPController

let BannerViewActionWillBegin = "BannerViewActionWillBegin"
let BannerViewActionDidFinish = "BannerViewActionDidFinish"
let BannerShouldBeHiddenByIAP = "BannerShouldBeHiddenByIAP"

class BannerViewController: UIViewController, ADBannerViewDelegate {
    var contentController: UIViewController!
    
    convenience init(contentController: UIViewController) {
        self.init()
        
        self.contentController = contentController
        BannerViewManager.sharedInstance.addBannerViewController(self)
    }
    
    deinit {
        BannerViewManager.sharedInstance.removeBannerViewController(self)
    }
    
    override func loadView() {
        let contentView = UIView(frame: UIScreen.mainScreen().bounds)
        
        self.addChildViewController(contentController)
        contentView.addSubview(contentController.view)
        contentController.didMoveToParentViewController(self)
        
        self.view = contentView
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return contentController.preferredInterfaceOrientationForPresentation()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return contentController.supportedInterfaceOrientations()
    }
    
    override func viewDidLayoutSubviews() {
        var contentFrame = self.view.bounds, bannerFrame = CGRectZero
        let bannerView = BannerViewManager.sharedInstance.bannerView
        
        bannerFrame.size = bannerView.sizeThatFits(contentFrame.size)
        
        if bannerView.bannerLoaded && !Settings.sharedInstance.completeVersionPurchased {
            contentFrame.size.height -= bannerFrame.size.height
            bannerFrame.origin.y = contentFrame.size.height
        } else {
            bannerFrame.origin.y = contentFrame.size.height
        }
        
        contentController.view.frame = contentFrame
        
        if self.isViewLoaded() && !Settings.sharedInstance.completeVersionPurchased && self.view.window != nil {
            self.view.addSubview(bannerView)
            bannerView.frame = bannerFrame
        } else {
            bannerView.removeFromSuperview()
        }
    }
    
    func updateLayout() {
        UIView.animateWithDuration(0.25, animations: {
            // These two are equivalent to layoutSubviews
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(BannerViewManager.sharedInstance.bannerView)
    }
    
    override var title: String? {
        get {
            return contentController.title
        }
        set {
            contentController.title = newValue
        }
    }
    
    override var navigationItem: UINavigationItem {
        get {
            return contentController.navigationItem
        }
    }
}

class BannerViewManager: NSObject, ADBannerViewDelegate {
    var bannerView: ADBannerView
    var bannerViewControllers: [BannerViewController]
    
    static let sharedInstance = BannerViewManager()
    
    override init() {
        self.bannerView = ADBannerView(adType: .Banner)
        self.bannerViewControllers = []
        
        super.init()
        bannerView.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateLayouts", name: BannerShouldBeHiddenByIAP, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func addBannerViewController(controller: BannerViewController) {
        self.bannerViewControllers.append(controller)
    }
    
    func removeBannerViewController(controller: BannerViewController) {
        if let index = self.bannerViewControllers.indexOf(controller) {
            self.bannerViewControllers.removeAtIndex(index)
        }
    }
    
    func updateLayouts() {
        self.bannerViewControllers.forEach { bvc in
            bvc.updateLayout()
        }
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        updateLayouts()
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        updateLayouts()
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
         NSNotificationCenter.defaultCenter().postNotificationName(BannerViewActionWillBegin, object: self)
        return true
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        NSNotificationCenter.defaultCenter().postNotificationName(BannerViewActionDidFinish, object: self)
    }
}