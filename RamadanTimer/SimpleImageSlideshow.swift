//
//  SimpleImageSlideshow.swift
//  RamadanTimer
//
//  Created by Sumayyah on 19/06/17.
//  Copyright © 2017 Sumayyah. All rights reserved.
//

import UIKit

class SimpleImageSlideshow: UIView {

    @IBOutlet var imageView: UIImageView!
    private var timer = Timer()
    
    /// number of seconds to show each image
    var imageDuration  = 1.0
    /// the images to show
    var images = [UIImage]()
    /// the index of the displayed image
    var currentIndex: Int = 0
    
    /// view can be dragged around in superview, default = true
    var draggable = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /// setup the view
    func setup() {
        layer.cornerRadius = 6
        clipsToBounds = true
        if draggable {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView))
            isUserInteractionEnabled = true
            addGestureRecognizer(panGesture)
        }
    }
    
    @objc func draggedView(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.superview)
    }
    
    @objc func transition() {
        if images.count > 2 {
            var nextIndex = currentIndex + 1
            if nextIndex == images.count {
                nextIndex = 0
            }
            let nextImage = images[nextIndex]
            UIView.transition(with: imageView,
                              duration: 0.8,
                              options: .transitionCrossDissolve,
                              animations: { self.imageView.image = nextImage },
                              completion: nil)
            currentIndex = nextIndex
        }
    }
    
    func startSlideshow() {
        imageView.image = images.first
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: imageDuration, target: self, selector: #selector(transition), userInfo: nil, repeats: true)
    }
}
