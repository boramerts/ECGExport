//
//  SettingsView.swift
//  ECGApp
//
//  Created by Bora Mert on 16.10.2026.
//


import SwiftUI

struct SettingsView: View {

    @AppStorage(SettingsKeys.language)
    private var language = AppLanguage.english.rawValue

    @AppStorage(SettingsKeys.exportFormat)
    private var exportFormat = ECGExportFormat.combinedCSV.rawValue

    @AppStorage(SettingsKeys.showExportSummary)
    private var showExportSummary = true

    private func t(_ key: String) -> String {
        AppStrings.text(key, language: language)
    }

    var body: some View {
        Form {

            Section {
                Picker(
                    t("language"),
                    selection: $language
                ) {
                    ForEach(AppLanguage.allCases) { item in
                        Text(item.title)
                            .tag(item.rawValue)
                    }
                }
            } header: {
                Label(
                    t("language"),
                    systemImage: "globe"
                )
            }

            Section {
                Picker(
                    t("exportFormat"),
                    selection: $exportFormat
                ) {
                    Text(t("combinedCSV"))
                        .tag(ECGExportFormat.combinedCSV.rawValue)

                    Text(t("separateZIP"))
                        .tag(ECGExportFormat.separateZIP.rawValue)
                }
                .pickerStyle(.inline)
                .labelsHidden()

            } header: {
                Label(
                    t("exportFormat"),
                    systemImage: "square.and.arrow.up"
                )
            }

            Section {
                Toggle(
                    t("showSummary"),
                    isOn: $showExportSummary
                )
            }

            Section {
                NavigationLink {
                    AboutView()
                } label: {
                    Label(
                        t("about"),
                        systemImage: "info.circle"
                    )
                }
            }
        }
        .navigationTitle(t("settings"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AboutView: View {

    @AppStorage(SettingsKeys.language)
    private var language = AppLanguage.english.rawValue

    private func t(_ key: String) -> String {
        AppStrings.text(key, language: language)
    }

    private var appVersion: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "1.0"
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 48))
                        .foregroundStyle(.tint)

                    Text("ECG Exporter")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(t("aboutDescription"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }

            Section {
                LabeledContent(
                    t("version"),
                    value: appVersion
                )
            }

            Section {
                Text(t("privacyDescription"))
                    .font(.subheadline)
            }
            Section {
                Link(
                    t("privacyPolicy"),
                    destination: URL(
                        string: language == "tr"
                            ? "YOUR_TURKISH_GIST_URL"
                            : "YOUR_ENGLISH_GIST_URL"
                    )!
                )
            }
        }
        .navigationTitle(t("about"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
