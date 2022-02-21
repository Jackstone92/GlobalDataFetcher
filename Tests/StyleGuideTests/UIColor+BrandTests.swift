//
//  UIColor+BrandTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import StyleGuide

final class UIColor_BrandTests: XCTestCase {

    func test_neutralDark() {

        XCTAssertEqual(UIColor.brand.neutralDark.hexString, "#5E87B5")
    }

    func test_neutralLightest() {

        XCTAssertEqual(UIColor.brand.neutralLightest.hexString, "#FFFFFF")
    }

    func test_primaryBase() {

        XCTAssertEqual(UIColor.brand.primaryBase.hexString, "#222D65")
    }

    func test_primaryDark() {

        XCTAssertEqual(UIColor.brand.primaryDark.hexString, "#101147")
    }

    func test_primaryLight() {

        XCTAssertEqual(UIColor.brand.primaryLight.hexString, "#D9EDF8")
    }

    func test_functionalRedBase() {

        XCTAssertEqual(UIColor.brand.functionalRedBase.hexString, "#C9001E")
    }
}

private extension UIColor {

    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)

        return [r, g, b]
            .map { String(format: "%02lX", Int($0 * 255)) }
            .reduce("#", +)
    }
}
