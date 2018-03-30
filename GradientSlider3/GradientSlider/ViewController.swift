//
//  ViewController.swift
//  GradientSlider
//
//  Created by Jonathan Hull on 8/5/15.
//  Copyright © 2015 Jonathan Hull. All rights reserved.
//
//  Updated to Swift 3.2 by Brad Dowling

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var brightnessSlider: GradientSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        hueSlider.actionBlock = {slider,newValue in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.brightnessSlider.maxColor = UIColor(hue: newValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            slider.thumbColor = UIColor(hue: newValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            CATransaction.commit()
        }
        
        hueSlider.thumbColor = UIColor(hue: 0.5, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

