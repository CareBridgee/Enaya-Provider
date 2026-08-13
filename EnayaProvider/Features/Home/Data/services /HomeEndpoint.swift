//
//  HomeEndpoint.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//


import Foundation
import Alamofire

enum HomeEndpoint: Endpoint {
    case getNurseInfo(nurseId: String)
    case getUserMe
    case submitOffer(request: NurseOfferRequestDTO)
    case cancelOffer(offerId: String)
    case getNearbyServiceRequests
    case getServiceRequestPreview(serviceRequestId: String)
    case getServiceRequestProfile(serviceRequestId: String)
    case getCurrentActiveVisit

    var path: String {
        switch self {
        case .getNurseInfo(let nurseId): return "/api/v1/nurses/\(nurseId)"
        case .getUserMe: return "/api/v1/users/me"
        case .submitOffer: return "/api/v1/nurse-offers"
        case .cancelOffer(let offerId): return "/api/v1/nurse-offers/\(offerId)"
        case .getNearbyServiceRequests: return "/api/v1/service-requests/nearby"
        case .getServiceRequestPreview(let id): return "/api/v1/service-requests/\(id)/preview"
        case .getServiceRequestProfile(let id): return "/api/v1/service-requests/\(id)/profile"
        case .getCurrentActiveVisit: return "/api/v1/service-requests/current"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getNurseInfo, .getUserMe, .getNearbyServiceRequests, .getServiceRequestPreview, .getServiceRequestProfile, .getCurrentActiveVisit:
            return .get
        case .submitOffer:
            return .post
        case .cancelOffer:
            return .delete
        }
    }

    var parameters: Parameters? {
        switch self {
        case .submitOffer(let request):
            if let data = try? JSONEncoder().encode(request),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return dict
            }
            return nil
        default: return nil
        }
    }
}
