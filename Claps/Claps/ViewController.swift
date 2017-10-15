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
    }
}

extension ViewController: ClapsViewDelegate {
    func clapsViewStateChanged(clapsView: ClapsView, state: ClapsViewStates, totalClaps: Int, currentClaps: Int) {
        if state == .finalized {
            print("ClapsViewTag: \(clapsView.tag) | Total Claps:\(totalClaps) | Current Claps:\(currentClaps)")
        }
    }
}
