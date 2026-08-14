//
//  NurseOfferHistoryItem.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 14/08/2026.
//
//  NOTE: file name kept for project-reference stability; this now models
//  a nurse's service-request history entry (GET /api/v1/service-requests/nurse/history),
//  not a price offer.
//

import Foundation

/// Status of a service request as returned by GET /api/v1/service-requests/nurse/history.
/// `unknown` is a safe fallback so the app never crashes decoding a status
/// value the client doesn't recognize yet.
public enum NurseServiceRequestStatus: String, Equatable, Decodable {
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case rejected = "REJECTED"
    case cancelled = "CANCELLED"
    case expired = "EXPIRED"
    case unknown

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = NurseServiceRequestStatus(rawValue: raw) ?? .unknown
    }

    public var displayText: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .rejected: return "Rejected"
        case .cancelled: return "Cancelled"
        case .expired: return "Expired"
        case .unknown: return "Unknown"
        }
    }
}

public struct NurseServiceRequestHistoryItem: Identifiable, Equatable {
    public let id: String
    public let serviceTypeId: String
    public let serviceName: String
    public let estimatedDurationMinutes: Int?
    public let patientProfileId: String
    public let patientFullName: String
    public let patientPhoneNumber: String?
    public let patientProfileImageUrl: String?
    public let serviceDescription: String?
    public let dateText: String
    public let status: NurseServiceRequestStatus
    public let estimatedPrice: Decimal?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        serviceTypeId: String,
        serviceName: String,
        estimatedDurationMinutes: Int?,
        patientProfileId: String,
        patientFullName: String,
        patientPhoneNumber: String?,
        patientProfileImageUrl: String?,
        serviceDescription: String?,
        dateText: String,
        status: NurseServiceRequestStatus,
        estimatedPrice: Decimal?,
        createdAt: Date?,
        updatedAt: Date?
    ) {
        self.id = id
        self.serviceTypeId = serviceTypeId
        self.serviceName = serviceName
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.patientProfileId = patientProfileId
        self.patientFullName = patientFullName
        self.patientPhoneNumber = patientPhoneNumber
        self.patientProfileImageUrl = patientProfileImageUrl
        self.serviceDescription = serviceDescription
        self.dateText = dateText
        self.status = status
        self.estimatedPrice = estimatedPrice
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
