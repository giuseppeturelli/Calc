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
        didSet { setNeedsDisplay() } }
    
    var centerTranslation: CGPoint? = nil {
        didSet { setNeedsDisplay() } }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        if (centerTranslation == nil) {
            centerTranslation = convertPoint(center, fromCoordinateSpace: superview!)
        }
        
        let axesDrawer = AxesDrawer(contentScaleFactor: CGFloat(scale))
        axesDrawer.drawAxesInRect(self.bounds, origin: centerTranslation!, pointsPerUnit: scale)
        
        let path = UIBezierPath()
        var previousPoint: CGPoint?
        
        for i in Int(self.bounds.origin.x)...Int(self.bounds.width) {
            //Translate and scale x
            let x = (CGFloat(i) - centerTranslation!.x) / scale
            //Get y from data source
            let y = dataSource?.getYValueForX(x)
            
            if (y != nil) {
                //Scale and traslate y
                let scaledAntTranslatedY = centerTranslation!.y - (y! * scale)
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
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * scale) / scale
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.Changed: fallthrough
        case UIGestureRecognizerState.Ended:
            let translation = gesture.translationInView(self)
            centerTranslation!.x += translation.x
            centerTranslation!.y += translation.y
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
