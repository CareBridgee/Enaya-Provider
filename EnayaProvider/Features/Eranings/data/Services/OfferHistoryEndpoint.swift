//
//  OfferHistoryEndpoint.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 14/08/2026.
//
//  (file name kept for project-reference stability)
//

import Foundation
import Alamofire

enum NurseHistoryEndpoint: Endpoint {
    case getHistory

    var path: String {
        switch self {
        case .getHistory:
            return "/api/v1/service-requests/nurse/history"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getHistory:
            return .get
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getHistory:
            return nil
        }
    }
}
