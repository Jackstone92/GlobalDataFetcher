//
//  UIFont+Extensions.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import UIKit

extension UIFont {

    /// Modifies an existing font with bold symbolic traits.
    public func bold() -> UIFont {
        return withTraits(.traitBold)
    }

    /// Modifies an existing font with italic symbolic traits.
    public func italic() -> UIFont {
        return withTraits(.traitItalic)
    }

    private func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }

        return UIFont(descriptor: descriptor, size: 0) // size `0` maintains the existing size.
    }
}
