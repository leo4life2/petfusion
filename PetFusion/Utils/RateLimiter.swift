//
//  RateLimiter.swift
//  PetFusion
//
//  Created by Michael Zhu on 2/24/24.
//

import Foundation
import Combine

class RateLimiter: ObservableObject {
    static let shared = RateLimiter()
    private init() {} // Ensures singleton instance

    private let userDefaultsKey = "RateLimiterTimestamps"
    private var timestamps: [Date] {
        get {
            guard let savedTimestamps = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Date] else { return [] }
            return savedTimestamps
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
        }
    }

    // Limit: 20 requests per hour
    let requestLimit = 20
    let timeIntervalLimit: TimeInterval = 3600 // 1 hour in seconds

    // Published property to notify views of changes
    @Published private(set) var requestsLeft: Int = 0

    // MARK: - Public API
    func canAddRequest() -> Bool {
        cleanUpOldRequests()
        return timestamps.count < requestLimit
    }
    
    func addRequest() {
        guard canAddRequest() else { return }
        timestamps.append(Date())
        updateRequestsLeft() // Update the published property
    }
    
    // MARK: - Helpers
    private func cleanUpOldRequests() {
        let now = Date()
        timestamps = timestamps.filter { now.timeIntervalSince($0) < timeIntervalLimit }
        updateRequestsLeft() // Ensure requestsLeft is accurate after cleanup
    }
    
    private func updateRequestsLeft() {
        DispatchQueue.main.async { [self] in
            self.requestsLeft = max(self.requestLimit - timestamps.count, 0)
        }
    }
    
    func timeUntilReset() -> TimeInterval {
        cleanUpOldRequests()
        guard let oldestRequest = timestamps.min() else { return self.timeIntervalLimit }
        let resetTime = oldestRequest.addingTimeInterval(timeIntervalLimit)
        return resetTime.timeIntervalSinceNow
    }
}
