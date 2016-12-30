// LockViewControllerSpec.swift
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

class LockViewControllerSpec: QuickSpec {

    override func spec() {

        var controller: LockViewController!

        beforeEach {
            controller = Lock.classic(clientId: clientId, domain: domain).withConnections { $0.database(name: "db", requiresUsername: false) }.controller
        }

        describe("keyboard") {

            beforeEach {
                controller.loadView()
                controller.viewDidLoad()
            }

            it("should start without keyboard") {
                expect(controller.keyboard) == false
            }

            it("should have anchor constraint") {
                expect(controller.anchorConstraint).toNot(beNil())
            }

            it("should have zero insets in scroll") {
                expect(controller.scrollView?.contentInset) == UIEdgeInsets.zero
            }

            context("show") {

                var frame: CGRect!
                var duration: TimeInterval!
                var curve: UIViewAnimationOptions!

                beforeEach {
                    frame = CGRect(x: randomInteger(0, to: 200), y: randomInteger(0, to: 200), width: randomInteger(0, to: 200), height: randomInteger(0, to: 200))
                    duration = randomTimeInterval(0, to: 60)
                    curve = UIViewAnimationOptions()
                }

                it("should ignore invalid notification") {
                    let notification = Notification(name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                    controller.keyboardWasShown(notification)
                    expect(controller.keyboard) == false
                }

                it("should mark keyboard is displayed") {
                    let notification = willShowNotification(frame: frame, duration: duration, curve: curve)
                    controller.keyboardWasShown(notification)
                    expect(controller.keyboard) == true
                }

                it("should add insets to scroll") {
                    let notification = willShowNotification(frame: frame, duration: duration, curve: curve)
                    controller.keyboardWasShown(notification)
                    expect(controller.scrollView?.contentInset) == UIEdgeInsets(top: 0, left: 0, bottom: frame.size.height, right: 0)
                }

                it("should disable anchor constraint") {
                    let notification = willShowNotification(frame: frame, duration: duration, curve: curve)
                    controller.keyboardWasShown(notification)
                    expect(controller.anchorConstraint?.isActive).toEventually(beFalse())
                }

            }

            context("hide") {

                var duration: TimeInterval!
                var curve: UIViewAnimationOptions!

                beforeEach {
                    duration = randomTimeInterval(0, to: 60)
                    curve = UIViewAnimationOptions()
                }

                it("should ignore invalid notification") {
                    let notification = Notification(name: NSNotification.Name.UIKeyboardWillHide, object: nil)
                    controller.keyboardWasHidden(notification)
                    expect(controller.keyboard) == false
                }

                it("should mark keyboard is hidden") {
                    let notification = willHideNotification(duration: duration, curve: curve)
                    controller.keyboardWasHidden(notification)
                    expect(controller.keyboard) == false
                }

                it("should reset insets in scroll") {
                    let notification = willHideNotification(duration: duration, curve: curve)
                    controller.keyboardWasHidden(notification)
                    expect(controller.scrollView?.contentInset) == UIEdgeInsets.zero
                }

                it("should enable anchor constraint") {
                    let notification = willHideNotification(duration: duration, curve: curve)
                    controller.keyboardWasHidden(notification)
                    expect(controller.anchorConstraint?.isActive).toEventually(beTrue())
                }

            }

        }
    }

}

func randomInteger(_ from: Int, to: Int) -> Int {
    return Int(arc4random_uniform(UInt32(to))) + from
}

func randomTimeInterval(_ from: Int, to: Int) -> TimeInterval {
    let value: Int = Int(arc4random_uniform(UInt32(to))) + from
    return Double(value)
}

func willShowNotification(frame: CGRect, duration: TimeInterval, curve: UIViewAnimationOptions) -> Notification {
    let notification = Notification(
        name: NSNotification.Name.UIKeyboardWillShow,
        object: nil,
        userInfo: [
            UIKeyboardFrameEndUserInfoKey: NSValue(cgRect: frame),
            UIKeyboardAnimationDurationUserInfoKey: NSNumber(value: duration as Double),
            UIKeyboardAnimationCurveUserInfoKey: NSNumber(value: curve.rawValue as UInt),
        ]
    )
    return notification
}

func willHideNotification(duration: TimeInterval, curve: UIViewAnimationOptions) -> Notification {
    let notification = Notification(
        name: NSNotification.Name.UIKeyboardWillHide,
        object: nil,
        userInfo: [
            UIKeyboardAnimationDurationUserInfoKey: NSNumber(value: duration as Double),
            UIKeyboardAnimationCurveUserInfoKey: NSNumber(value: curve.rawValue as UInt),
        ]
    )
    return notification
}
