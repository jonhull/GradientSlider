//
//  GradientSlider.swift
//  GradientSlider
//
//  Created by Jonathan Hull on 8/5/15.
//  Copyright © 2015 Jonathan Hull. All rights reserved.
//

import UIKit

@IBDesignable class GradientSlider: UIControl {
    
    static var defaultThickness:CGFloat = 2.0
    static var defaultThumbSize:CGFloat = 28.0
    
    //MARK: Properties
    @IBInspectable var hasRainbow:Bool  = false {didSet{updateTrackColors()}}//Uses saturation & lightness from minColor
    @IBInspectable var minColor:UIColor = UIColor.blueColor() {didSet{updateTrackColors()}}
    @IBInspectable var maxColor:UIColor = UIColor.orangeColor() {didSet{updateTrackColors()}}
    
    @IBInspectable var value: CGFloat {
        get{return _value}
        set{setValue(newValue, animated:true)}
    }
    
    func setValue(value:CGFloat, animated:Bool = true) {
        _value = max(min(value,self.maximumValue),self.minimumValue)
        updateThumbPosition(animated: animated)
    }
    
    @IBInspectable var minimumValue: CGFloat = 0.0 // default 0.0. the current value may change if outside new min value
    @IBInspectable var maximumValue: CGFloat = 1.0 // default 1.0. the current value may change if outside new max value
    
    @IBInspectable var minimumValueImage: UIImage? = nil { // default is nil. image that appears to left of control (e.g. speaker off)
        didSet{
            if let img = minimumValueImage {
                let imgLayer = _minTrackImageLayer ?? {
                    let l = CALayer()
                    l.anchorPoint = CGPointMake(0.0, 0.5)
                    self.layer.addSublayer(l)
                    return l
                }()
                imgLayer.contents = img.CGImage
                imgLayer.bounds = CGRectMake(0, 0, img.size.width, img.size.height)
                _minTrackImageLayer = imgLayer
                    
            }else{
                _minTrackImageLayer?.removeFromSuperlayer()
                _minTrackImageLayer = nil
            }
            self.layer.needsLayout()
        }
    }
    @IBInspectable var maximumValueImage: UIImage? = nil { // default is nil. image that appears to right of control (e.g. speaker max)
        didSet{
            if let img = maximumValueImage {
                let imgLayer = _maxTrackImageLayer ?? {
                    let l = CALayer()
                    l.anchorPoint = CGPointMake(1.0, 0.5)
                    self.layer.addSublayer(l)
                    return l
                    }()
                imgLayer.contents = img.CGImage
                imgLayer.bounds = CGRectMake(0, 0, img.size.width, img.size.height)
                _maxTrackImageLayer = imgLayer
                
            }else{
                _maxTrackImageLayer?.removeFromSuperlayer()
                _maxTrackImageLayer = nil
            }
            self.layer.needsLayout()
        }
    }
    
    var continuous: Bool = true // if set, value change events are generated any time the value changes due to dragging. default = YES
    
    var actionBlock:(GradientSlider,CGFloat)->() = {slider,newValue in }
    
    @IBInspectable var thickness:CGFloat = defaultThickness {
        didSet{
            _trackLayer.cornerRadius = thickness / 2.0
            self.layer.setNeedsLayout()
        }
    }
    
    var trackBorderColor:UIColor? {
        set{
            _trackLayer.borderColor = newValue?.CGColor
        }
        get{
            if let color = _trackLayer.borderColor {
                return UIColor(CGColor: color)
            }
            return nil
        }
    }
    
    var trackBorderWidth:CGFloat {
        set{
            _trackLayer.borderWidth = newValue
        }
        get{
            return _trackLayer.borderWidth
        }
    }
    
    var thumbSize:CGFloat = defaultThumbSize {
        didSet{
            _thumbLayer.cornerRadius = thumbSize / 2.0
            _thumbLayer.bounds = CGRectMake(0, 0, thumbSize, thumbSize)
            self.invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var thumbIcon:UIImage? = nil {
        didSet{
            _thumbIconLayer.contents = thumbIcon?.CGImage
        }
    }
    
    var thumbColor:UIColor {
        get {
            if let color = _thumbIconLayer.backgroundColor {
                return UIColor(CGColor: color)
            }
            return UIColor.whiteColor()
        }
        set {
            _thumbIconLayer.backgroundColor = newValue.CGColor
            thumbIcon = nil
        }
    }
    
    //MARK: - Convienience Colors
    
    func setGradientForHueWithSaturation(saturation:CGFloat,brightness:CGFloat){
        minColor = UIColor(hue: 0.0, saturation: saturation, brightness: brightness, alpha: 1.0)
        hasRainbow = true
    }
    
    func setGradientForSaturationWithHue(hue:CGFloat,brightness:CGFloat){
        hasRainbow = false
        minColor = UIColor(hue: hue, saturation: 0.0, brightness: brightness, alpha: 1.0)
        maxColor = UIColor(hue: hue, saturation: 1.0, brightness: brightness, alpha: 1.0)
    }
    
    func setGradientForBrightnessWithHue(hue:CGFloat,saturation:CGFloat){
        hasRainbow = false
        minColor = UIColor.blackColor()
        maxColor = UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)
    }
    
    func setGradientForRedWithGreen(green:CGFloat,blue:CGFloat){
        hasRainbow = false
        minColor = UIColor(red: 0.0, green: green, blue: blue, alpha: 1.0)
        maxColor = UIColor(red: 1.0, green: green, blue: blue, alpha: 1.0)
    }
    
    func setGradientForGreenWithRed(red:CGFloat,blue:CGFloat){
        hasRainbow = false
        minColor = UIColor(red: red, green: 0.0, blue: blue, alpha: 1.0)
        maxColor = UIColor(red: red, green: 1.0, blue: blue, alpha: 1.0)
    }
    
    func setGradientForBlueWithRed(red:CGFloat,green:CGFloat){
        hasRainbow = false
        minColor = UIColor(red: red, green: green, blue: 0.0, alpha: 1.0)
        maxColor = UIColor(red: red, green: green, blue: 1.0, alpha: 1.0)
    }
    
    func setGradientForGrayscale(){
        hasRainbow = false
        minColor = UIColor.blackColor()
        maxColor = UIColor.whiteColor()
    }
    
    
    //MARK: - Private Properties
    
    private var _value:CGFloat = 0.0 // default 0.0. this value will be pinned to min/max
    
    private var _thumbLayer:CALayer = {
        let thumb = CALayer()
        thumb.cornerRadius = defaultThumbSize/2.0
        thumb.bounds = CGRectMake(0, 0, defaultThumbSize, defaultThumbSize)
        thumb.backgroundColor = UIColor.whiteColor().CGColor
        thumb.shadowColor = UIColor.blackColor().CGColor
        thumb.shadowOffset = CGSizeMake(0.0, 2.5)
        thumb.shadowRadius = 2.0
        thumb.shadowOpacity = 0.25
        thumb.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.15).CGColor
        thumb.borderWidth = 0.5
        return thumb
    }()
    
    private var _trackLayer:CAGradientLayer = {
        let track = CAGradientLayer()
        track.cornerRadius = defaultThickness / 2.0
        track.startPoint = CGPointMake(0.0, 0.5)
        track.endPoint = CGPointMake(1.0, 0.5)
        track.locations = [0.0,1.0]
        track.colors = [UIColor.blueColor().CGColor,UIColor.orangeColor().CGColor]
        track.borderColor = UIColor.blackColor().CGColor
        return track
    }()
    
    private var _minTrackImageLayer:CALayer? = nil
    private var _maxTrackImageLayer:CALayer? = nil
    
    private var _thumbIconLayer:CALayer = {
        let size = defaultThumbSize - 4
        let iconLayer = CALayer()
        iconLayer.cornerRadius = size/2.0
        iconLayer.bounds = CGRectMake(0, 0, size, size)
        iconLayer.backgroundColor = UIColor.whiteColor().CGColor
        return iconLayer
    }()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        minColor = aDecoder.decodeObjectForKey("minColor") as? UIColor ?? UIColor.lightGrayColor()
        maxColor = aDecoder.decodeObjectForKey("maxColor") as? UIColor ?? UIColor.darkGrayColor()
        
        value = aDecoder.decodeObjectForKey("value") as? CGFloat ?? 0.0
        minimumValue = aDecoder.decodeObjectForKey("minimumValue") as? CGFloat ?? 0.0
        maximumValue = aDecoder.decodeObjectForKey("maximumValue") as? CGFloat ?? 1.0

        minimumValueImage = aDecoder.decodeObjectForKey("minimumValueImage") as? UIImage
        maximumValueImage = aDecoder.decodeObjectForKey("maximumValueImage") as? UIImage
        
        thickness = aDecoder.decodeObjectForKey("thickness") as? CGFloat ?? 2.0
        
        thumbIcon = aDecoder.decodeObjectForKey("thumbIcon") as? UIImage
        
        commonSetup()
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
        aCoder.encodeObject(minColor, forKey: "minColor")
        aCoder.encodeObject(maxColor, forKey: "maxColor")
        
        aCoder.encodeObject(value, forKey: "value")
        aCoder.encodeObject(minimumValue, forKey: "minimumValue")
        aCoder.encodeObject(maximumValue, forKey: "maximumValue")
        
        aCoder.encodeObject(minimumValueImage, forKey: "minimumValueImage")
        aCoder.encodeObject(maximumValueImage, forKey: "maximumValueImage")
        
        aCoder.encodeObject(thickness, forKey: "thickness")
        
        aCoder.encodeObject(thumbIcon, forKey: "thumbIcon")
        
    }
    
    private func commonSetup() {
        self.layer.delegate = self
        self.layer.addSublayer(_trackLayer)
        self.layer.addSublayer(_thumbLayer)
        _thumbLayer.addSublayer(_thumbIconLayer)
    }
    
    //MARK: - Layout
    
    override func intrinsicContentSize()->CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: thumbSize)
    }
    
    override func alignmentRectInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(4.0, 2.0, 4.0, 2.0)
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
//        super.layoutSublayersOfLayer(layer)
        
        if layer != self.layer {return}
        
        var w = self.bounds.width
        let h = self.bounds.height
        var left:CGFloat = 2.0
        
        if let minImgLayer = _minTrackImageLayer {
            minImgLayer.position = CGPointMake(0.0, h/2.0)
            left = minImgLayer.bounds.width + 13.0
        }
        w -= left
        
        if let maxImgLayer = _maxTrackImageLayer {
            maxImgLayer.position = CGPointMake(self.bounds.width, h/2.0)
            w -= (maxImgLayer.bounds.width + 13.0)
        }else{
            w -= 2.0
        }
        
        _trackLayer.bounds = CGRectMake(0, 0, w, thickness)
        _trackLayer.position = CGPointMake(w/2.0 + left, h/2.0)
        
        let halfSize = thumbSize/2.0
        var layerSize = thumbSize - 4.0
        if let icon = thumbIcon {
            layerSize = min(max(icon.size.height,icon.size.width),layerSize)
            _thumbIconLayer.cornerRadius = 0.0
            _thumbIconLayer.backgroundColor = UIColor.clearColor().CGColor
        }else{
            _thumbIconLayer.cornerRadius = layerSize/2.0
        }
        _thumbIconLayer.position = CGPointMake(halfSize, halfSize)
        _thumbIconLayer.bounds = CGRectMake(0, 0, layerSize, layerSize)
        
        
        updateThumbPosition(animated: false)
    }
    
    
    
    //MARK: - Touch Tracking
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let pt = touch.locationInView(self)
        
        let center = _thumbLayer.position
        let diameter = max(thumbSize,44.0)
        let r = CGRectMake(center.x - diameter/2.0, center.y - diameter/2.0, diameter, diameter)
        if CGRectContainsPoint(r, pt){
            sendActionsForControlEvents(UIControlEvents.TouchDown)
            return true
        }
        return false
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let pt = touch.locationInView(self)
        let newValue = valueForLocation(pt)
        setValue(newValue, animated: false)
        if(continuous){
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
            actionBlock(self,newValue)
        }
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if let pt = touch?.locationInView(self){
            let newValue = valueForLocation(pt)
            setValue(newValue, animated: false)
        }
        actionBlock(self,_value)
        sendActionsForControlEvents([UIControlEvents.ValueChanged, UIControlEvents.TouchUpInside])

    }
    
    //MARK: - Private Functions
    
    private func updateThumbPosition(animated animated:Bool){
        let diff = maximumValue - minimumValue
        let perc = CGFloat((value - minimumValue) / diff)
        
        let halfHeight = self.bounds.height / 2.0
        let trackWidth = _trackLayer.bounds.width - thumbSize
        let left = _trackLayer.position.x - trackWidth/2.0
        
        if !animated{
            CATransaction.begin() //Move the thumb position without animations
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            _thumbLayer.position = CGPointMake(left + (trackWidth * perc), halfHeight)
            CATransaction.commit()
        }else{
            _thumbLayer.position = CGPointMake(left + (trackWidth * perc), halfHeight)
        }
    }
    
    private func valueForLocation(point:CGPoint)->CGFloat {
        
        var left = self.bounds.origin.x
        var w = self.bounds.width
        if let minImgLayer = _minTrackImageLayer {
            let amt = minImgLayer.bounds.width + 13.0
            w -= amt
            left += amt
        }else{
            w -= 2.0
            left += 2.0
        }
        
        if let maxImgLayer = _maxTrackImageLayer {
            w -= (maxImgLayer.bounds.width + 13.0)
        }else{
            w -= 2.0
        }
        
        let diff = CGFloat(self.maximumValue - self.minimumValue)
        
        let perc = max(min((point.x - left) / w ,1.0), 0.0)
        
        return (perc * diff) + CGFloat(self.minimumValue)
    }
    
    private func updateTrackColors() {
        if !hasRainbow {
            _trackLayer.colors = [minColor.CGColor,maxColor.CGColor]
            _trackLayer.locations = [0.0,1.0]
            return
        }
        //Otherwise make a rainbow with the saturation & lightness of the min color
        var h:CGFloat = 0.0
        var s:CGFloat = 0.0
        var l:CGFloat = 0.0
        var a:CGFloat = 1.0
        
        minColor.getHue(&h, saturation: &s, brightness: &l, alpha: &a)
        
        let cnt = 40
        let step:CGFloat = 1.0 / CGFloat(cnt)
        let locations:[CGFloat] = (0...cnt).map({ i in return (step * CGFloat(i))})
        _trackLayer.colors = locations.map({return UIColor(hue: $0, saturation: s, brightness: l, alpha: a).CGColor})
        _trackLayer.locations = locations
    }
}



