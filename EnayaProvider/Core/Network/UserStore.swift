import Foundation

protocol UserStoring: Sendable {
    func saveUser(_ user: UserDTO)
    func getUser() -> UserDTO?
    func clearUser()
}

final class UserDefaultsUserStore: UserStoring, @unchecked Sendable {
    private let defaults = UserDefaults.standard
    private let userKey = "saved_user_session_key"
    
    func saveUser(_ user: UserDTO) {
        if let encodedData = try? JSONEncoder().encode(user) {
            defaults.set(encodedData, forKey: userKey)
        }
    }
    
    func getUser() -> UserDTO? {
        guard let data = defaults.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(UserDTO.self, from: data)
    }
    
    func clearUser() {
        defaults.removeObject(forKey: userKey)
    }
}
