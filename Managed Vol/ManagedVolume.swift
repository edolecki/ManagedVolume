//
//  ManagedVolume.swift
//  Managed Volume
//
//  Created by Eric Dolecki on 3/23/16.
//  Copyright © 2016 Eric Dolecki. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension UIColor {
    func inverse () -> UIColor {
        var r:CGFloat = 0.0; var g:CGFloat = 0.0; var b:CGFloat = 0.0; var a:CGFloat = 0.0;
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: 1.0-r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
        }
        return self
    }
}

enum Shade {
    case Silver, Salmon, Crimson, PaleGold, SkyBlue, Tomato, Blush
    func color() -> UIColor {
        switch self {
        case .Salmon:
            return UIColor(netHex: 0xfa8072)
        case .Silver:
            return UIColor(netHex: 0xc0c0c0)
        case .Crimson:
            return UIColor(netHex: 0xdc143c)
        case .PaleGold:
            return UIColor(netHex: 0xeee8aa)
        case .SkyBlue:
            return UIColor(netHex: 0x87ceeb)
        case .Tomato:
            return UIColor(netHex: 0xff6347)
        case .Blush:
            return UIColor(netHex: 0xfff0f5)
        }
    }
}

@objc protocol ManagedVolumeDelegate {
    optional func volumeUpdated( val:Float, sender:ManagedVolume )
}

class ManagedVolume: UIView
{
    var delegate:ManagedVolumeDelegate?
    var mySlider: UISlider!
    var volLabel: UILabel!
    var darkRule: UIView!
    var myIcon: UIImageView!
    var myFrame: CGRect!
    var currentVolume: Float!
    var myMaxVolume: Float!
    var myMinVolume: Float!
    var myTint = UIColor.whiteColor()
    var fadeTimer: NSTimer!
    
    override init( frame: CGRect ) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init( frame:CGRect, initialVolume:Float, minVolume: Float, maxVolume: Float, tint: UIColor ) {
        super.init(frame: frame)
        myFrame = frame
        currentVolume = initialVolume
        myMaxVolume = maxVolume
        myMinVolume = minVolume
        myTint = tint
        
        mySlider = UISlider(frame: CGRect(x: 80,
            y: 0,
            width: myFrame.width - 90,
            height: myFrame.height))
        mySlider.center = CGPoint(x: mySlider.center.x, y: myFrame.height / 2)
        mySlider.addTarget(self, action: #selector(self.sliderChanged(_:)), forControlEvents: .ValueChanged)
        
        let img = UIImage(named: "kalmThumb.png")
        mySlider.setThumbImage(img, forState: .Normal)
        
        mySlider.maximumValue = myMaxVolume
        mySlider.minimumValue = myMinVolume
        mySlider.maximumTrackTintColor = UIColor(netHex: 0xFFFFFF)
        mySlider.minimumTrackTintColor = UIColor(netHex: 0xFFFFFF)
        mySlider.value = currentVolume
        
        darkRule = UIView(frame: CGRect(x: 45, y: 0, width: 33, height: 2))
        darkRule.backgroundColor = UIColor(netHex: 0x888888)
        darkRule.center = CGPoint(x: darkRule.center.x, y: myFrame.height / 2)
        
        myIcon = UIImageView(frame: CGRect(x: 8, y: 0, width: 30, height: 30))
        myIcon.center = CGPoint(x: myIcon.center.x, y: myFrame.height / 2)
        myIcon.image = evaluateVolumeLevel(currentVolume)
        myIcon.tintColor = myTint
        
        volLabel = UILabel(frame: CGRect(x: 11, y: 0, width: 24, height: 24))
        volLabel.center = myIcon.center
        volLabel.textColor = myTint.inverse()
        //volLabel.textColor = myTint.complementaryColor()
        
        volLabel.backgroundColor = myTint.colorWithAlphaComponent(0.9)
        volLabel.layer.cornerRadius = volLabel.frame.width / 2
        volLabel.layer.masksToBounds = true
        volLabel.textAlignment = .Center
        volLabel.font = UIFont.systemFontOfSize(10)
        volLabel.alpha = 0.0
        volLabel.text = "\(Int(currentVolume * 100))"
        
        self.addSubview( darkRule )
        self.addSubview( mySlider )
        self.addSubview( myIcon )
        self.addSubview( volLabel )
    }
    
    func changeTint( val:UIColor ){
        myTint = val
        myIcon.tintColor = myTint
    }
    
    func sliderChanged( sender:UISlider ){
        let val = sender.value
        currentVolume = val
        myIcon.image = evaluateVolumeLevel( val )
        myIcon.tintColor = myTint
        delegate?.volumeUpdated!( currentVolume, sender: self )
        volLabel.text = "\(Int(currentVolume * 100))"
        UIView.animateWithDuration(0.4, delay: 0.0, options: [.CurveEaseOut], animations: {
            self.volLabel.alpha = 1.0
            if self.fadeTimer != nil {
                self.fadeTimer.invalidate()
                self.fadeTimer = nil
            }
            }, completion: {
                (finished: Bool) -> Void in
                self.fadeTimer = NSTimer.scheduledTimerWithTimeInterval(2.5,
                    target: self,
                    selector: #selector(self.fadeDone),
                    userInfo: nil,
                    repeats: false)
        })
    }
    
    func fadeDone(){
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.CurveEaseIn], animations: {
            self.volLabel.alpha = 0.0
            }, completion: {
                (finished: Bool) -> Void in
        })
    }
    
    func evaluateVolumeLevel( val:Float ) -> UIImage
    {
        var returnImage:UIImage!
        
        let first = myMaxVolume / 3 + 0.05
        let second = first * 2
        let third = first * 3
        if val < first {
            returnImage = UIImage(named: "volMin.png")!
        } else if val < second {
            returnImage = UIImage(named: "volMed.png")!
        } else if val < third {
            returnImage = UIImage(named: "volMax.png")!
        } else {
            returnImage = UIImage(named: "volMax.png")!
        }
        let tintedImage = returnImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        return tintedImage!
    }
}