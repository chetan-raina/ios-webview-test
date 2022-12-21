import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    var webView: WKWebView!
    
    override func loadView() {
        let userController = WKUserContentController()
        userController.add(self, name: "hyperfaceIosBridge")
        
        // set variables in window object for the web app to use
        let script = """
            window.hyperfaceIosProps = {
                version: "0.1",
            };
        """
        
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        userController.addUserScript(userScript)
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userController;
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://www.google.com")!
        
        self.webView.load(URLRequest(url: url))
        self.webView.allowsBackForwardNavigationGestures = true
    }
    
    // receive message from wkwebview
    func userContentController( _ userContentController: WKUserContentController, didReceive message: WKScriptMessage ) {
        print("received message from webview \(message.body)")
        
        // parse message as json
        let jsonData = (message.body as! String).data(using: .utf8)!
        
        do {
            let action = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:Any] as NSDictionary?
            
//            // for nested objects
//            print("value is - \((dictionary?["a"] as! NSDictionary)["b"]!)")
            
            let cmd = action?["cmd"] as! String
            
            if (cmd == "SESSION_EXPIRED") {
                // do stuff
            }
        } catch (let error as NSError) {
            print(error)
        }
    }
    
    func messageToWebview(msg: String) {
        // has sync issues, message is sent even before browser sets callback method 'onMessage' in 'window.hyperfaceIosProps' object
        self.webView?.evaluateJavaScript("window.hyperfaceIosProps.onMessage('\(msg)')")
    }
}
