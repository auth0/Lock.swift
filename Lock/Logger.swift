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

public class Logger {

    static let sharedInstance = Logger()

    var level: LoggerLevel = .off
    var output: LoggerOutput = DefaultLoggerOutput()

    func debug(_ message: String, filename: String = #file, line: Int = #line) {
        guard self.level >= .debug else { return }
        output.message(message, level: .debug, filename: filename, line: line)
    }

    func info(_ message: String, filename: String = #file, line: Int = #line) {
        guard self.level >= .info else { return }
        output.message(message, level: .info, filename: filename, line: line)
    }

    func error(_ message: String, filename: String = #file, line: Int = #line) {
        guard self.level >= .error else { return }
        output.message(message, level: .error, filename: filename, line: line)
    }

    func warn(_ message: String, filename: String = #file, line: Int = #line) {
        guard self.level >= .warn else { return }
        output.message(message, level: .warn, filename: filename, line: line)
    }

    func verbose(_ message: String, filename: String = #file, line: Int = #line) {
        guard self.level >= .verbose else { return }
        output.message(message, level: .verbose, filename: filename, line: line)
    }
}

// MARK: - Level

public enum LoggerLevel: Int {
    case off = 0
    case error
    case warn
    case info
    case debug
    case verbose
    case all

    var label: String {
        switch self {
        case .error:
            return "ERROR"
        case .warn:
            return "WARN"
        case .info:
            return "INFO"
        case .debug:
            return "DEBUG"
        case .verbose:
            return "VERBOSE"
        default:
            return "INVALID"
        }
    }
}

func >= (lhs: LoggerLevel, rhs: LoggerLevel) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}

// MARK: - Loggable

protocol Loggable { }

extension Loggable {
    var logger: Logger {
        return Logger.sharedInstance
    }
}

// MARK: - LoggerOutput

public protocol LoggerOutput {
    func message(_ message: String, level: LoggerLevel, filename: String, line: Int)
}

struct DefaultLoggerOutput: LoggerOutput {
    func message(_ message: String, level: LoggerLevel, filename: String, line: Int) {
        trace("\(heading(forFile: filename, line: line))", level, message)
    }

    var trace: (String, LoggerLevel, String) -> Void = { print("\($1.label) | \($0) - \($2)") }

    private func heading(forFile file: String, line: Int) -> String {
        let filename = URL(fileURLWithPath: file).lastPathComponent
        return "\(filename):\(line)"
    }
}
