//
//  EarningsRoute.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import Foundation
import SwiftUI

public enum EarningsRoute: Hashable {
    case payouts
}

@MainActor
public final class EarningsCoordinator: ObservableObject {
    @Published public var path = NavigationPath()

    public init() {}

    public func goToPayouts() {
        path.append(EarningsRoute.payouts)
    }

    public func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}