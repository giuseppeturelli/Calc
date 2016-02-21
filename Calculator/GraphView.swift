//
//  GraphDrawer.swift
//  Calculator
//
//  Created by Giuseppe Turelli on 12/16/15.
//  Copyright © 2015 Giuseppe Turelli. All rights reserved.
//

import UIKit

protocol GraphDataSource: class {
    func getYValueForX(x: CGFloat) -> CGFloat?
}

class GraphView: UIView {
    
    weak var dataSource: GraphDataSource?
    
    var scale: CGFloat? = 50.0 {
        didSet { setNeedsDisplay(); previousPath = nil } }
    
    var translation: CGPoint? = nil {
        didSet { setNeedsDisplay() } }
    
    var nextCenter: CGPoint? = nil {
        didSet { setNeedsDisplay() } }
    
    var lastCenter: CGPoint? = nil
    
    private var relativeCenterPerc: CGPoint? = nil
    private var previousPath: UIBezierPath? = nil
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        var previousPoint: CGPoint?
        var startX: CGFloat = 0.0
        var endX: CGFloat = self.bounds.width
        var path = UIBezierPath()
        var requestedCenter = lastCenter == nil ? convertPoint(center, fromCoordinateSpace: superview!) : lastCenter!
        
        if scale == nil {
            scale = 50.0
        }
        
        //If it exist we reuse what what drawn before and move it as requested (nextCenter or translation)
        if lastCenter != nil && previousPath != nil {
            path = previousPath!
            var requestedTranslation = CGPointZero
            
            if translation != nil {
                requestedTranslation = translation!
                requestedCenter = CGPointMake((lastCenter?.x)! + (translation?.x)!, (lastCenter?.y)! + (translation?.y)!)
                translation = nil
                nextCenter = nil
            } else {
                requestedCenter = nextCenter!
                requestedTranslation = CGPointMake((nextCenter?.x)! - (lastCenter?.x)!, (nextCenter?.y)! - (lastCenter?.y)!)
                translation = nil
                nextCenter = nil
            }
            
            let translationTransform = CGAffineTransformMakeTranslation(requestedTranslation.x, requestedTranslation.y)
            path.applyTransform(translationTransform)
            
            if requestedTranslation.x > 0.0 {
                endX = requestedTranslation.x + 1
            } else {
                startX = self.bounds.width + requestedTranslation.x - 1
                //Calculating previousPoint
            }
        }
//        if nextCenter != nil {
//            requestedCenter = nextCenter!
//        }
        
        print("Requested center X: \(requestedCenter.x) Y: \(requestedCenter.y)")
        
        let axesDrawer = AxesDrawer(contentScaleFactor: CGFloat(scale!))
        axesDrawer.drawAxesInRect(self.bounds, origin: requestedCenter, pointsPerUnit: scale!)
        
        //print("This is the start \(startX) this is the end \(endX)")
        for i in Int(startX)...Int(endX) {
            //Translate and scale x
            let x = (CGFloat(i) - requestedCenter.x) / scale!
            //Get y from data source
            let y = dataSource?.getYValueForX(x)
            
            if (y != nil) {
                //Scale and traslate y
                let scaledAntTranslatedY = requestedCenter.y - (y! * scale!)
                let point = CGPointMake(CGFloat(i), scaledAntTranslatedY)
                //If previous point existed, add a line from the previous one to the current one
                if (previousPoint != nil) {
                    path.addLineToPoint(point)
                }
                //Otherwise move to the new point
                else if (y != nil) {
                    path.moveToPoint(point)
                }
                previousPoint = point
            }
        }
        UIColor.blueColor().set()
        path.stroke()
        previousPath = path
        lastCenter = requestedCenter
        relativeCenterPerc = CGPointMake(requestedCenter.x / self.bounds.width, requestedCenter.y / self.bounds.height)
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * scale!) / scale!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let perc = relativeCenterPerc {
            nextCenter = CGPointMake(perc.x * self.bounds.width, perc.y * self.bounds.height)
        }
    }
}
