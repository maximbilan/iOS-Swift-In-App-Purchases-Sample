//
//  InAppPurchase.swift
//  ios_swift_in_app_purchases_sample
//
//  Created by Maxim Bilan on 7/27/15.
//  Copyright (c) 2015 Maxim Bilan. All rights reserved.
//

import Foundation
import StoreKit

class InAppPurchase : NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
	
	let kInAppProductPurchasedNotification = "InAppProductPurchasedNotification"
	let kInAppPurchaseFailedNotification   = "InAppPurchaseFailedNotification"
	let kInAppProductRestoredNotification  = "InAppProductRestoredNotification"
	let kInAppPurchasingErrorNotification  = "InAppPurchasingErrorNotification"
	
	let unlockTestInAppPurchase1ProductId = "com.testing.iap1"
	let unlockTestInAppPurchase2ProductId = "com.testing.iap2"
	
	class var sharedInstance : InAppPurchase {
		struct Static {
			static var onceToken: dispatch_once_t = 0
			static var instance: InAppPurchase? = nil
		}
		dispatch_once(&Static.onceToken) {
			Static.instance = InAppPurchase()
		}
		return Static.instance!
	}
	
	override init() {
		super.init()
		
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
	}
	
	func buyProduct(product: SKProduct) {
		println("Sending the Payment Request to Apple")
		var payment = SKPayment(product: product)
		SKPaymentQueue.defaultQueue().addPayment(payment)
	}
	
	func restoreTransactions() {
		SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
	}
	
	func request(request: SKRequest!, didFailWithError error: NSError!) {
		println("Error %@ \(error)")
		NSNotificationCenter.defaultCenter().postNotificationName(kInAppPurchasingErrorNotification, object: error.description)
	}
	
	func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
		println("Got the request from Apple")
		var count: Int = response.products.count
		if count > 0 {
			var validProducts = response.products
			var validProduct: SKProduct = response.products[0] as! SKProduct
			println(validProduct.localizedTitle)
			println(validProduct.localizedDescription)
			println(validProduct.price)
			buyProduct(validProduct);
		}
		else {
			println("No products")
		}
	}
	
	func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
		println("Received Payment Transaction Response from Apple");
		
		for transaction: AnyObject in transactions {
			if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction {
				switch trans.transactionState {
				case .Purchased:
					println("Product Purchased")
					savePurchasedProductIdentifier(trans.payment.productIdentifier)
					SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
					NSNotificationCenter.defaultCenter().postNotificationName(kInAppProductPurchasedNotification, object: nil)
					break
					
				case .Failed:
					println("Purchased Failed")
					SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
					NSNotificationCenter.defaultCenter().postNotificationName(kInAppPurchaseFailedNotification, object: nil)
					break
					
				case .Restored:
					println("Product Restored")
					savePurchasedProductIdentifier(trans.payment.productIdentifier)
					SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
					NSNotificationCenter.defaultCenter().postNotificationName(kInAppProductRestoredNotification, object: nil)
					break
					
				default:
					break
				}
			}
		}
	}
	
	func savePurchasedProductIdentifier(productIdentifier: String!) {
		NSUserDefaults.standardUserDefaults().setObject(productIdentifier, forKey: productIdentifier)
		NSUserDefaults.standardUserDefaults().synchronize()
	}
	
	func unlockProduct(productIdentifier: String!) {
		if SKPaymentQueue.canMakePayments() {
			var productID: NSSet = NSSet(object: productIdentifier)
			var productsRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as Set<NSObject>)
			productsRequest.delegate = self
			productsRequest.start()
			println("Fething Products")
		}
		else {
			println("Сan't make purchases")
			NSNotificationCenter.defaultCenter().postNotificationName(kInAppPurchasingErrorNotification, object: NSLocalizedString("CANT_MAKE_PURCHASES", comment: "Can't make purchases"))
		}
	}
	
	func buyUnlockTestInAppPurchase1() {
		unlockProduct(unlockTestInAppPurchase1ProductId)
	}
	
	func buyUnlockTestInAppPurchase2() {
		unlockProduct(unlockTestInAppPurchase2ProductId)
	}
}
