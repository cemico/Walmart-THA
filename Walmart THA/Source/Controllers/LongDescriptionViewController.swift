//
//  LongDescriptionViewController.swift
//  Walmart THA
//
//  Created by Dave Rogers on 10/4/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit
import WebKit

class LongDescriptionViewController: UIViewController {

    ///////////////////////////////////////////////////////////
    // outlets
    ///////////////////////////////////////////////////////////

    @IBOutlet weak var titleLabelView: UILabel!
    @IBOutlet weak var textView: UITextView!

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    var productItem: ProductItem? = nil

//    var longDescription: String?

//    let viewportScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"
//    let disableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
//    let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"

    ///////////////////////////////////////////////////////////
    // overrides
    ///////////////////////////////////////////////////////////

    override func viewDidLoad() {
        super.viewDidLoad()

//        // load up our html long description
//        if let longDescription = longDescription {

//            // 1 - Make user scripts for injection
//            let viewportScript = WKUserScript(source: viewportScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//            let disableSelectionScript = WKUserScript(source: disableSelectionScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//            let disableCalloutScript = WKUserScript(source: disableCalloutScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//
//            // 2 - Initialize a user content controller
//            // From docs: "provides a way for JavaScript to post messages and inject user scripts to a web view."
//            let controller = WKUserContentController()
//
//            // 3 - Add scripts
//            controller.addUserScript(viewportScript)
//            controller.addUserScript(disableSelectionScript)
//            controller.addUserScript(disableCalloutScript)
//
//            // 4 - Initialize a configuration and set controller
//            let config = WKWebViewConfiguration()
//            config.userContentController = controller
//
//            // 5 - Initialize webview with configuration
//            let webView = WKWebView(frame: view.bounds, configuration: config)
//            view.addSubview(webView)
//
//            // 6 - Webview options
//            webView.scrollView.isScrollEnabled = true               // Make sure our view is interactable
//            webView.scrollView.bounces = false                    // Things like this should be handled in web code
//            webView.allowsBackForwardNavigationGestures = false   // Disable swiping to navigate
//            webView.contentMode = .scaleToFill                    // Scale the page to fill the web view
//
////            let html = "<html><body bgcolor=red><font size=4><p>\(longDescription)</p></font></body></html>"
//            let html = "<html><body bgcolor=red><p><h1>\(longDescription)</h1></p></body></html>"
//            webView.loadHTMLString(html, baseURL: nil)
//        }

        if let productItem = productItem {

            // set name
            titleLabelView.text = productItem.name.withoutUnicodeChars

            // set details
            textView.attributedText = productItem.longDescription.html2AttributedString
//            textView.text = productItem.longDescription
        }
    }
}
