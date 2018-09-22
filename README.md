# iOS Swift In-App-Purchases

I would like to tell how to create a simple application with in-app-purchases using <i>Swift</i>.

First of all you need to create product IDs in <i><a href="http://itunesconnect.apple.com">iTunes Connect</a></i> for your application.

![alt tag](https://raw.github.com/maximbilan/ios_swift_in_app_purchases_sample/master/img/img2.png)
![alt tag](https://raw.github.com/maximbilan/ios_swift_in_app_purchases_sample/master/img/img1.png)

Lets create a class <i>InAppPurchase</i>. Inherited from the following protocols:

<pre>
class InAppPurchase : NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver
</pre>

<i>InAppPurchase</i> class will be singleton, for easy management of purchases.

<pre>
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
</pre>

Add some constants for notifications:

<pre>
let kInAppProductPurchasedNotification = "InAppProductPurchasedNotification"
let kInAppPurchaseFailedNotification   = "InAppPurchaseFailedNotification"
let kInAppProductRestoredNotification  = "InAppProductRestoredNotification"
let kInAppPurchasingErrorNotification  = "InAppPurchasingErrorNotification"
</pre>

And for product IDs:

<pre>
let unlockTestInAppPurchase1ProductId = "com.testing.iap1"
let unlockTestInAppPurchase2ProductId = "com.testing.iap2"
</pre>

In the initialization of class, we need to add a observer:

<pre>
SKPaymentQueue.defaultQueue().addTransactionObserver(self)
</pre>

For starting of making purchase, we need to run a product request:

<pre>
if SKPaymentQueue.canMakePayments() {
    let productID: NSSet = NSSet(object: productIdentifier)
    let productsRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
    productsRequest.delegate = self
    productsRequest.start()
}
else {
    print(“Сan’t make purchases”)
}
</pre>

After that if is it a success, will be called:

<pre>
func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
    var count: Int = response.products.count
    if count > 0 {
        let validProduct: SKProduct = response.products[0] as! SKProduct
        buyProduct(validProduct)
    }
    else {
        print(“No products”)
    }
}
</pre>

If error:

<pre>
func request(request: SKRequest!, didFailWithError error: NSError!) {
    print("Error %@ \(error)")
}
</pre>

In the <i>buyProduct</i> method we need to add a payment to payment queue:

<pre>
let payment = SKPayment(product: product)
SKPaymentQueue.defaultQueue().addPayment(payment)
</pre>

And after that will be called <i>paymentQueue</i> callback:

<pre>
func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
    for transaction: AnyObject in transactions {
        if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction {
            switch trans.transactionState {
                case .Purchased:
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                break
 
                case .Failed:
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                break

                case .Restored:
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                break
           
                default:
                break
        }
    }
}
</pre>

If you did everything right, you should see the similar:

![alt tag](https://raw.github.com/maximbilan/ios_swift_in_app_purchases_sample/master/img/img3.png)
![alt tag](https://raw.github.com/maximbilan/ios_swift_in_app_purchases_sample/master/img/img4.png)
![alt tag](https://raw.github.com/maximbilan/ios_swift_in_app_purchases_sample/master/img/img5.png)

For testing the app, please use sandbox accounts, which you can create in <a href="http://itunesconnect.apple.com">iTunes Connect</a>.

For updating UI in your application in the example I use notifications, and for checking if already unlocked purchases or not, I use <i>NSUserDefaults</i>.

Please see the full sample in this repository, feel free to use and don’t forget to like the repository :) Thanks for attention.
