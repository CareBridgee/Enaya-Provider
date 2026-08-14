//
//  ProfileEndpoint.swift
//  EnayaProvider
//
//  Created by AI.
//

import Alamofire
import Foundation

enum ProfileEndpoint: Endpoint {
    case getProfile(id: String)
    case updateProfile(id: String)
    case getReviews(id: String, page: Int, size: Int)

    var path: String {
        switch self {
        case .getProfile(let id), .updateProfile(let id):
            return "/api/v1/nurses/\(id)"
        case .getReviews(let id, _, _):
            return "/api/v1/nurses/\(id)/reviews"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getProfile, .getReviews:
            return .get
        case .updateProfile:
            return .put
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getReviews(_, let page, let size):
            return [
                "page": page,
                "size": size
            ]
        default:
            return nil
        }
    }

    var authorizationType: AuthorizationType {
        return .bearer
    }
}
