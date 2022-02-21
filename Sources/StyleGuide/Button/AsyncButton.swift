//
//  AsyncButton.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// A button that supports asynchronous tasks.
///
/// If a task takes >= 1 second to complete (ie. before the corresponding `AsyncButtonCompletion` is invoked),
/// an activity indicator is displayed until the completion is invoked.
///
public final class AsyncButton: UIButton {

    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .white)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let viewModel: AsyncButtonViewModel
    private let disposeBag = DisposeBag()

    public override var isHighlighted: Bool {
        didSet { updateBackgroundColour(when: isHighlighted) }
    }

    // MARK: - Init
    public init(
        title: String,
        action: @escaping AsyncButtonAction,
        isLoading: Bool = false,
        mainScheduler: SchedulerType = MainScheduler.asyncInstance,
        frame: CGRect = .zero
    ) {
        self.viewModel = AsyncButtonViewModel(
            title: title,
            action: action,
            isLoading: isLoading,
            mainScheduler: mainScheduler
        )

        super.init(frame: frame)

        setupViews()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupViews() {
        setupButton()
        setupActivityIndicatorView()
    }

    private func setupButton() {
        titleLabel?.font = .preferredFont(forTextStyle: .callout)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.maximumContentSizeCategory = .accessibilityLarge

        updateBackgroundColour(when: false)

        layer.cornerRadius = 4
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)

        setTitle(viewModel.title, for: .normal)
        setTitleColor(.brand.neutralLightest, for: .normal)

        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    private func setupActivityIndicatorView() {
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func updateBackgroundColour(when isHighlighted: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.backgroundColor = isHighlighted ? .brand.primaryDark : .brand.primaryBase
        }
    }

    // MARK: - Bindings
    private func setupBindings() {
        bindButtonContentAlpha()
        bindActivityIndicator()
        bindAccessibilityLabel()
    }

    private func bindButtonContentAlpha() {
        viewModel.buttonTitleAlpha
            .withUnretained(self)
            .bind(onNext: { owner, alpha in
                owner.titleLabel?.alpha = alpha
                owner.imageView?.alpha = alpha
            })
            .disposed(by: disposeBag)
    }

    private func bindActivityIndicator() {
        viewModel.isLoadingSubject
            .withUnretained(self)
            .bind(onNext: { owner, isLoading in
                switch isLoading {
                case true:  owner.activityIndicator.startAnimating()
                case false: owner.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
    }

    private func bindAccessibilityLabel() {
        viewModel.accessibilityLabel
            .bind(to: rx.accessibilityLabel)
            .disposed(by: disposeBag)
    }

    // MARK: - Actions
    @objc
    private func buttonTapped() {
        viewModel.onButtonTap()
    }
}
