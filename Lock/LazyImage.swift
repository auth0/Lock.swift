// LazyImage.swift
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

/**
 *  Convenience struct to hold an image reference to a `NSBundle` without loading the `UIImage`.
 *  Used to tell Lock to load an image from a specific bundle, e.g. when customising the Header logo.
 */
public struct LazyImage: Equatable {
    let bundle: Bundle
    let name: String

    /**
     Creates a LazyImage with a name and an optional Bundle.
     For images outside Lock's bundle you should specify the Bundle like
     
     ```
     let image = LazyImage(name: "image_name")
     ```

     - parameter name:   name of the image to load from a bundle
     - parameter bundle: bundle from where to load the image. By default is application main bundle

     - returns: a newly created `LazyImage`
     */
    public init(name: String, bundle: Bundle = Bundle.main) {
        self.name = name
        self.bundle = bundle
    }

    func image(compatibleWithTraits traits: UITraitCollection? = nil) -> UIImage? {
        return UIImage(named: self.name, in: self.bundle, compatibleWith: traits)
    }
}

public func == (lhs: LazyImage, rhs: LazyImage) -> Bool {
    return lhs.name == rhs.name && lhs.bundle == rhs.bundle
}
