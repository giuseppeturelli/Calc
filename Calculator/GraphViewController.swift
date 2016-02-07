//
//  GraphViewController.swift
//  Calculator
//
//  Created by Giuseppe Turelli on 12/15/15.
//  Copyright © 2015 Giuseppe Turelli. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphDataSource {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "pan:"))
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.dataSource = self
        }
    }
    
    var brain: CalculatorBrain?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
