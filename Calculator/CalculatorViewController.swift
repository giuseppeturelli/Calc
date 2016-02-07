//
//  ViewController.swift
//  Calculator
//
//  Created by Giuseppe Turelli on 6/21/15.
//  Copyright (c) 2015 Giuseppe Turelli. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var calcDisplay: UILabel!
    @IBOutlet weak var historyDisplay: UILabel!
    
    var userIsTyping = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.titleForState(UIControlState.Normal)!
        if !userIsTyping {
            userIsTyping = true
            calcDisplay.text! = digit
        } else {
            calcDisplay.text! += digit
        }
    }
    
    @IBAction func undo() {
        if userIsTyping {
            if (calcDisplay.text!).characters.count > 0 {
                calcDisplay.text = String((calcDisplay.text!).characters.dropLast())
            }
        } else {
            displayValue = brain.removeLastElement()
            historyValue = brain.description
        }
    }
    
    @IBAction func appendPoint(sender: UIButton) {
        let point = sender.titleForState(UIControlState.Normal)!
        if calcDisplay.text!.rangeOfString(point, options: [], range: nil, locale: nil) == nil {
            calcDisplay.text! += point
            userIsTyping = true
        }
    }
    
    @IBAction func appendPi(sender: UIButton) {
        if userIsTyping {
            enter()
        }
        appendDigit(sender)
        enter()
    }
    
    @IBAction func clear() {
        displayValue = nil
        historyValue = nil
        brain.clear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func enter() {
        userIsTyping = false
        if let toPush = calcDisplay.text {
            displayValue = brain.push(toPush)
            historyValue = brain.description
        }
    }
    
    var displayValue: Double? {
        get {
            if let number = NSNumberFormatter().numberFromString(calcDisplay.text!) {
                return number.doubleValue
            }
            else {
                return nil
            }
        }
        
        set {
            if (newValue != nil) {
                calcDisplay.text = "\(newValue!)"
                userIsTyping = false
            }
            else {
                calcDisplay.text = brain.errorDescr
            }
        }
    }
    
    var historyValue: String? {
        get {
            return historyDisplay.text
        }
        set {
            if newValue != nil {
                historyDisplay.text = newValue
            } else {
                historyDisplay.text = " "
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsTyping {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
            historyValue = brain.description
        }
    }
    
    @IBAction func changeSign(sender: UIButton) {
        if userIsTyping {
            if (calcDisplay.text!).characters.first == "-" {
                calcDisplay.text = String((calcDisplay.text!).characters.dropFirst())
            }
            else {
                calcDisplay.text = "-" + calcDisplay.text!
            }
        } else {
            operate(sender)
        }
    }
    @IBAction func setVariableM(sender: UIButton) {
        displayValue = brain.setVariable("M", value: calcDisplay.text)
        historyValue = brain.description
        userIsTyping = false
    }
    
    @IBAction func pushVariableM(sender: UIButton) {
        if userIsTyping {
            enter()
        }
        displayValue = brain.push("M")
        historyValue = brain.description
    }
    
    private struct CalcSegue {
        static let ShowGraph = "Show Graph"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        if let gvc = destination as? GraphViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case CalcSegue.ShowGraph:
                    gvc.title = "Hello"
                    gvc.brain = brain
                default:
                    break
                }
            }
        }
    }
}

