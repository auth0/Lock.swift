// LazyImageSpec.swift
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

class LazyImageSpec: QuickSpec {

    override func spec() {

        describe("init") {

            it("should use name only") {
                let image = LazyImage(name: "image")
                expect(image.name) == "image"
                expect(image.bundle) == Bundle.main
            }

            it("should use name and bundle") {
                let image = LazyImage(name: "image", bundle: Lock.bundle)
                expect(image.name) == "image"
                expect(image.bundle) == Lock.bundle
            }

        }

        describe("image(compatibleWithTraits:)") {
            it("should load image") {
                let image = LazyImage(name: "ic_auth0", bundle: Lock.bundle)
                expect(image.image(compatibleWithTraits: nil)).toNot(beNil())
            }

            it("should return nil when image cannot be found") {
                let image = LazyImage(name: "ic_not_found_image")
                expect(image.image(compatibleWithTraits: nil)).to(beNil())
            }

        }

    }

}
