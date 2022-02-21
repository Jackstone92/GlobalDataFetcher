//
//  UIStackView+DataFetchFeature.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
@testable import DataFetchFeature

final class UIStackView_DataFetchFeature: XCTestCase {

    private var subview: UIView!

    override func setUp() {
        super.setUp()

        subview = UIView()
    }

    func test_makePrimaryVertical() {

        let alignment: UIStackView.Alignment = .leading

        let sut: UIStackView = .makePrimaryVertical(with: [subview], alignment: alignment)

        XCTAssertEqual(sut.arrangedSubviews, [subview])
        XCTAssertFalse(sut.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(sut.axis, .vertical)
        XCTAssertEqual(sut.alignment, alignment)
        XCTAssertEqual(sut.spacing, 24)
        XCTAssertEqual(sut.distribution, .fillEqually)
    }

    func test_makeNested() {

        let axis: NSLayoutConstraint.Axis = .horizontal

        let sut: UIStackView = .makeNested(with: [subview], axis: axis)

        XCTAssertEqual(sut.arrangedSubviews, [subview])
        XCTAssertFalse(sut.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(sut.axis, axis)
        XCTAssertEqual(sut.spacing, 8)
        XCTAssertEqual(sut.distribution, .fill)
    }
}
