//
//  DataFetchViewController.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxAnimated
import StyleGuide

/// The main `DataFetchFeature` view controller. This allows the user to tap a button to fetch content
/// and have the corresponding response code printed on the screen and the fetch counter incremented.
///
public final class DataFetchViewController: UIViewController {

    lazy var responseCodeHeading: UILabel = .makeResponseCodeHeadingLabel()
    lazy var responseCodeLabel: UILabel = .makeResponseCodeLabel()
    lazy var timesFetchedHeading: UILabel = .makeTimesFetchedHeadingLabel()
    lazy var timesFetchedLabel: UILabel = .makeTimesFetchedLabel()
    lazy var errorMessageLabel: UILabel = .makeErrorMessageLabel()

    lazy var fetchContentButton: AsyncButton = {
        let button = AsyncButton(title: "Fetch Content", action: fetchContentButtonAction)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var dataStackView: UIStackView = .makePrimaryVertical(
        with: [responseCodeStackView, timesFetchedStackView],
        alignment: .leading
    )
    private lazy var responseCodeStackView: UIStackView = .makeNested(
        with: [responseCodeHeading, responseCodeLabel],
        axis: .vertical
    )
    private lazy var timesFetchedStackView: UIStackView = .makeNested(
        with: [timesFetchedHeading, timesFetchedLabel],
        axis: .horizontal
    )
    private lazy var buttonStackView: UIStackView = .makePrimaryVertical(
        with: [errorMessageLabel, fetchContentButton],
        alignment: .center
    )

    let viewModel: DataFetchViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Button action
    private var fetchContentButtonAction: AsyncButtonAction {
        return { [weak self] completion in
            guard let self = self else { completion(); return }

            self.viewModel.fetchContent()
                .subscribe(
                    onNext: { _ in completion() },
                    onError: { _ in completion() }
                )
                .disposed(by: self.disposeBag)
        }
    }

    // MARK: - Init
    public init(viewModel: DataFetchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle methods
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.onAppear()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupBindings()
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .brand.neutralLightest
        setupButtonStackView()
        setupDataStackView()
    }

    private func setupButtonStackView() {
        view.addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            fetchContentButton.leadingAnchor.constraint(equalTo: buttonStackView.leadingAnchor),
            fetchContentButton.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor)
        ])
    }

    private func setupDataStackView() {
        view.addSubview(dataStackView)

        NSLayoutConstraint.activate([
            dataStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            dataStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            dataStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Bindings
    private func setupBindings() {
        bindResponseCodeLabel()
        bindTimesFetchedLabel()
        bindErrorMessageLabel()
    }

    private func bindResponseCodeLabel() {
        viewModel.responseCodeLabel
            .distinctUntilChanged()
            .bind(animated: responseCodeLabel.rx.animated.fade(duration: 0.3).optionalText)
            .disposed(by: disposeBag)
    }

    private func bindTimesFetchedLabel() {
        viewModel.timesFetchedLabel
            .distinctUntilChanged()
            .bind(animated: timesFetchedLabel.rx.animated.fade(duration: 0.3).text)
            .disposed(by: disposeBag)
    }

    private func bindErrorMessageLabel() {
        viewModel.errorMessageLabel
            .distinctUntilChanged()
            .bind(animated: errorMessageLabel.rx.animated.fade(duration: 0.6).optionalText)
            .disposed(by: disposeBag)
    }
}
