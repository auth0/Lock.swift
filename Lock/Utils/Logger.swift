// Logger.swift
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public protocol Logger {
    func debug(message: String, filename: String, line: Int)
    func info(message: String, filename: String, line: Int)
    func error(message: String, filename: String, line: Int)

    var level: LoggerLevel { get set }
}

extension Logger {
    func debug(message: String, _ filename: String = #file, _ line: Int = #line) {
        debug(message, filename: filename, line: line)
    }

    func info(message: String, _ filename: String = #file, _ line: Int = #line) {
        info(message, filename: filename, line: line)
    }

    func error(message: String, _ filename: String = #file, _ line: Int = #line) {
        error(message, filename: filename, line: line)
    }
}

// MARK:- Level

public enum LoggerLevel: Int {
    case Off = 0
    case Error
    case Info
    case Debug
    case All

    var label: String {
        switch self {
        case .Error:
            return "ERROR"
        case .Info:
            return "INFO"
        case .Debug:
            return "DEBUG"
        default:
            return "INVALID"
        }
    }
}

func >=(lhs: LoggerLevel, rhs: LoggerLevel) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}

// MARK:- Loggable

protocol Loggable {
    var customLogger: Logger? { get }
}

extension Loggable {
    var logger: Logger {
        return self.customLogger ?? DefaultLogger.sharedInstance
    }
}

// MARK:- Default Logger (console)

class DefaultLogger: Logger {

    static let sharedInstance = DefaultLogger()

    var level: LoggerLevel = .Off
    var trace: (String, LoggerLevel, String) -> () = { print("\($1.label) | \($0) - \($2)") }

    func debug(message: String, filename: String, line: Int) {
        guard self.level >= .Debug else { return }
        trace("\(heading(forFile: filename, line: line))", .Debug, message)
    }

    func info(message: String, filename: String, line: Int) {
        guard self.level >= .Info else { return }
        trace("\(heading(forFile: filename, line: line))", .Info, message)
    }

    func error(message: String, filename: String, line: Int) {
        guard self.level >= .Error else { return }
        trace("\(heading(forFile: filename, line: line))", .Error, message)
    }

    private func heading(forFile file: String, line: Int) -> String {
        let filename = NSURL(fileURLWithPath: file).lastPathComponent ?? ""
        return "\(filename):\(line)"
    }
}
