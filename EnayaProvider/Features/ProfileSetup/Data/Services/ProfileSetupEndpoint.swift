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
    case updateUserProfile(request: UpdateProfileRequestDTO)
    case registerNurse
    case addNurseService(nurseId: String, request: NurseServiceRequestDTO)
    case uploadDocument
    
    var path: String {
        switch self {
        case .getServiceTypes:
            return "/api/v1/service-types"
        case .updateUserProfile:
            return "/api/v1/users/me"
        case .registerNurse:
            return "/api/v1/nurses/register"
        case .addNurseService(let nurseId, _):
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
        case .getServiceTypes, .registerNurse, .uploadDocument:
            return nil
        case .updateUserProfile(let request):
            var params: [String: Any] = [
                "firstName": request.firstName,
                "lastName": request.lastName
            ]
            if let email = request.email { params["email"] = email }
            if let dob = request.dateOfBirth { params["dateOfBirth"] = dob }
            if let gender = request.gender { params["gender"] = gender }
            if let url = request.profileImageUrl { params["profileImageUrl"] = url }
            return params
        case .addNurseService(_, let request):
            return ["serviceTypeId": request.serviceTypeId]
        }
    }
    
    var authorizationType: AuthorizationType {
        return .bearer
    }
}
