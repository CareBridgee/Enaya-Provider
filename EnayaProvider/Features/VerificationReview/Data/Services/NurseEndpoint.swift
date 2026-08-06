//
//  NurseEndpoint.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Alamofire
import Foundation

enum NurseEndpoint: Endpoint {
    case getNurse(id: String)

    var path: String {
        switch self {
        case .getNurse(let id):
            return "/api/v1/nurses/\(id)"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: Parameters? {
        return nil
    }

    var authorizationType: AuthorizationType {
        return .bearer
    }
}
