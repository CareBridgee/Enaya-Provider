//
//  ProfileSetupEndpoint.swift
//  EnayaProvider
//

import Alamofire
import Foundation

enum ProfileSetupEndpoint: Endpoint {
    case updatePersonalInfo(request: UpdatePersonalInfoRequest)
    case registerNurse
    
    var path: String {
        switch self {
        case .updatePersonalInfo:
            return "/api/v1/users/me"
        case .registerNurse:
            return "/api/v1/nurses/register"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .updatePersonalInfo:
            return .put
        case .registerNurse:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .updatePersonalInfo(let request):
            if let data = try? JSONEncoder().encode(request),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return dict
            }
            return nil
        case .registerNurse:
            return nil
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        case .updatePersonalInfo, .registerNurse:
            return .bearer
        }
    }
}
