//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Giuseppe Turelli on 10/1/15.
//  Copyright © 2015 Giuseppe Turelli. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible {
        case Operand(String)
        case ConstantOperand(String, Double)
        case UnaryOperation(String, (Double -> Double), (Double -> String?)?)
        case BinaryOperation(String, (Double, Double) -> Double, ((Double, Double) -> String?)?)
        
        var description: String {
            get {
                switch self {
                case Op.Operand(let operand):
                    return operand
                case Op.ConstantOperand(let constOperand, _):
                    return constOperand
                case Op.UnaryOperation(let symbol, _, _):
                    return symbol
                case Op.BinaryOperation(let symbol, _, _):
                    return symbol
                }
            }
        }
        var precedence: Int {
            get {
                switch self {
                case Op.BinaryOperation(let symbol, _, _):
                    switch symbol {
                    case "⊗":
                        return 20
                    case "⌹":
                        return 20
                    case "+":
                        return 10
                    case "-":
                        return 10
                    default:
                        return 0
                    }
                default:
                    return Int.max
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String: Op]()
    
    var variableValues = [String: Double]()
    
    init() {
        
        func learnOps(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOps(Op.ConstantOperand("π", M_PI))
        
        learnOps(Op.BinaryOperation("⊗", *, nil))
        learnOps(Op.BinaryOperation("⌹", { $1 / $0 }, { if $0.0 == 0 { return "Divide by Zero" }; return nil }))
        learnOps(Op.BinaryOperation("+", +, nil))
        learnOps(Op.BinaryOperation("-", { $1 - $0 }, nil))
        learnOps(Op.UnaryOperation("√", sqrt, { if $0 < 0 { return "Sqrt of a negative num" }; return nil }))
        learnOps(Op.UnaryOperation("sin", {sin($0)}, nil))
        learnOps(Op.UnaryOperation("cos", {cos($0)}, nil))
        learnOps(Op.UnaryOperation("+/-", {$0 * -1}, nil))
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Operand(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func push(pushedValue: String?) -> Double? {
        if let toPush = pushedValue {
            if knownOps.keys.contains(toPush) {
                return performOperation(toPush)
            } else {
                return pushOperand(toPush)
            }
        }
        return nil
    }
    
    func removeLastElement() -> Double? {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return evaluate()
    }
    
    func setVariable(name: String, value: String?) -> Double? {
        if let number = NSNumberFormatter().numberFromString(value!)?.doubleValue {
            variableValues[name] = number
        }
        return evaluate()
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case Op.Operand(let operand):
                if let number = NSNumberFormatter().numberFromString(operand) {
                    return (number.doubleValue, remainingOps)
                } else if let value = variableValues[operand] {
                    return (value, remainingOps)
                }
            case Op.ConstantOperand(_, let value):
                return (value, remainingOps)
            case Op.UnaryOperation(_, let operation, _):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case Op.BinaryOperation(_, let operation, _):
                let operand1Eval = evaluate(remainingOps)
                let operand2Eval = evaluate(operand1Eval.remainingOps)
                if let operand1 = operand1Eval.result  {
                    if let operand2 = operand2Eval.result {
                        return (operation(operand1, operand2), operand2Eval.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        let (resultWithErrors, _) = evaluateAndReportErrors(opStack)
        print(resultWithErrors)
        return result
    }
    
    enum Result {
        case Normal(Double)
        case Error(String)
    }
    
    private func evaluateAndReportErrors(ops: [Op]) -> (result: Result, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case Op.Operand(let operand):
                if let number = NSNumberFormatter().numberFromString(operand) {
                    return (Result.Normal(number.doubleValue), remainingOps)
                } else if let value = variableValues[operand] {
                    return (Result.Normal(value), remainingOps)
                } else {
                    return (Result.Error("Variable not set"), remainingOps)
                }
            case Op.ConstantOperand(_, let value):
                return (Result.Normal(value), remainingOps)
            case Op.UnaryOperation(_, let operation, let check):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    if let error = check?(operand) {
                        return (Result.Error(error), remainingOps)
                    } else {
                        return (Result.Normal(operation(operand)), operandEvaluation.remainingOps)
                    }
                }
            case Op.BinaryOperation(_, let operation, let check):
                let operand1Eval = evaluate(remainingOps)
                let operand2Eval = evaluate(operand1Eval.remainingOps)
                if let operand1 = operand1Eval.result  {
                    if let operand2 = operand2Eval.result {
                        if let error = check?(operand1, operand2) {
                            return (Result.Error(error), remainingOps)
                        } else {
                            return (Result.Normal(operation(operand1, operand2)), operand2Eval.remainingOps)
                        }
                    }
                }
            }
        }
        return (Result.Error("Not enough operands"), ops)
    }
    
    func evaluateAndReportErrors() -> Result {
        let (result, _) = evaluateAndReportErrors(opStack)
        return result
    }
    
    
    private func getDescription(ops: [Op], previousOpPrecedence: Int) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case Op.UnaryOperation(let symbol, _, _):
                let operandPrint = getDescription(remainingOps, previousOpPrecedence: op.precedence)
                if let operandSymbol = operandPrint.result {
                    return (symbol + "(" + operandSymbol + ")", operandPrint.remainingOps)
                }
            case Op.BinaryOperation(let symbol, _, _):
                let operand1Print = getDescription(remainingOps, previousOpPrecedence: op.precedence)
                let operand2Print = getDescription(operand1Print.remainingOps, previousOpPrecedence: op.precedence)
                if let op1 = operand1Print.result {
                    if let op2 = operand2Print.result {
                        var textToReturn = op2 + symbol + op1
                        if previousOpPrecedence > op.precedence {
                            textToReturn = "(" + textToReturn + ")"
                        }
                        return (textToReturn,operand2Print.remainingOps)
                    }
                }
            default:
                return (op.description, remainingOps)
            }
        }
        return ("?", ops)
    }
    
    
    var description: String? {
        get {
            var reminder = opStack
            var results = [String]()
            while !reminder.isEmpty {
                let (result, more) = getDescription(reminder, previousOpPrecedence: 0)
                if result != nil {
                    results.append(result!)
                }
                reminder = more
            }
            var textToReturn = ""
            for a in results.reverse() {
                if !textToReturn.isEmpty {
                    textToReturn += ","
                }
                textToReturn += a
            }
            textToReturn += " ="
            return textToReturn
        }
    }
    
    func clearOpStack() {
        opStack = [Op]()
    }
    
    func clearVariables() {
        variableValues = [String: Double]()
    }
    
    func clear() {
        clearOpStack()
        clearVariables()
    }
    
    typealias PropertyList = AnyObject
    
    var myPropList: PropertyList {
        get {
            return opStack.map({ $0.description })
    }
        set {
            var newOpStack = [Op]()
            if let input = newValue as? [String] {
                for op in input {
                    if let operand = knownOps[op] {
                        newOpStack.append(operand)
                    } else if NSNumberFormatter().numberFromString(op) != nil {
                        newOpStack.append(Op.Operand(op))
                    }
                }
                opStack = newOpStack
            }
        }
    }
}