//
//  NurseOfferHistoryMapper.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 14/08/2026.
//


import Foundation

enum NurseServiceRequestHistoryMapper {
    static func map(_ dto: NurseServiceRequestHistoryDTO) -> NurseServiceRequestHistoryItem {
        NurseServiceRequestHistoryItem(
            id: dto.serviceRequestId,
            serviceTypeId: dto.serviceTypeId,
            serviceName: dto.serviceName,
            estimatedDurationMinutes: dto.estimatedDurationMinutes,
            patientProfileId: dto.patientProfileId,
            patientFullName: fullName(first: dto.patientFirstName, last: dto.patientLastName),
            patientPhoneNumber: dto.patientPhoneNumber,
            patientProfileImageUrl: dto.patientProfileImageUrl,
            serviceDescription: dto.serviceDescription,
            dateText: formattedDateText(date: dto.preferredDate, time: dto.preferredTime),
            status: dto.status,
            estimatedPrice: dto.estimatedPrice.map{Decimal($0)},
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
    }

    private static func fullName(first: String?, last: String?) -> String {
        let name = [first, last].compactMap { $0 }.joined(separator: " ").trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Unknown Patient" : name
    }

    private static func formattedDateText(date: String?, time: String?) -> String {
        let dateText = formattedDate(date)
        let timeText = formattedTime(time)

        switch (dateText, timeText) {
        case let (d?, t?): return "\(d) • \(t)"
        case let (d?, nil): return d
        case let (nil, t?): return t
        default: return "Flexible Schedule"
        }
    }

    private static func formattedDate(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: raw) else { return raw }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        return outputFormatter.string(from: date)
    }

    private static func formattedTime(_ raw: String?) -> String? {
        guard let raw else { return nil }

        // API returns "HH:mm:ss"; fall back to "HH:mm" just in case.
        for format in ["HH:mm:ss", "HH:mm"] {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = format
            if let date = inputFormatter.date(from: raw) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "h:mm a"
                return outputFormatter.string(from: date)
            }
        }
        return raw
    }
}
