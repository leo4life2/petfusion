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
    func txt2img(prompt: String) async throws -> UIImage {
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

    func img2img(prompt: String, promptimage: UIImage, promptmask: UIImage) async throws -> UIImage {
        var image = promptimage
        var mask = promptmask
        
// uncomment to override with test default images
//        image = UIImage(named: "test_dog")!
//        mask = UIImage(named: "test_dog_mask")!
        
        let width = UInt(image.size.width)
        let height = UInt(image.size.height)
        
        let host = "sd.odam.camp"
        let port = 12345
        guard let url = URL(string: "http://\(host):\(port)/sdapi/v1/img2img") else {
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
        request.timeoutInterval = 60
        
        guard let imageData = image.jpegData(compressionQuality: 0.7)?.base64EncodedString() else {
            throw DiffusionAPIError.invalidImageError
        }
        guard let maskData = mask.jpegData(compressionQuality: 0.7)?.base64EncodedString() else {
            throw DiffusionAPIError.invalidImageError
        }
        
        let inpaint_payload = [
            "prompt": prompt,
            "negative_prompt": "lowres, text, error, cropped, worst quality, low quality, jpeg artifacts, ugly, duplicate, morbid, mutilated, out of frame, extra fingers, mutated hands, poorly drawn hands, poorly drawn face, mutation, deformed, blurry, dehydrated, bad anatomy, bad proportions, extra limbs, cloned face, disfigured, gross proportions, malformed limbs, missing arms, missing legs, extra arms, extra legs, fused fingers, too many fingers, long neck, username, watermark, signature",
            "seed": -1,
            "sampler_name": "Euler a",
            "batch_size": 1,
            "n_iter": 1,
            "steps": 20,
            "cfg_scale": 7,
            "width": width,
            "height": height,
            "denoising_strength": 1.0,
            "include_init_images": true,
            "init_images": [
                imageData
            ],
            "resize_mode": 0,
            "mask_blur": 4,
            "mask": maskData,
            "inpainting_fill": 0,
            "inpainting_mask_invert": 1,
            "alwayson_scripts": [
                "controlnet": [
                    "args": [
                        [
                            "pixel_perfect": true,
                            "control_mode": 2,
                            "guidance_end": 1.0,
                            "guidance_start": 0.0,
                            "weight": 1.0,
                            "model": "control_v11f1e_sd15_tile [a371b31b]",
                        ],
                        [
                            "pixel_perfect": true,
                            "control_mode": 2,
                            "guidance_end": 1.0,
                            "guidance_start": 0.0,
                            "weight": 1.0,
                            "model": "control_v11p_sd15_inpaint [ebff9138]",
                        ]
                    ]
                ]
            ]
        ] as [String : Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: inpaint_payload, options: [])
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
        // for some reason, the JSON is double-encoded - first, let's do one pass to get the string
        // and then re-encode it as utf-8 data
        guard let jsonString = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? String else {
            throw DiffusionAPIError.responseBodyJSONError
        }
        guard let jsonStringData = jsonString.data(using: .utf8) else {
            throw DiffusionAPIError.responseBodyJSONError
        }
        // then, do another pass on the string to get the final JSON dictionary
        guard let jsonObject = try JSONSerialization.jsonObject(with: jsonStringData, options: []) as? [String: Any] else {
            throw DiffusionAPIError.responseBodyJSONError
        }
        guard let imagesArray = jsonObject["images"] as? [String] else {
            throw DiffusionAPIError.responseDataError
        }
        guard let imageString = imagesArray.first else {
            throw DiffusionAPIError.responseDataError
        }
        guard let imageData = Data(base64Encoded: imageString) else {
            throw DiffusionAPIError.responseDataError
        }
        guard let returnedImage = UIImage(data: imageData) else {
            throw DiffusionAPIError.invalidImageError
        }
        return returnedImage
    }
}
