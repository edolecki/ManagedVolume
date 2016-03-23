//
//  ViewController.swift
//  Managed Volume
//
//  Created by Eric Dolecki on 3/23/16.
//  Copyright © 2016 Eric Dolecki. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ManagedVolumeDelegate {

    var mVol:   ManagedVolume!
    var mVol2:  ManagedVolume!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let salmon = Shade.SkyBlue.color()
        
        mVol = ManagedVolume(frame: CGRect(x:0, y:50, width: self.view.frame.width, height:40), initialVolume: 0.5, minVolume: 0.2, maxVolume: 1.0, tint: salmon )
        mVol.center = CGPoint(x:mVol.center.x, y:self.view.frame.height / 2)
        mVol.delegate = self
        
        mVol2 = ManagedVolume(frame: CGRect(x:0, y:100, width: self.view.frame.width, height:40), initialVolume: 0.4, minVolume: 0.4, maxVolume: 1.0, tint: UIColor.blackColor() )
        mVol2.center = CGPoint(x:mVol2.center.x, y:self.view.frame.height / 2 + 60)
        mVol2.delegate = self

        self.view.addSubview( mVol )
        self.view.addSubview( mVol2 )
    }
    
    func volumeUpdated(val: Float, sender: ManagedVolume) {
        if sender == mVol {
            print("v: \(val)")
        } else {
            print("v2: \(val)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

