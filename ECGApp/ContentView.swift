//
//  ContentView.swift
//  ECGApp
//
//  Created by Bora Mert on 16.10.2026.
//

import SwiftUI
import HealthKit

struct ContentView: View {

    @StateObject private var manager = ECGManager()

    @AppStorage(SettingsKeys.language)
    private var language = AppLanguage.english.rawValue

    @AppStorage(SettingsKeys.exportFormat)
    private var exportFormat = ECGExportFormat.combinedCSV.rawValue

    @AppStorage(SettingsKeys.showExportSummary)
    private var showExportSummary = true

    @State private var selectedIDs: Set<UUID> = []
    @State private var subjectIDs: [UUID: String] = [:]

    @State private var editingRecordingID: UUID?
    @State private var subjectIDInput = ""
    @State private var showSubjectIDEditor = false

    @State private var exportURL: URL?
    @State private var isExporting = false
    @State private var exportError: String?
    @State private var exportSummary = ""
    @State private var showExportAlert = false

    private func t(_ key: String) -> String {
        AppStrings.text(key, language: language)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                if manager.isLoading {
                    ProgressView(t("loading"))
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )

                } else if manager.recordings.isEmpty {
                    ContentUnavailableView(
                        t("noRecordings"),
                        systemImage: "waveform.path.ecg",
                        description: Text(t("noRecordingsDetail"))
                    )
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                } else {
                    recordingList
                }

                exportControls
            }
            .navigationTitle(t("appTitle"))
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {

                    Button {
                        Task {
                            await manager.loadRecordings()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel(t("refresh"))

                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel(t("settings"))
                }
            }
            .task {
                loadSubjectIDs()
                await manager.loadRecordings()
            }
            .onChange(of: exportFormat) { _, _ in
                invalidateExport()
            }
            .alert(
                t("subjectID"),
                isPresented: $showSubjectIDEditor
            ) {
                TextField(
                    t("subjectID"),
                    text: $subjectIDInput
                )
                .autocorrectionDisabled()

                Button(t("save")) {
                    saveSubjectID()
                }

                Button(t("cancel"), role: .cancel) {
                    editingRecordingID = nil
                }

            } message: {
                Text(t("subjectPrompt"))
            }
            .alert(
                t("exportComplete"),
                isPresented: $showExportAlert
            ) {
                Button(t("ok"), role: .cancel) {}
            } message: {
                Text(exportSummary)
            }
            .alert(
                t("exportFailed"),
                isPresented: Binding(
                    get: { exportError != nil },
                    set: { if !$0 { exportError = nil } }
                )
            ) {
                Button(t("ok"), role: .cancel) {}
            } message: {
                Text(exportError ?? "")
            }
            .alert(
                t("healthError"),
                isPresented: Binding(
                    get: { manager.errorMessage != nil },
                    set: { if !$0 { manager.errorMessage = nil } }
                )
            ) {
                Button(t("ok"), role: .cancel) {}
            } message: {
                Text(manager.errorMessage ?? "")
            }
        }
    }

    private var recordingList: some View {
        List {
            Section {
                ForEach(manager.recordings, id: \.uuid) { ecg in
                    HStack(spacing: 12) {

                        Button {
                            toggleSelection(ecg.uuid)
                        } label: {
                            HStack(spacing: 12) {
                                Image(
                                    systemName:
                                        selectedIDs.contains(ecg.uuid)
                                        ? "checkmark.circle.fill"
                                        : "circle"
                                )
                                .font(.title2)
                                .foregroundStyle(
                                    selectedIDs.contains(ecg.uuid)
                                    ? Color.accentColor
                                    : Color.secondary
                                )

                                VStack(
                                    alignment: .leading,
                                    spacing: 5
                                ) {
                                    Text(
                                        ecg.startDate,
                                        format: .dateTime
                                            .year()
                                            .month()
                                            .day()
                                            .hour()
                                            .minute()
                                    )
                                    .font(.headline)

                                    Text(
                                        "\(ecg.numberOfVoltageMeasurements) \(t("samples"))"
                                    )
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                    if let fs = ecg.samplingFrequency {
                                        Text(
                                            "\(fs.doubleValue(for: .hertz()), specifier: "%.1f") Hz"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }

                                    Text(
                                        "\(t("subject")): \(subjectIDs[ecg.uuid] ?? t("notAssigned"))"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer(minLength: 0)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Button {
                            editSubjectID(for: ecg.uuid)
                        } label: {
                            Image(systemName: "pencil")
                                .padding(10)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel(t("editSubject"))
                    }
                }
            } header: {
                HStack {
                    Text(
                        "\(manager.recordings.count) \(t("recordings"))"
                    )

                    Spacer()

                    Button(
                        selectedIDs.count == manager.recordings.count
                        ? t("deselectAll")
                        : t("selectAll")
                    ) {
                        if selectedIDs.count == manager.recordings.count {
                            selectedIDs.removeAll()
                        } else {
                            selectedIDs = Set(
                                manager.recordings.map(\.uuid)
                            )
                        }

                        invalidateExport()
                    }
                    .textCase(nil)
                }
            }
        }
    }

    private var exportControls: some View {
        VStack(spacing: 12) {

            Text("\(selectedIDs.count) \(t("selected"))")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                Task {
                    await exportSelected()
                }
            } label: {
                HStack {
                    if isExporting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Text(
                        isExporting
                        ? t("exporting")
                        : t("export")
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedIDs.isEmpty || isExporting)

            if let exportURL {
                ShareLink(item: exportURL) {
                    Label(
                        t("share"),
                        systemImage: "square.and.arrow.up"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }

    private func toggleSelection(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }

        invalidateExport()
    }

    private func editSubjectID(for id: UUID) {
        editingRecordingID = id
        subjectIDInput = subjectIDs[id] ?? ""
        showSubjectIDEditor = true
    }

    private func saveSubjectID() {
        guard let id = editingRecordingID else {
            return
        }

        let value = subjectIDInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if value.isEmpty {
            subjectIDs.removeValue(forKey: id)
        } else {
            subjectIDs[id] = value
        }

        saveSubjectIDs()
        invalidateExport()
        editingRecordingID = nil
    }

    private func saveSubjectIDs() {
        let stored = Dictionary(
            uniqueKeysWithValues: subjectIDs.map {
                ($0.key.uuidString, $0.value)
            }
        )

        UserDefaults.standard.set(
            stored,
            forKey: "ECGSubjectIDs"
        )
    }

    private func loadSubjectIDs() {
        let stored = UserDefaults.standard.dictionary(
            forKey: "ECGSubjectIDs"
        ) as? [String: String] ?? [:]

        subjectIDs = Dictionary(
            uniqueKeysWithValues: stored.compactMap { key, value in
                guard let uuid = UUID(uuidString: key) else {
                    return nil
                }
                return (uuid, value)
            }
        )
    }

    private func invalidateExport() {
        exportURL = nil
        exportSummary = ""
    }

    private func exportSelected() async {
        guard !isExporting else { return }

        isExporting = true
        exportURL = nil
        exportError = nil
        exportSummary = ""

        defer { isExporting = false }

        let selected = manager.recordings.filter {
            selectedIDs.contains($0.uuid)
        }

        guard selected.count == selectedIDs.count else {
            exportError = "Selection mismatch. Refresh recordings."
            return
        }

        let format = ECGExportFormat(
            rawValue: exportFormat
        ) ?? .combinedCSV

        do {
            let result = try await ECGExporter.export(
                recordings: selected,
                subjectIDs: subjectIDs,
                healthStore: manager.healthStore,
                format: format
            )

            exportURL = result.url

            exportSummary = """
            \(t("exportedCount")): \(result.recordingCount)
            \(t("sampleCount")): \(result.sampleCount.formatted())

            \(t("exportReady"))
            """

            if showExportSummary {
                showExportAlert = true
            }

        } catch {
            exportError = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
