//
//  AnimatedSink+OptionalText.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import UIKit
import RxSwift
import RxAnimated

extension AnimatedSink where Base: UILabel {

    /// A `Binder` that allows for an optional string to be set on
    /// a `UILabel`'s `text` property with animation applied.
    ///
    var optionalText: Binder<String?> {
        let animation = self.type

        return Binder(base) { label, optionalText in
            animation?.animate(view: label, binding: {
                label.text = optionalText
            })
        }
    }
}
