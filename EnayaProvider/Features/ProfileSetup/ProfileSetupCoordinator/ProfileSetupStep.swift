import Foundation

enum ProfileSetupStep: CaseIterable {
    case personalInfo
    case professionalInfo
    case providedServices
    case review
}

extension ProfileSetupStep {

    var next: ProfileSetupStep? {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self), all.index(after: index) < all.endIndex else { return nil }
        return all[all.index(after: index)]
    }

    var previous: ProfileSetupStep? {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self), index > all.startIndex else { return nil }
        return all[all.index(before: index)]
    }

    var isFirst: Bool { self == Self.allCases.first }
    var isLast: Bool { self == Self.allCases.last }

    var stepTitle: String {
        switch self {
        case .personalInfo: return "Personal Info"
        case .professionalInfo: return "Professional Info"
        case .providedServices: return "Services"
        case .review: return "Review"
        }
    }
}
