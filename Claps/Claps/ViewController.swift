//
//  ViewController.swift
//  Claps
//
//  Created by Hemang Shah on 8/17/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

let kClapsForImageView = "kClapsForImageView"

class ViewController: UIViewController {
    
    @IBOutlet var clapsView: ClapsView!
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.webView.loadRequest(URLRequest.init(url: URL.init(string: "https://blog.medium.com/show-authors-more-%EF%B8%8F-with-s-c1652279ba01")!))
        self.loadPreviousClaps(forClapsView: self.clapsView)
        self.clapsView.finalizeClaps()
    }
    
    //MARK: Handle Claps.
    //In live apps, generally this should be handle using the server.
    fileprivate func loadPreviousClaps(forClapsView clapsView: ClapsView) {
        //Here instead of user defaults, you can load the claps by a user which is stored on your server.
        let defaults = UserDefaults.standard
        if let claps = defaults.value(forKey: getKeyForClapsView(forClapsView: clapsView)) {
            clapsView.currentClaps = claps as! Int
        }
    }
    
    fileprivate func saveClapsForClapsView(clapsView: ClapsView, withClaps claps: Int) {
        //Here instead of user defaults to save a user claps, you can store it to the server.
        let defaults = UserDefaults.standard
        defaults.set(claps, forKey: getKeyForClapsView(forClapsView: clapsView))
        defaults.synchronize()
    }
    
    fileprivate func getKeyForClapsView(forClapsView clapsView: ClapsView) -> String {
        return "\(kClapsForImageView)\(clapsView.tag)"
    }
}

extension ViewController: ClapsViewDelegate {
    func clapsViewStateChanged(clapsView: ClapsView, state: ClapsViewStates, totalClaps: Int, currentClaps: Int) {
        if state == .finalized {
            print("ClapsViewTag: \(clapsView.tag) | Total Claps:\(totalClaps) | Current Claps:\(currentClaps)")
            self.saveClapsForClapsView(clapsView: clapsView, withClaps: currentClaps)
        }
    }
}
