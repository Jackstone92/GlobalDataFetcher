//
//  UILabel+DataFetchFeature.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import StyleGuide
@testable import DataFetchFeature

final class UILabel_DataFetchFeature: XCTestCase {

    func test_makeResponseCodeHeadingLabel() {

        let sut: UILabel = .makeResponseCodeHeadingLabel()

        XCTAssertEqual(sut.numberOfLines, 0)
        XCTAssertTrue(sut.adjustsFontForContentSizeCategory)
        XCTAssertFalse(sut.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(sut.text, "Response Code:")
        XCTAssertEqual(sut.textColor, .brand.primaryDark)
        XCTAssertEqual(sut.font, .preferredFont(forTextStyle: .headline).bold())
    }

    func test_makeResponseCodeLabel() {

        let sut: UILabel = .makeResponseCodeLabel()

        XCTAssertEqual(sut.numberOfLines, 0)
        XCTAssertTrue(sut.adjustsFontForContentSizeCategory)
        XCTAssertFalse(sut.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(sut.textColor, .brand.neutralDark)
        XCTAssertEqual(sut.font, .preferredFont(forTextStyle: .body).italic())
    }

    func test_makeTimesFetchedHeadingLabel() {

        let sut: UILabel = .makeTimesFetchedHeadingLabel()

        XCTAssertEqual(sut.numberOfLines, 0)
        XCTAssertTrue(sut.adjustsFontForContentSizeCategory)
        XCTAssertFalse(sut.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(sut.text, "Times Fetched:")
        XCTAssertEqual(sut.textColor, .brand.primaryDark)
        XCTAssertEqual(sut.font, .preferredFont(forTextStyle: .headline).bold())
    }

    func test_makeTimesFetchedLabel() {

        let sut: UILabel = .makeTimesFetchedLabel()

        XCTAssertEqual(sut.numberOfLines, 0)
        XCTAssertTrue(sut.adjustsFontForContentSizeCategory)
        XCTAssertFalse(sut.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(sut.textColor, .brand.neutralDark)
        XCTAssertEqual(sut.font, .preferredFont(forTextStyle: .body).italic())
    }

    func test_makeErrorMessageLabel() {

        let sut: UILabel = .makeErrorMessageLabel()

        XCTAssertEqual(sut.numberOfLines, 0)
        XCTAssertTrue(sut.adjustsFontForContentSizeCategory)
        XCTAssertFalse(sut.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(sut.textColor, .brand.functionalRedBase)
        XCTAssertEqual(sut.textAlignment, .center)
        XCTAssertEqual(sut.font, .preferredFont(forTextStyle: .callout).italic())
    }
}
