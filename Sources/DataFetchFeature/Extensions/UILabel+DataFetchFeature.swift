//
//  UILabel+DataFetchFeature.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import UIKit
import StyleGuide

extension UILabel {

    /// A factory method that vends the heading for the response code.
    static func makeResponseCodeHeadingLabel() -> UILabel {
        let label: UILabel = .makeHeadingBase()
        label.text = "Response Code:"
        return label
    }

    /// A factory method that vends the label for the response code value.
    static func makeResponseCodeLabel() -> UILabel {
        return .makeSubHeadingBase()
    }

    /// A factory method that vends the heading for times fetched.
    static func makeTimesFetchedHeadingLabel() -> UILabel {
        let label: UILabel = .makeHeadingBase()
        label.text = "Times Fetched:"
        return label
    }

    /// A factory method that vends the label for the times fetched value.
    static func makeTimesFetchedLabel() -> UILabel {
        return .makeSubHeadingBase()
    }

    /// A factory method that vends the error message label.
    static func makeErrorMessageLabel() -> UILabel {
        let label: UILabel = .makeBase()
        label.textColor = .brand.functionalRedBase
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .callout).italic()
        return label
    }

    // MARK: - Common
    private static func makeHeadingBase() -> UILabel {
        let label: UILabel = .makeBase()
        label.textColor = .brand.primaryDark
        label.font = .preferredFont(forTextStyle: .headline).bold()
        return label
    }

    private static func makeSubHeadingBase() -> UILabel {
        let label: UILabel = .makeBase()
        label.textColor = .brand.neutralDark
        label.font = .preferredFont(forTextStyle: .body).italic()
        return label
    }

    private static func makeBase() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityLarge
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
