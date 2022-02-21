//
//  UIColor+Brand.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import UIKit

extension UIColor {

    public enum brand {

        public static var neutralDark: UIColor {
            UIColor(named: "neutral-dark", in: .module, compatibleWith: nil)!
        }

        public static var neutralLightest: UIColor {
            UIColor(named: "neutral-lightest", in: .module, compatibleWith: nil)!
        }

        public static var primaryBase: UIColor {
            UIColor(named: "primary-base", in: .module, compatibleWith: nil)!
        }

        public static var primaryDark: UIColor {
            UIColor(named: "primary-dark", in: .module, compatibleWith: nil)!
        }

        public static var primaryLight: UIColor {
            UIColor(named: "primary-light", in: .module, compatibleWith: nil)!
        }

        public static var functionalRedBase: UIColor {
            UIColor(named: "functional-red-base", in: .module, compatibleWith: nil)!
        }
    }
}
