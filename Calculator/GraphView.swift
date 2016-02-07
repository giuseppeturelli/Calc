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
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let axesCenter = convertPoint(center, fromCoordinateSpace: superview!)
        let axesDrawer = AxesDrawer(contentScaleFactor: CGFloat(scale))
        axesDrawer.drawAxesInRect(rect, origin: axesCenter, pointsPerUnit: scale)
        
        let path = UIBezierPath()
        var previousPoint: CGPoint?
        
        for i in Int(0)...Int(2*axesCenter.x) {
            let x = (CGFloat(i) - axesCenter.x) / scale
            let y = dataSource?.getYValueForX(CGFloat(x))
            if (y != nil) {
                let point = CGPointMake(CGFloat(i), (axesCenter.y - (y! * scale)))
                if (previousPoint != nil) {
                    path.addLineToPoint(point)
                }
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
            self.center.x += translation.x
            self.center.y += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
        setNeedsDisplay()
    }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
}
