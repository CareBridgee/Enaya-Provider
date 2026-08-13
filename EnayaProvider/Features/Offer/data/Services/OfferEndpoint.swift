//
//  OfferEndpoint.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 08/08/2026.
//


import Foundation
import Alamofire

enum OfferEndpoint: Endpoint {
    case getRequestDetails(serviceRequestId: String)
    case cancelServiceRequest(serviceRequestId: String)
    case startVisit(serviceRequestId: String)
    case completeVisit(serviceRequestId: String, visitCode: String)
    case getServiceRequestProfile(serviceRequestId: String)
    
    var path: String {
        switch self {
        case .getRequestDetails(let id): return "/api/v1/service-requests/\(id)"
        case .cancelServiceRequest(let id): return "/api/v1/service-requests/\(id)/cancel"
        case .startVisit(let id): return "/api/v1/service-requests/\(id)/start"
        case .completeVisit(let id, _): return "/api/v1/service-requests/\(id)/complete"
        case .getServiceRequestProfile(let id): return "/api/v1/service-requests/\(id)/profile"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getRequestDetails, .getServiceRequestProfile: return .get
        case .cancelServiceRequest: return .patch
        case .startVisit, .completeVisit: return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .completeVisit(_, let visitCode):
            return ["visitCode": visitCode]
        default:
            return nil
        }
    }
}
