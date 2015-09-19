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
		print("Sending the Payment Request to Apple")
		let payment = SKPayment(product: product)
		SKPaymentQueue.defaultQueue().addPayment(payment)
	}
	
	func restoreTransactions() {
		SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
	}
	
	func request(request: SKRequest, didFailWithError error: NSError) {
		print("Error %@ \(error)")
		NSNotificationCenter.defaultCenter().postNotificationName(kInAppPurchasingErrorNotification, object: error.description)
	}
	
	func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
		print("Got the request from Apple")
		let count: Int = response.products.count
		if count > 0 {
			_ = response.products
			let validProduct: SKProduct = response.products[0] 
			print(validProduct.localizedTitle)
			print(validProduct.localizedDescription)
			print(validProduct.price)
			buyProduct(validProduct);
		}
		else {
			print("No products")
		}
	}
	
	func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		print("Received Payment Transaction Response from Apple");
		
		for transaction: AnyObject in transactions {
			if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction {
				switch trans.transactionState {
				case .Purchased:
					print("Product Purchased")
					savePurchasedProductIdentifier(trans.payment.productIdentifier)
					SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
					NSNotificationCenter.defaultCenter().postNotificationName(kInAppProductPurchasedNotification, object: nil)
					break
					
				case .Failed:
					print("Purchased Failed")
					SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
					NSNotificationCenter.defaultCenter().postNotificationName(kInAppPurchaseFailedNotification, object: nil)
					break
					
				case .Restored:
					print("Product Restored")
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
			let productID: NSSet = NSSet(object: productIdentifier)
			let productsRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
			productsRequest.delegate = self
			productsRequest.start()
			print("Fething Products")
		}
		else {
			print("Сan't make purchases")
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
