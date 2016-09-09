//
//  NJKWebViewProgressView.swift
//  CommonWKWebView
//
//  Created by 姚凤 on 16/9/8.
//  Copyright © 2016年 姚凤. All rights reserved.
//

import UIKit

class WEWebViewProgressView: UIView {

    var progress : CGFloat{
        set{
            self .setProgressWithAnimated(progress: newValue, animated: false)
        }
        get{
            return self.progress
        }
    }
    var progressBarView = UIView()
    var barAnimationDuration : TimeInterval = 0.1
    var fadeAnimationDuration : TimeInterval = 0.27
    var fadeOutDelay : TimeInterval = 0.1
    
    private var gradientLayer = CAGradientLayer()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
// MARK: 此处UIViewAutoresizing 要调整
    func configureViews() {
        self.isUserInteractionEnabled = false
        self.autoresizingMask = .flexibleWidth
        self.progressBarView = UIView.init(frame: self.bounds)
        self.progressBarView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        var tintColor = UIColor.init(colorLiteralRed: 22.0 / 255.0, green: 126.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)
        gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = progressBarView.bounds
        gradientLayer.colors = [tintColor.cgColor,UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint.zero
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0)
        progressBarView.layer.addSublayer(gradientLayer)
        
        if (UIApplication.shared.delegate?.window??.responds(to: #selector(setter: UIView.tintColor)))! && UIApplication.shared.delegate?.window??.tintColor != nil {
            tintColor = (UIApplication.shared.delegate?.window??.tintColor)!
        }
        
        progressBarView.backgroundColor = tintColor
        self.addSubview(progressBarView)
        
    }

    func setProgressWithAnimated(progress: CGFloat ,animated: Bool) {
        let isGrowing = progress>0.0
        UIView.animate(withDuration: (isGrowing && animated) ? barAnimationDuration: 0.0, delay: 0, options: .curveEaseInOut, animations: { 
            
            var frame = self.progressBarView.frame;
            frame.size.width = progress * self.bounds.size.width
            self.progressBarView.frame = frame
            self.gradientLayer.frame = frame
            
            }) { (value) in
                
        }
        
        if progress>=1.0 {
            UIView.animate(withDuration: animated ? fadeAnimationDuration : 0.0, delay: fadeOutDelay, options: .curveEaseInOut, animations: { 
                self.progressBarView.alpha = 0.0
                }, completion: { (completed: Bool) in
                    var frame = self.progressBarView.frame;
                    frame.size.width = 0
                    self.progressBarView.frame = frame
                    self.gradientLayer.frame = frame
            })
        }else{
            UIView.animate(withDuration: animated ? fadeAnimationDuration : 0.0, delay: 0.0, options: .curveEaseInOut, animations: { 
                self.progressBarView.alpha = 1.0
                }, completion: { (value) in
    
            })
        }
    }

}
