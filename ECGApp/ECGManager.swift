//
//  ECGManager.swift
//  ECGApp
//
//  Created by Bora Mert on 16.10.2026.
//

import Foundation
import HealthKit
import Combine

@MainActor
final class ECGManager: ObservableObject {

    @Published var recordings: [HKElectrocardiogram] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let healthStore = HKHealthStore()

    func loadRecordings() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available on this device."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let ecgType = HKObjectType.electrocardiogramType()

        do {
            try await healthStore.requestAuthorization(
                toShare: [],
                read: [ecgType]
            )

            let samples = try await fetchRecordings()

            recordings = samples.sorted {
                $0.startDate > $1.startDate
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func fetchRecordings() async throws
        -> [HKElectrocardiogram] {

        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<
                [HKElectrocardiogram], Error
            >) in

            let query = HKSampleQuery(
                sampleType: HKObjectType.electrocardiogramType(),
                predicate: nil,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let ecgs = samples as? [HKElectrocardiogram] ?? []

                continuation.resume(returning: ecgs)
            }

            healthStore.execute(query)
        }
    }
}

