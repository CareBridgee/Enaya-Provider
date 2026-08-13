//
//  ProfileSetupEndpoint.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation
import Alamofire

enum ProfileSetupEndpoint: Endpoint {
    case getServiceTypes
    case updateUserProfile
    case registerNurse
    case addNurseService(nurseId: String)
    case uploadDocument
    
    var path: String {
        switch self {
        case .getServiceTypes:
            return "/api/v1/service-types"
        case .updateUserProfile:
            return "/api/v1/users/me"
        case .registerNurse:
            return "/api/v1/nurses/register"
        case .addNurseService(let nurseId):
            return "/api/v1/nurses/\(nurseId)/services"
        case .uploadDocument:
            return "/api/v1/upload"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getServiceTypes:
            return .get
        case .updateUserProfile:
            return .put
        case .registerNurse, .uploadDocument:
            return .post
        case .addNurseService:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getServiceTypes, .registerNurse, .uploadDocument, .updateUserProfile, .addNurseService:
            return nil
        }
    }
    
    var authorizationType: AuthorizationType {
        return .bearer
    }
}
