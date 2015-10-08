//
//  SettingsViewController.swift
//  Minesweeper
//
//  Created by Thomas Durand on 10/08/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import StoreKit
import XLForm

class SettingsViewController: XLFormViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var hideAdsRow: XLFormRowDescriptor?
    var restoreRow: XLFormRowDescriptor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupForm()
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        if !Settings.isCompleteVersionPurchased {
            requestProductData()
        }
    }
    
    func setupForm() {
        let form = XLFormDescriptor(title: "Settings")
        
        var section = XLFormSectionDescriptor()
        section.title = "Difficulty"
        form.addFormSection(section)
        
        var row = XLFormRowDescriptor(tag: "difficulty", rowType: XLFormRowDescriptorTypeSelectorPush, title: "Difficulty")
        row.selectorTitle = "Difficulty"
        row.selectorOptions = GameDifficulty.allRawValues
        row.value = Settings.difficulty.rawValue
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor()
        section.title = "Gameplay"
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: "vibrate", rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Vibrations")
        row.value = Settings.isVibrationEnabled
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "longPress", rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Mark with long press")
        row.value = Settings.isMarkWithLongPressEnabled
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "hiddenToolbar", rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Hide Toolbar")
        row.value = Settings.isBottomBarHidden
        row.hidden = "$longPress==0"
        section.addFormRow(row)
        
        if !Settings.isCompleteVersionPurchased {
            section = XLFormSectionDescriptor()
            section.title = "Purchase complete version"
            section.footerTitle = "Complete version gives you access to Hard and Insane levels of difficulty"
            form.addFormSection(section)
            
            hideAdsRow = XLFormRowDescriptor(tag: "fullVersion", rowType: XLFormRowDescriptorTypeButton, title: "Purchase complete version")
            hideAdsRow!.action.formSelector = Selector("purchaseFullVersion")
            hideAdsRow!.disabled = true
            section.addFormRow(hideAdsRow!)
            
            restoreRow = XLFormRowDescriptor(tag: "restorePurchase", rowType: XLFormRowDescriptorTypeButton, title: "Restore purchases")
            restoreRow!.action.formSelector = Selector("restoreInAppPurchase")
            hideAdsRow!.disabled = true
            section.addFormRow(restoreRow!)
        }
        
        self.form = form
    }
    
    func saveForm() {
        let dict = self.formValues()
        
        if let raw = dict["difficulty"] as? String {
            if let difficulty = GameDifficulty(rawValue: raw) {
                Settings.setDifficulty(difficulty)
            }
        }
        
        if let vibrate = dict["vibrate"] as? Bool {
            Settings.setVibration(vibrate)
        }
        
        if let longPress = dict["longPress"] as? Bool {
            Settings.setMarkForLongPress(longPress)
        }
        
        if let hiddenToolbar = dict["hiddenToolbar"] as? Bool {
            Settings.setBottomBarHidden(hiddenToolbar)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveForm()
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // In App Purchase
    let productIdentifiers = Set(["fr.Dean.Minesweeper.hideAds"])
    var removeAdProduct: SKProduct?
    
    func purchaseFullVersion(sender: XLFormRowDescriptor) {
        // handle the in app purchase
        if !Settings.isCompleteVersionPurchased {
            let payment = SKPayment(product: removeAdProduct)
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }
    }
    
    func restoreInAppPurchase(sender: XLFormRowDescriptor) {
        // handle in app purchase restoration
        if !Settings.isCompleteVersionPurchased {
            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        }
    }
    
    func requestProductData()
    {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: self.productIdentifiers as Set<NSObject>)
            request.delegate = self
            request.start()
            if restoreRow != nil {
                restoreRow!.disabled = false
            }
        } else {
            var alert = UIAlertController(title: NSLocalizedString("IAP_NOT_ENABLED", comment: ""), message: NSLocalizedString("IAP_NOT_ENABLED_DESC", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("SETTINGS", comment: ""), style: UIAlertActionStyle.Default, handler: {
                alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                
                let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.sharedApplication().openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("DISMISS", comment: ""), style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        
        var products = response.products
        
        if (products.count == 1) {
            self.removeAdProduct = products[0] as? SKProduct
            
            let formatter = NSNumberFormatter()
            formatter.formatterBehavior = .Behavior10_4
            formatter.numberStyle = .CurrencyStyle
            formatter.locale = removeAdProduct!.priceLocale
            
            if hideAdsRow != nil {
                hideAdsRow!.title = "Purchase complete version (\(formatter.stringFromNumber(self.removeAdProduct!.price)!)))"
                hideAdsRow!.disabled = false
            }
        } else {
            println("No products found")
        }
        
        products = response.invalidProductIdentifiers
        
        for product in products
        {
            println("Product not found: \(product)")
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        for transaction in transactions as! [SKPaymentTransaction] {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Restored:
                println("Transaction Restored")
                println("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Purchased:
                println("Transaction Approved")
                println("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                println("Transaction Failed")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    func deliverProduct(transaction:SKPaymentTransaction) {
        if transaction.payment.productIdentifier == "fr.Dean.Minesweeper.hideAds"
        {
            println("Remove adds Purchased")
            Settings.setCompletVersionPurchased(true)
            if hideAdsRow != nil {
                hideAdsRow!.disabled = true
            }
            if restoreRow != nil {
                restoreRow!.disabled = true
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        println("Transactions Restored")
        var purchasedItemIDS = []
        for transaction:SKPaymentTransaction in queue.transactions as! [SKPaymentTransaction] {
            
            deliverProduct(transaction)
        }
        
        var alert = UIAlertView(title: NSLocalizedString("THANK_YOU", comment: ""), message: NSLocalizedString("IAP_RESTORED", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("DISMISS", comment: ""))
        alert.show()
    }
}
