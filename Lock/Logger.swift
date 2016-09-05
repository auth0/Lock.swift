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

class Logger {

    static let sharedInstance = Logger()

    var level: LoggerLevel = .Off
    var output: LoggerOutput = DefaultLoggerOutput()

    func debug(message: String, filename: String = #file, line: Int = #line) {
        guard self.level >= .Debug else { return }
        output.message(message, level: .Debug, filename: filename, line: line)
    }

    func info(message: String, filename: String = #file, line: Int = #line) {
        guard self.level >= .Info else { return }
        output.message(message, level: .Info, filename: filename, line: line)
    }

    func error(message: String, filename: String = #file, line: Int = #line) {
        guard self.level >= .Error else { return }
        output.message(message, level: .Error, filename: filename, line: line)
    }

    func warn(message: String, filename: String = #file, line: Int = #line) {
        guard self.level >= .Warn else { return }
        output.message(message, level: .Warn, filename: filename, line: line)
    }

    func verbose(message: String, filename: String = #file, line: Int = #line) {
        guard self.level >= .Verbose else { return }
        output.message(message, level: .Verbose, filename: filename, line: line)
    }
}

// MARK:- Level

public enum LoggerLevel: Int {
    case Off = 0
    case Error
    case Warn
    case Info
    case Debug
    case Verbose
    case All

    var label: String {
        switch self {
        case .Error:
            return "ERROR"
        case Warn:
            return "WARN"
        case .Info:
            return "INFO"
        case .Debug:
            return "DEBUG"
        case .Verbose:
            return "VERBOSE"
        default:
            return "INVALID"
        }
    }
}

func >=(lhs: LoggerLevel, rhs: LoggerLevel) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}

// MARK:- Loggable

protocol Loggable { }

extension Loggable {
    var logger: Logger {
        return Logger.sharedInstance
    }
}

// MARK:- LoggerOutput

public protocol LoggerOutput {
    func message(message: String, level: LoggerLevel, filename: String, line: Int)
}

struct DefaultLoggerOutput: LoggerOutput {
    func message(message: String, level: LoggerLevel, filename: String, line: Int) {
        trace("\(heading(forFile: filename, line: line))", level, message)
    }

    var trace: (String, LoggerLevel, String) -> () = { print("\($1.label) | \($0) - \($2)") }

    private func heading(forFile file: String, line: Int) -> String {
        let filename = NSURL(fileURLWithPath: file).lastPathComponent ?? ""
        return "\(filename):\(line)"
    }
}