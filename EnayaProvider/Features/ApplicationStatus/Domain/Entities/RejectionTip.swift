import Foundation

struct RejectionTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

struct DocumentRejection {
    let documentName: String
    let reason: String
    let tips: [RejectionTip]
}