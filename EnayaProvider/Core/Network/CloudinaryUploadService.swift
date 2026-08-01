//
//  CloudinaryUploadService.swift
//  EnayaProvider
//

import Foundation

protocol MediaUploadServiceProtocol: Sendable {
    func uploadMedia(data: Data, fileName: String, mimeType: String) async throws -> String
}

final class CloudinaryUploadService: MediaUploadServiceProtocol {
    
    // TODO: Replace with your actual Cloudinary Cloud Name and Upload Preset
    private let cloudName = "uy4vxp6c"
    private let uploadPreset = "ios_unsigned_preset"
    
    func uploadMedia(data: Data, fileName: String, mimeType: String) async throws -> String {
        let urlString = "https://api.cloudinary.com/v1_1/\(cloudName)/upload"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add Upload Preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        
        // Add File Data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        // End Boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let (responseData, response) = try await URLSession.shared.upload(for: request, from: body)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        struct CloudinaryResponse: Decodable {
            let secure_url: String
        }
        
        let decodedResponse = try JSONDecoder().decode(CloudinaryResponse.self, from: responseData)
        return decodedResponse.secure_url
    }
}
