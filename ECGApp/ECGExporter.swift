


import Foundation
import HealthKit
import ZIPFoundation

struct ECGExportResult {
    let url: URL
    let recordingCount: Int
    let sampleCount: Int
}

enum ECGExportError: LocalizedError {
    case noRecordings
    case emptyRecording(String)

    var errorDescription: String? {
        switch self {
        case .noRecordings:
            return "No ECG recordings selected."
        case .emptyRecording(let id):
            return "No voltage measurements found for ECG \(id)."
        }
    }
}

enum ECGExporter {

    static func export(
        recordings: [HKElectrocardiogram],
        subjectIDs: [UUID: String],
        healthStore: HKHealthStore,
        format: ECGExportFormat
    ) async throws -> ECGExportResult {

        guard !recordings.isEmpty else {
            throw ECGExportError.noRecordings
        }

        let fileManager = FileManager.default
        let folder = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try fileManager.createDirectory(
            at: folder,
            withIntermediateDirectories: true
        )

        let header = "subject_id,recording_id,recording_date,sampling_frequency_hz,time_s,voltage_mV"

        var combinedRows = [header]
        var totalSamples = 0

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        for (index, ecg) in recordings.enumerated() {

            let subjectID = subjectIDs[ecg.uuid] ?? ""
            let recordingID = ecg.uuid.uuidString
            let date = dateFormatter.string(from: ecg.startDate)

            let fs = ecg.samplingFrequency?
                .doubleValue(for: .hertz()) ?? 0

            let descriptor = HKElectrocardiogramQueryDescriptor(ecg)

            var recordingRows = [header]
            var sampleCount = 0

            for try await measurement in descriptor.results(
                for: healthStore
            ) {
                guard let quantity = measurement.quantity(
                    for: .appleWatchSimilarToLeadI
                ) else {
                    continue
                }

                let voltage = quantity.doubleValue(
                    for: .voltUnit(with: .milli)
                )

                let time = measurement.timeSinceSampleStart

                let row = [
                    csvField(subjectID),
                    csvField(recordingID),
                    csvField(date),
                    String(fs),
                    String(time),
                    String(voltage)
                ].joined(separator: ",")

                recordingRows.append(row)
                sampleCount += 1
            }

            guard sampleCount > 0 else {
                throw ECGExportError.emptyRecording(recordingID)
            }

            totalSamples += sampleCount

            if format == .combinedCSV {
                combinedRows.append(
                    contentsOf: recordingRows.dropFirst()
                )
            } else {
                let filename = String(
                    format: "ECG_%03d.csv",
                    index + 1
                )

                let fileURL = folder.appendingPathComponent(filename)

                try writeCSV(recordingRows, to: fileURL)
            }

            print(
                "Exported ECG \(index + 1)/\(recordings.count): \(sampleCount) samples"
            )
        }

        let outputURL: URL

        if format == .combinedCSV {
            outputURL = fileManager.temporaryDirectory
                .appendingPathComponent(
                    "AppleWatch_ECG_\(UUID().uuidString).csv"
                )

            try writeCSV(combinedRows, to: outputURL)

        } else {
            outputURL = fileManager.temporaryDirectory
                .appendingPathComponent(
                    "AppleWatch_ECG_\(UUID().uuidString).zip"
                )

            try fileManager.zipItem(
                at: folder,
                to: outputURL
            )

            try? fileManager.removeItem(at: folder)
        }

        return ECGExportResult(
            url: outputURL,
            recordingCount: recordings.count,
            sampleCount: totalSamples
        )
    }

    private static func writeCSV(
        _ rows: [String],
        to url: URL
    ) throws {
        try rows.joined(separator: "\n")
            .appending("\n")
            .write(
                to: url,
                atomically: true,
                encoding: .utf8
            )
    }

    private static func csvField(_ value: String) -> String {
        let escaped = value.replacingOccurrences(
            of: "\"",
            with: "\"\""
        )
        return "\"\(escaped)\""
    }
}
