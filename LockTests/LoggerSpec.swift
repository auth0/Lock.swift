// LoggerSpec.swift
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

import Quick
import Nimble

@testable import Lock

private let message = UUID().uuidString

class LoggerSpec: QuickSpec {

    override func spec() {

        var logger: Logger!
        var output: MockLoggerOutput!

        beforeEach {
            logger = Logger()
            output = MockLoggerOutput()
            logger.output = output
        }

        context("all enabled") {

            beforeEach {
                logger.level = .all
            }

            it("should log verbose message") {
                logger.verbose(message)
                expect(output.message) == message
                expect(output.level) == .verbose
                expect(output.level?.label) == "VERBOSE"
            }

            it("should log debug message") {
                logger.debug(message)
                expect(output.message) == message
                expect(output.level) == .debug
                expect(output.level?.label) == "DEBUG"
            }

            it("should log info message") {
                logger.info(message)
                expect(output.message) == message
                expect(output.level) == .info
                expect(output.level?.label) == "INFO"
            }

            it("should log warn message") {
                logger.warn(message)
                expect(output.message) == message
                expect(output.level) == .warn
                expect(output.level?.label) == "WARN"
            }

            it("should log error message") {
                logger.error(message)
                expect(output.message) == message
                expect(output.level) == .error
                expect(output.level?.label) == "ERROR"
            }
        }

        context("off") {

            beforeEach {
                logger.level = .off
            }

            it("should log verbose message") {
                logger.verbose(message)
                expect(output.message).to(beNil())
                expect(output.level).to(beNil())
            }

            it("should log debug message") {
                logger.debug(message)
                expect(output.message).to(beNil())
                expect(output.level).to(beNil())
            }

            it("should log info message") {
                logger.info(message)
                expect(output.message).to(beNil())
                expect(output.level).to(beNil())
            }

            it("should log warn message") {
                logger.warn(message)
                expect(output.message).to(beNil())
                expect(output.level).to(beNil())
            }

            it("should log error message") {
                logger.error(message)
                expect(output.message).to(beNil())
                expect(output.level).to(beNil())
            }
        }

    }

}

class MockLoggerOutput: LoggerOutput {
    var message: String? = nil
    var level: LoggerLevel? = nil

    func message(_ message: String, level: LoggerLevel, filename: String, line: Int) {
        self.message = message
        self.level = level
    }
}
