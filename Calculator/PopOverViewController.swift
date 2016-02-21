//
//  PopOverViewController.swift
//  Calculator
//
//  Created by Giuseppe Turelli on 2/21/16.
//  Copyright © 2016 Giuseppe Turelli. All rights reserved.
//

import UIKit

class PopOverViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var text: String = "" {
        didSet {
            textView?.text = text
        }
    }
    
    var anchor: CGPoint = CGPointZero
    
    override var preferredContentSize: CGSize {
        get {
            if textView != nil && presentingViewController != nil {
                return textView.sizeThatFits(presentingViewController!.view.bounds.size)
            } else {
                return super.preferredContentSize
            }
        }
        
        set {
            super.preferredContentSize = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textView?.text = text
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
