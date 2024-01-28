//
//  DiffusionAPI.swift
//  PetFusion
//
//  Created by fdsa on 2/2/24.
//

import Foundation
import UIKit

enum DiffusionAPIError: Error {
    case invalidURL
    case invalidLoginData
    case requestBodyJSONError(error: Error)
    case URLSessionRequestError(error: Error)
    case badServerResponse
    case responseBodyJSONError
    case responseDataError
    case invalidImageError
}
extension DiffusionAPIError: LocalizedError {
    public var errorDescription: String? {
        return "Failed to fetch the image"
    }
    public var failureReason: String? {
        switch self {
        case .invalidURL:
            return "The provided URL was invalid"
        case .invalidLoginData:
            return "The provided username/password was invalid"
        case .requestBodyJSONError(let error):
            return "While constructing the request, received error: \(error)"
        case .URLSessionRequestError(let error):
            return "Server returned error: \(error)"
        case .badServerResponse:
            return "The server responded with an error code"
        case .responseBodyJSONError:
            return "Could not decode the response"
        case .responseDataError:
            return "The response contains invalid parameters"
        case .invalidImageError:
            return "An image could not be constructed from the returned data"
        }
    }
    public var recoverySuggestion: String? {
        return "Please try again"
    }
}

struct DiffusionAPI {
    
    func img2img(prompt: String) async throws -> UIImage {
        let payload = [
            "prompt": "cinematic still, medium shot on ARRI Alexa 35, futuristic NYC sunset with a polar bear chilling on a chair, low-key color grading, hyper-realistic pop, cyberpunk, Chicago 2087",
            "negative_prompt": "(deformed iris, deformed pupils), text, worst quality, low quality, jpeg artifacts, ugly, duplicate, morbid, mutilated, (extra fingers), (mutated hands), poorly drawn hands, poorly drawn face, mutation, deformed, blurry, dehydrated, bad anatomy, bad proportions, extra limbs, cloned face, disfigured, gross proportions, malformed limbs, missing arms, missing legs, extra arms, extra legs, (fused fingers), (too many fingers), long neck, camera",
            "sampler_index": "Euler",
            "steps": 20,
            "width": 960,
            "height": 540,
            "cfg_scale": 8,
            "seed": -1
        ] as [String: Any]
        
        let host = "sd.odam.camp"
        let port = 12345
        guard let url = URL(string: "http://\(host):\(port)/sdapi/v1/txt2img") else {
            throw DiffusionAPIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let username = "petfusion"
        let password = "allyoufeedmearepoffins"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: .utf8) else {
            throw DiffusionAPIError.invalidLoginData
        }
        let base64LoginString = loginData.base64EncodedString()
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            throw DiffusionAPIError.requestBodyJSONError(error: error)
        }

        // Perform the request
        var data: Data
        var response: URLResponse
        do {
            let (tmpdata, tmpresponse) = try await URLSession.shared.data(for: request)
            data = tmpdata
            response = tmpresponse
        } catch {
            throw DiffusionAPIError.URLSessionRequestError(error: error)
        }

        // Check for HTTP status code and response data
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw DiffusionAPIError.badServerResponse
        }
        
        // Decode the JSON response into a [String: Any] dictionary
        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw DiffusionAPIError.responseBodyJSONError
        }
        guard let imagesArray = jsonObject["images"] as? [Data] else {
            throw DiffusionAPIError.responseDataError
        }
        guard let imageData = imagesArray.first else {
            throw DiffusionAPIError.responseDataError
        }
        guard let returnedImage = UIImage(data: imageData) else {
            throw DiffusionAPIError.invalidImageError
        }
        return returnedImage
    }

}
