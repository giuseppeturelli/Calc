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
    
    var scale: CGFloat = 50.0 {
        didSet {
            setNeedsDisplay()
            previousPath = nil
        } }
    
    var lastTranslation: CGPoint = CGPointZero {
        didSet { setNeedsDisplay() } }
    
    var lastCenter: CGPoint? = nil
    
    var previousPath: UIBezierPath? = nil
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        if (lastCenter == nil) {
            lastCenter = convertPoint(center, fromCoordinateSpace: superview!)
        }
        lastCenter!.x += lastTranslation.x
        lastCenter!.y += lastTranslation.y
        
        let axesDrawer = AxesDrawer(contentScaleFactor: CGFloat(scale))
        axesDrawer.drawAxesInRect(self.bounds, origin: lastCenter!, pointsPerUnit: scale)
        
        var previousPoint: CGPoint?
        
        var startX: CGFloat = 0.0
        var endX: CGFloat = self.bounds.width
        
        var path = UIBezierPath()
        if previousPath != nil {
            path = previousPath!
            
            let translation = CGAffineTransformMakeTranslation(lastTranslation.x, lastTranslation.y)
            path.applyTransform(translation)
            
            if lastTranslation.x > 0.0 {
                endX = lastTranslation.x + 1
            } else {
                startX = self.bounds.width + lastTranslation.x - 1
                //Calculating previousPoint
            }
        }
        
        print("This is the start \(startX) this is the end \(endX)")
        for i in Int(startX)...Int(endX) {
            //Translate and scale x
            let x = (CGFloat(i) - lastCenter!.x) / scale
            //Get y from data source
            let y = dataSource?.getYValueForX(x)
            
            if (y != nil) {
                //Scale and traslate y
                let scaledAntTranslatedY = lastCenter!.y - (y! * scale)
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
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * scale) / scale
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.Changed: fallthrough
        case UIGestureRecognizerState.Ended:
            lastTranslation = gesture.translationInView(self)
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
}
