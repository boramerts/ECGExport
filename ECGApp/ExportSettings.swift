//
//  ExportSettings.swift
//  ECGApp
//
//  Created by Bora Mert on 16.10.2026.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "English"
        case .turkish: "Türkçe"
        }
    }
}

enum ECGExportFormat: String, CaseIterable, Identifiable {
    case combinedCSV
    case separateZIP

    var id: String { rawValue }
}

enum SettingsKeys {
    static let language = "appLanguage"
    static let exportFormat = "exportFormat"
    static let showExportSummary = "showExportSummary"
}
