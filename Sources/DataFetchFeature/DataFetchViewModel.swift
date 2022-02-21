//
//  DataFetchViewModel.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import RxSwift

/// The interface for the main `DataFetchFeature` view model.
public final class DataFetchViewModel {

    /// An observable containing the response code label.
    public let responseCodeLabel: Observable<String?>

    /// An observable containing the times fetched label.
    public let timesFetchedLabel: Observable<String>

    /// An observable containing the error message label.
    public let errorMessageLabel: Observable<String?>

    /// Restores state according to the last response code and counter value known to
    /// the `LastResponseCodeService` and `CounterService`.
    /// This ensures any persisted data is restored after the app restarts.
    public let onAppear: () -> Void

    /// Initiates the fetching of new content.
    public let fetchContent: () -> Observable<Void>

    public init(
        responseCodeLabel: Observable<String?>,
        timesFetchedLabel: Observable<String>,
        errorMessageLabel: Observable<String?>,
        onAppear: @escaping () -> Void,
        fetchContent: @escaping () -> Observable<Void>
    ) {
        self.responseCodeLabel = responseCodeLabel
        self.timesFetchedLabel = timesFetchedLabel
        self.errorMessageLabel = errorMessageLabel
        self.onAppear = onAppear
        self.fetchContent = fetchContent
    }
}
