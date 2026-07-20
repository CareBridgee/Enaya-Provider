
protocol SubmitProfileApplicationUseCaseProtocol {
    func execute(_ data: ProfileSetupData) async throws
}

struct SubmitProfileApplicationUseCase: SubmitProfileApplicationUseCaseProtocol {
    private let repository: ProfileSetupRepositoryProtocol

    init(repository: ProfileSetupRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ data: ProfileSetupData) async throws {
        try await repository.submitApplication(data)
    }
}