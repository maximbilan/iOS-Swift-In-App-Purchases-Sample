//
//  ViewController.swift
//  ios_swift_in_app_purchases_sample
//
//  Created by Maxim Bilan on 7/27/15.
//  Copyright (c) 2015 Maxim Bilan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func unlockTestInAppPurchase1(_ sender: UIButton) {
		InAppPurchase.sharedInstance.buyUnlockTestInAppPurchase1()
	}

	@IBAction func unlockTestInAppPurchase2(_ sender: UIButton) {
		InAppPurchase.sharedInstance.buyUnlockTestInAppPurchase2()
	}
	
	@IBAction func autorenewableSubscription(_ sender: UIButton) {
		InAppPurchase.sharedInstance.buyAutorenewableSubscription()
	}
	
	@IBAction func nonrenewingSubscription(_ sender: UIButton) {
		InAppPurchase.sharedInstance.buyNonrenewingSubscription()
	}
	
	@IBAction func restorePurchases(_ sender: UIButton) {
		InAppPurchase.sharedInstance.restoreTransactions()
	}
	
}

