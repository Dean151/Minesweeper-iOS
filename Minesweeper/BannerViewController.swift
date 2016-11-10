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
        let contentView = UIView(frame: UIScreen.main.bounds)
        
        self.addChildViewController(contentController)
        contentView.addSubview(contentController.view)
        contentController.didMove(toParentViewController: self)
        
        self.view = contentView
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return contentController.preferredInterfaceOrientationForPresentation
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return contentController.supportedInterfaceOrientations
    }
    
    override func viewDidLayoutSubviews() {
        var contentFrame = self.view.bounds, bannerFrame = CGRect.zero
        let bannerView = BannerViewManager.sharedInstance.bannerView
        
        bannerFrame.size = bannerView.sizeThatFits(contentFrame.size)
        
        if bannerView.isBannerLoaded && !Settings.sharedInstance.completeVersionPurchased {
            contentFrame.size.height -= bannerFrame.size.height
            bannerFrame.origin.y = contentFrame.size.height
        } else {
            bannerFrame.origin.y = contentFrame.size.height
        }
        
        contentController.view.frame = contentFrame
        
        if self.isViewLoaded && !Settings.sharedInstance.completeVersionPurchased && self.view.window != nil {
            self.view.addSubview(bannerView)
            bannerView.frame = bannerFrame
        } else {
            bannerView.removeFromSuperview()
        }
    }
    
    func updateLayout() {
        UIView.animate(withDuration: 0.25, animations: {
            // These two are equivalent to layoutSubviews
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        self.bannerView = ADBannerView(adType: .banner)
        self.bannerViewControllers = []
        
        super.init()
        bannerView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(BannerViewManager.updateLayouts), name: NSNotification.Name(rawValue: BannerShouldBeHiddenByIAP), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addBannerViewController(_ controller: BannerViewController) {
        self.bannerViewControllers.append(controller)
    }
    
    func removeBannerViewController(_ controller: BannerViewController) {
        if let index = self.bannerViewControllers.index(of: controller) {
            self.bannerViewControllers.remove(at: index)
        }
    }
    
    func updateLayouts() {
        self.bannerViewControllers.forEach { bvc in
            bvc.updateLayout()
        }
    }
    
    func bannerViewDidLoadAd(_ banner: ADBannerView!) {
        updateLayouts()
    }
    
    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        updateLayouts()
    }
    
    func bannerViewActionShouldBegin(_ banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
         NotificationCenter.default.post(name: Notification.Name(rawValue: BannerViewActionWillBegin), object: self)
        return true
    }
    
    func bannerViewActionDidFinish(_ banner: ADBannerView!) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: BannerViewActionDidFinish), object: self)
    }
}
