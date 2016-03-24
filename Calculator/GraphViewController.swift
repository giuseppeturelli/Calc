//
//  GraphViewController.swift
//  Calculator
//
//  Created by Giuseppe Turelli on 12/15/15.
//  Copyright © 2015 Giuseppe Turelli. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphDataSource, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(GraphViewController.pan(_:))))
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(GraphViewController.scale(_:))))
            graphView.dataSource = self
            graphView.nextCenter = origin
            graphView.scale = scale
        }
    }
    
    var brain: CalculatorBrain?
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private struct DefaultsString {
        static let OriginXKey = "GraphViewController.OriginX"
        static let OriginYKey = "GraphViewController.OriginY"
        static let ScaleKey = "GraphViewController.Scale"
        static let PopOverIdentifier = "Graph Details PopOver"
    }
    
    private var pointTouched: CGPoint = CGPointZero
    
    var origin: CGPoint? {
        get {
            if let x = defaults.objectForKey(DefaultsString.OriginXKey) as? CGFloat {
                if let y = defaults.objectForKey(DefaultsString.OriginYKey) as? CGFloat {
                    return CGPointMake(x, y)
                }
            }
            return nil
        }
        set {
            defaults.setObject(newValue?.x, forKey: DefaultsString.OriginXKey)
            defaults.setObject(newValue?.y, forKey: DefaultsString.OriginYKey)
        }
    }
    
    var scale: CGFloat? {
        get {
            return defaults.objectForKey(DefaultsString.ScaleKey) as? CGFloat
        }
        set {
            defaults.setObject(newValue, forKey: DefaultsString.ScaleKey)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        origin = graphView.lastCenter
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getYValueForX(x: CGFloat) -> CGFloat? {
        let aString = "\(x)"
        let resultDouble = brain?.setVariable("M", value: aString)
        brain?.clearVariables()
        if (resultDouble != nil) {
            return CGFloat(resultDouble!)
        } else {
            return nil
        }
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.Changed: fallthrough
        case UIGestureRecognizerState.Ended:
            graphView.translation = gesture.translationInView(graphView)
            gesture.setTranslation(CGPointZero, inView: graphView)
        default: break
        }
    }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Changed {
            graphView.scale! *= gesture.scale
            scale = graphView.scale
            gesture.scale = 1
        }
    }
    
    
    @IBAction func tap(gesture: UITapGestureRecognizer) {
        pointTouched = gesture.locationInView(graphView)
        performSegueWithIdentifier(DefaultsString.PopOverIdentifier, sender: self)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
    
    @IBAction func doubleTap(gesture: UITapGestureRecognizer) {
        graphView.nextCenter = gesture.locationInView(graphView)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case DefaultsString.PopOverIdentifier:
                if let pvc = segue.destinationViewController as? PopOverViewController {
                    if let ppc = pvc.popoverPresentationController {
                        ppc.delegate = self
                        ppc.sourceView = graphView
                        ppc.sourceRect = CGRectMake(pointTouched.x, pointTouched.y, 0, 20)
                    }
                    pvc.text = "MinY: \(graphView.minY) MaxY: \(graphView.maxY)\nThis is the point you touched\n X:\(pointTouched.x) Y:\(pointTouched.y)"
                }
            default:
                break
            }
        }
    }

}
