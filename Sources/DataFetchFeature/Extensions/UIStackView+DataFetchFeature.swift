//
//  UIStackView+DataFetchFeature.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import UIKit

extension UIStackView {

    /// A factory method that vends the primary stack view.
    static func makePrimaryVertical(with arrangedSubviews: [UIView], alignment: UIStackView.Alignment) -> UIStackView {
        let stackView: UIStackView = .makeBase(with: arrangedSubviews)
        stackView.axis = .vertical
        stackView.alignment = alignment
        stackView.spacing = 24
        stackView.distribution = .fillEqually
        return stackView
    }

    /// A factory method that vends a stack view that can be nested inside an existing stack view.
    static func makeNested(
        with arrangedSubviews: [UIView],
        axis: NSLayoutConstraint.Axis
    ) -> UIStackView {
        let stackView: UIStackView = .makeBase(with: arrangedSubviews)
        stackView.axis = axis
        stackView.alignment = .leading
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }

    private static func makeBase(with arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}
