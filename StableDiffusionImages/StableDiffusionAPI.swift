//
//  StableDiffusionAPI.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/21/23.
//

import Foundation
import SwiftUI
import OSLog
import AWSS3
//import AWSClientRuntime
import ClientRuntime

enum StableDiffusionAPIError: Error {
    case unknownError(Error?)
    case invalidURL(String)
    case networkingError(Error?)
    case invalidRequest
    case invalidResponse
    case noData
    case imageDataConversionError
}

struct StableDiffusionAPI {

    let INPAINT_ENDPOINT = URL(string: "https://stablediffusionapi.com/api/v3/inpaint")!
    let IMG2IMG_ENDPOINT = URL(string: "https://stablediffusionapi.com/api/v3/img2img")!
    let UPLOAD_ENDPOINT = URL(string: "https://filebin.net/MyTestApp1234Hello/")!
    let S3_BUCKET_NAME = "nemos-sd-app"
    let logger = Logger()

    private func downloadImage(from url: URL) async throws -> UIImage {
        self.logger.log("\(#function) making request \(url)")
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw StableDiffusionAPIError.imageDataConversionError
        }
        return image
    }

    private func fetchQueuedImageURL(from url: URL, delay: TimeInterval, currentRetries: UInt, maxRetries: UInt) async throws -> URL {
        let settings = try await UserSettings.shared()
        if (currentRetries >= maxRetries) {
            self.logger.error("\(#function) reached maxRetries limit")
            throw StableDiffusionAPIError.unknownError(nil)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any?] = [
            "key": settings.apiKey
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        self.logger.log("\(#function) making request \(request)")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            self.logger.log("\(#function) invalid HTTP response: \(response)")
            throw StableDiffusionAPIError.invalidResponse
        }
        guard let responseData = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            self.logger.log("\(#function) invalid response body: \(response)")
            throw StableDiffusionAPIError.invalidResponse
        }
        guard let status = responseData["status"] as? String else {
            self.logger.log("\(#function) invalid response data, missing status: \(responseData)")
            throw StableDiffusionAPIError.invalidResponse
        }
        self.logger.log("\(#function) fetched response data: \(responseData)")
        if status == "success" {
            var output: String? = responseData["output"] as? String
            if output == nil {
                output = (responseData["output"] as? [String])?.first
            }
            guard let output = output, let outputURL = URL(string: output) else {
                throw StableDiffusionAPIError.noData
            }
            return outputURL
        } else if status == "processing" {
            return try await Task {
                try await Task.sleep(until: .now + .seconds(delay), clock: .continuous)
                return try await self.fetchQueuedImageURL(from: url, delay: delay, currentRetries: currentRetries + 1, maxRetries: maxRetries)
            }.value
        } else {
            // failed
            throw StableDiffusionAPIError.unknownError(nil)
        }
    }
    
    private func uploadImageToS3(name: String, image: UIImage) async throws -> URL {
        let client = try S3Client(region: "us-east-1")
        let putObjectInput = PutObjectInput(
            body: ByteStream.from(data: image.jpegData(compressionQuality: 0.5)!),
            bucket: self.S3_BUCKET_NAME,
            key: name
        )
        let _ = try await client.putObject(input: putObjectInput)
        guard let url = URL(string: "https://\(self.S3_BUCKET_NAME).s3.amazonaws.com/\(name)") else {
            throw StableDiffusionAPIError.unknownError(nil)
        }
        return url
    }
    
    private func downloadImageFromS3(name: String) async throws -> UIImage {
        let client = try S3Client(region: "us-east-1")
        let getObjectInput = GetObjectInput(
            bucket: self.S3_BUCKET_NAME,
            key: name
        )
        let output = try await client.getObject(input: getObjectInput)
        guard let data = try await output.body?.readData() else {
            throw StableDiffusionAPIError.unknownError(nil)
        }
        guard let image = UIImage(data: data) else {
            throw StableDiffusionAPIError.unknownError(nil)
        }
        return image
    }

    private func uploadImageToTemporaryStorage(name: String, image: UIImage) async throws -> URL {
        guard let pngData = image.pngData() else {
            self.logger.error("\(#function) could not convert image to png")
            throw StableDiffusionAPIError.imageDataConversionError
        }

        let url = URL(string: self.UPLOAD_ENDPOINT.absoluteString + name)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        self.logger.log("\(#function) making request \(request)")

        let (_, response) = try await URLSession.shared.upload(for: request, from: pngData)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            self.logger.error("\(#function) upload server responded with invalid response: \(response)")
            throw StableDiffusionAPIError.invalidResponse
        }
        return url
    }

    private func fetchIMG2IMGUrl(image: UIImage, imageURL: URL, positivePrompt: String, negativePrompt: String) async throws -> URL {
        let settings = try await UserSettings.shared()
        var request = URLRequest(url: self.IMG2IMG_ENDPOINT)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any?] = [
            "key": settings.apiKey,
            "prompt": positivePrompt,
            "negative_prompt": negativePrompt,
            "init_image": settings.useDefaultImage ? "https://raw.githubusercontent.com/CompVis/stable-diffusion/main/data/inpainting_examples/overture-creations-5sI6fQgYIuo.png" : imageURL.absoluteString,
            "width": "\(image.size.width)",
            "height": "\(image.size.height)",
            "samples": "1",
            "num_inference_steps": "30",
            "safety_checker": "no",
            "enhance_prompt": String(settings.enhancePrompt),
            "guidance_scale": 7.5,
            "strength": settings.promptStrength,
            "seed": nil,
            "webhook": nil,
            "track_id": nil
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        self.logger.log("\(#function) making request \(request)")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            self.logger.error("\(#function) invalid HTTP response \(response)")
            throw StableDiffusionAPIError.invalidResponse
        }
        guard let responseData = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            self.logger.error("\(#function) invalid HTTP response data \(response)")
            throw StableDiffusionAPIError.invalidResponse
        }
        self.logger.error("\(#function) received response data \(responseData)")
        guard let status = responseData["status"] as? String else {
            self.logger.error("\(#function) invalid response status \(responseData)")
            throw StableDiffusionAPIError.invalidResponse
        }
        var output: String? = responseData["output"] as? String
        if output == nil {
            output = (responseData["output"] as? [String])?.first
        }
        if status == "success" {
            guard let output = output, let outputURL = URL(string: output) else {
                throw StableDiffusionAPIError.noData
            }
            return outputURL
        } else if status == "processing" {
            guard let fetchResult = responseData["fetch_result"] as? String, let fetchResultURL = URL(string: fetchResult) else {
                throw StableDiffusionAPIError.noData
            }
            return try await self.fetchQueuedImageURL(from: fetchResultURL, delay: 5.0, currentRetries: 0, maxRetries: 8)
        } else {
            // failed
            throw StableDiffusionAPIError.unknownError(nil)
        }
    }

    private func fetchInpaintUrl(image: UIImage, maskURL: URL, imageURL: URL, positivePrompt: String, negativePrompt: String) async throws -> URL {
        let settings = try await UserSettings.shared()
        var request = URLRequest(url: self.INPAINT_ENDPOINT)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any?] = [
            "key": settings.apiKey,
            "prompt": positivePrompt,
            "negative_prompt": negativePrompt,
            "init_image": settings.useDefaultImage ?  "https://raw.githubusercontent.com/CompVis/stable-diffusion/main/data/inpainting_examples/overture-creations-5sI6fQgYIuo.png" : imageURL.absoluteString,
            "mask_image": settings.useDefaultImage ?  "https://raw.githubusercontent.com/CompVis/stable-diffusion/main/data/inpainting_examples/overture-creations-5sI6fQgYIuo_mask.png" : maskURL.absoluteString,
            "width": "\(image.size.width)",
            "height": "\(image.size.height)",
            "samples": "1",
            "num_inference_steps": "30",
            "safety_checker": "no",
            "enhance_prompt": String(settings.enhancePrompt),
            "guidance_scale": 7.5,
            "strength": settings.promptStrength,
            "seed": nil,
            "webhook": nil,
            "track_id": nil
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        self.logger.log("\(#function) making request \(request)")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            self.logger.error("\(#function) invalid HTTP response \(response)")
            throw StableDiffusionAPIError.invalidResponse
        }
        guard let responseData = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            self.logger.error("\(#function) invalid HTTP response data \(response)")
            throw StableDiffusionAPIError.invalidResponse
        }
        self.logger.error("\(#function) received response data \(responseData)")
        guard let status = responseData["status"] as? String else {
            self.logger.error("\(#function) invalid response status \(responseData)")
            throw StableDiffusionAPIError.invalidResponse
        }
        var output: String? = responseData["output"] as? String
        if output == nil {
            output = (responseData["output"] as? [String])?.first
        }
        if status == "success" {
            guard let output = output, let outputURL = URL(string: output) else {
                throw StableDiffusionAPIError.noData
            }
            return outputURL
        } else if status == "processing" {
            guard let fetchResult = responseData["fetch_result"] as? String, let fetchResultURL = URL(string: fetchResult) else {
                throw StableDiffusionAPIError.noData
            }
            return try await self.fetchQueuedImageURL(from: fetchResultURL, delay: 5.0, currentRetries: 0, maxRetries: 8)
        } else {
            // failed
            throw StableDiffusionAPIError.unknownError(nil)
        }
    }

    func img2img(image: UIImage, positivePrompt: String, negativePrompt: String) async throws -> UIImage {
        let imageName = UUID().uuidString + ".png"
//        let url = try await self.uploadImageToTemporaryStorage(name: imageName, image: image)
        let url = try await self.uploadImageToS3(name: imageName, image: image)
        let generatedImageURL = try await self.fetchIMG2IMGUrl(image: image, imageURL: url, positivePrompt: positivePrompt, negativePrompt: negativePrompt)
        return try await self.downloadImage(from: generatedImageURL)
    }

    func inpaint(image: UIImage, mask: UIImage, positivePrompt: String, negativePrompt: String) async throws -> UIImage {
        let imageName = UUID().uuidString + ".png"
//        let url = try await self.uploadImageToTemporaryStorage(name: imageName, image: image)
        let url = try await self.uploadImageToS3(name: imageName, image: image)
        let maskImageName = UUID().uuidString + ".png"
        let maskUrl = try await self.uploadImageToTemporaryStorage(name: maskImageName, image: mask)
        let generatedImageURL = try await self.fetchInpaintUrl(image: image, maskURL: maskUrl, imageURL: url, positivePrompt: positivePrompt, negativePrompt: negativePrompt)
        return try await self.downloadImage(from: generatedImageURL)
    }
}
