//
//  ChatEndpoint.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//

import Foundation
import Alamofire

enum ChatEndpoint: Endpoint {
    case getHistory(reservationId: String)
    case sendMessage(reservationId: String, payload: SendMessageRequestDTO)
    
    var path: String {
        switch self {
        case .getHistory(let id), .sendMessage(let id, _):
            return "/api/v1/reservations/\(id)/messages"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getHistory: return .get
        case .sendMessage: return .post
        }
    }
    
    var parameters: Alamofire.Parameters? {
        switch self {
        case .getHistory: return nil
        case .sendMessage(_, let payload):
            return ["content": payload.content]
        }
    }
}
