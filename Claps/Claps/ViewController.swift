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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Comment below line to see ClapsView created in UIStoryboard.
        self.addImages()
    }

    fileprivate func addImages() {
        let scrollView = UIScrollView.init(frame: CGRect.init(origin: CGPoint.zero, size: UIScreen.main.bounds.size))
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        scrollView.autoresizesSubviews = true
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = true
        self.view.addSubview(scrollView)
        
        let images = [UIImage.init(named: "1.jpg"), UIImage.init(named: "2.jpg"), UIImage.init(named: "3.jpg"), UIImage.init(named: "4.jpg"), UIImage.init(named: "5.jpg")]
        
        var originX: CGFloat = 0.0
        let originY: CGFloat = 0.0
        
        let imageViewWidth = scrollView.frame.size.width
        let imageViewHeight = scrollView.frame.size.height
        
        let margin: CGFloat = 20.0
        let size: CGFloat = 100.0
        var clapsViewTag = 1
        
        for image in images {
            
            //Adding UIImageView
            let imageView = UIImageView.init(frame: CGRect.init(origin: CGPoint.init(x: originX, y: originY), size: CGSize.init(width: imageViewWidth, height: imageViewHeight)))
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            scrollView.addSubview(imageView)
            
            //Adding ClapsView
            let claps = ClapsView.init(frame: CGRect.init(origin: CGPoint.init(x: originX + margin, y: imageViewHeight - (size + margin)), size: CGSize.init(width: size, height: size)))
            claps.delegate = self
            //Emoji to be used with ClapsView.
            claps.emoji = "👋"
            //The number of claps by all of the user.
            claps.totalClaps = 30
            //The maximum number of claps a user can do.
            claps.maxClaps = 50
            //If set true, 1000 claps will be display as 1k
            claps.showClapsAbbreviated = true
            claps.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            //Tag for the identification.
            claps.tag = clapsViewTag
            scrollView.addSubview(claps)
            //If there are any claps it will be visible to user.
            //The same behavior can be achieved by tapping on a ClapsView.
            claps.finalizeClaps()

            //Loading Previous Claps for the ClapsView.
            loadPreviousClaps(forClapsView: claps)

            clapsViewTag = clapsViewTag + 1
            originX = originX + scrollView.frame.size.width
        }
        scrollView.contentSize = CGSize.init(width: CGFloat(images.count) * imageViewWidth, height: imageViewHeight)
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
            saveClapsForClapsView(clapsView: clapsView, withClaps: currentClaps)
        }
    }
}
