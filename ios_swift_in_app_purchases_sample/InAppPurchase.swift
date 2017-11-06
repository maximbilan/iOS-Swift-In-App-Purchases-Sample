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
	
	static let sharedInstance = InAppPurchase()
	
#if DEBUG
	let verifyReceiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
#else
	let verifyReceiptURL = "https://buy.itunes.apple.com/verifyReceipt"
#endif
	
	let kInAppProductPurchasedNotification = "InAppProductPurchasedNotification"
	let kInAppPurchaseFailedNotification   = "InAppPurchaseFailedNotification"
	let kInAppProductRestoredNotification  = "InAppProductRestoredNotification"
	let kInAppPurchasingErrorNotification  = "InAppPurchasingErrorNotification"
	
	let unlockTestInAppPurchase1ProductId = "com.testing.iap1"
	let unlockTestInAppPurchase2ProductId = "com.testing.iap2"
	let autorenewableSubscriptionProductId = "com.testing.autorenewablesubscription"
	let nonrenewingSubscriptionProductId = "com.testing.nonrenewingsubscription"
	
	override init() {
		super.init()
		
		SKPaymentQueue.default().add(self)
	}
	
	func buyProduct(_ product: SKProduct) {
		print("Sending the Payment Request to Apple")
		let payment = SKPayment(product: product)
		SKPaymentQueue.default().add(payment)
	}
	
	func restoreTransactions() {
		SKPaymentQueue.default().restoreCompletedTransactions()
	}
	
	func request(_ request: SKRequest, didFailWithError error: Error) {
		print("Error %@ \(error)")
		NotificationCenter.default.post(name: Notification.Name(rawValue: kInAppPurchasingErrorNotification), object: error.localizedDescription)
	}
	
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
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
	
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		print("Received Payment Transaction Response from Apple");
		
		for transaction: AnyObject in transactions {
			if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction {
				switch trans.transactionState {
				case .purchased:
					print("Product Purchased")
					
					savePurchasedProductIdentifier(trans.payment.productIdentifier)
					SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
					NotificationCenter.default.post(name: Notification.Name(rawValue: kInAppProductPurchasedNotification), object: nil)
					
					receiptValidation()
					
					break
					
				case .failed:
					print("Purchased Failed")
					SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
					NotificationCenter.default.post(name: Notification.Name(rawValue: kInAppPurchaseFailedNotification), object: nil)
					break
					
				case .restored:
					print("Product Restored")
					savePurchasedProductIdentifier(trans.payment.productIdentifier)
					SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
					NotificationCenter.default.post(name: Notification.Name(rawValue: kInAppProductRestoredNotification), object: nil)
					break
					
				default:
					break
				}
			}
			else {
				
			}
		}
	}
	
	func savePurchasedProductIdentifier(_ productIdentifier: String!) {
		UserDefaults.standard.set(productIdentifier, forKey: productIdentifier)
		UserDefaults.standard.synchronize()
	}
	
	func receiptValidation() {
		
		let receiptFileURL = Bundle.main.appStoreReceiptURL
		let receiptData = try? Data(contentsOf: receiptFileURL!)
		let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
		let jsonDict: [String: AnyObject] = ["receipt-data" : recieptString! as AnyObject, "password" : "dab3f8e770384d99ae7dda0096529a30" as AnyObject]
		
		do {
			let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
			let storeURL = URL(string: verifyReceiptURL)!
			var storeRequest = URLRequest(url: storeURL)
			storeRequest.httpMethod = "POST"
			storeRequest.httpBody = requestData
			
			let session = URLSession(configuration: URLSessionConfiguration.default)
			let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in

				do {
					let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
					print(jsonResponse)
					if let date = self?.getExpirationDateFromResponse(jsonResponse as! NSDictionary) {
						print(date)
					}
				} catch let parseError {
					print(parseError)
				}
			})
			task.resume()
		} catch let parseError {
			print(parseError)
		}
	}
	
	func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
		
		if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {

			let lastReceipt = receiptInfo.lastObject as! NSDictionary
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
			
			if let expiresDate = lastReceipt["expires_date"] as? String {
				let expirationDate: Date = formatter.date(from: expiresDate) as Date!
				return expirationDate
			}
			
			return nil
		}
		else {
			return nil
		}
	}
	
	func unlockProduct(_ productIdentifier: String!) {
		if SKPaymentQueue.canMakePayments() {
			let productID: NSSet = NSSet(object: productIdentifier)
			let productsRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
			productsRequest.delegate = self
			productsRequest.start()
			print("Fetching Products")
		}
		else {
			print("Сan't make purchases")
			NotificationCenter.default.post(name: Notification.Name(rawValue: kInAppPurchasingErrorNotification), object: NSLocalizedString("CANT_MAKE_PURCHASES", comment: "Can't make purchases"))
		}
	}
	
	func buyUnlockTestInAppPurchase1() {
		unlockProduct(unlockTestInAppPurchase1ProductId)
	}
	
	func buyUnlockTestInAppPurchase2() {
		unlockProduct(unlockTestInAppPurchase2ProductId)
	}

	func buyAutorenewableSubscription() {
		unlockProduct(autorenewableSubscriptionProductId)
	}
	
	func buyNonrenewingSubscription() {
		unlockProduct(nonrenewingSubscriptionProductId)
	}
	
}
