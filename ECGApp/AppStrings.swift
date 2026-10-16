//
//  AppStrings.swift
//  ECGApp
//
//  Created by Bora Mert on 16.10.2026.
//

import Foundation

enum AppStrings {

    static func text(
        _ key: String,
        language: String
    ) -> String {

        let translations: [String: (String, String)] = [
            "privacyPolicy": (
                "Privacy Policy",
                "Gizlilik Politikası"
            ),
            "contact": (
                "Contact",
                "İletişim"
            ),
            "settings": ("Settings", "Ayarlar"),
            "language": ("Language", "Dil"),
            "exportFormat": ("Export Format", "Dışa Aktarma Biçimi"),
            "combinedCSV": ("Combined CSV", "Birleştirilmiş CSV"),
            "separateZIP": ("Separate CSV files (ZIP)", "Ayrı CSV dosyaları (ZIP)"),
            "showSummary": ("Show Export Summary", "Dışa Aktarma Özetini Göster"),
            "about": ("About", "Hakkında"),
            "version": ("Version", "Sürüm"),
            "aboutDescription": (
                "Export previously recorded Apple Watch ECG voltage measurements for signal analysis.",
                "Önceden kaydedilmiş Apple Watch EKG voltaj ölçümlerini sinyal analizi için dışa aktarın."
            ),
            "privacyDescription": (
                "ECG data is processed locally. No data is uploaded to a server.",
                "EKG verileri cihazda işlenir. Hiçbir veri sunucuya yüklenmez."
            ),
            "appTitle": ("ECG Exporter", "EKG Aktarıcı"),
            "refresh": ("Refresh", "Yenile"),
            "noRecordings": ("No ECG Recordings", "EKG Kaydı Bulunamadı"),
            "noRecordingsDetail": (
                "No accessible ECG recordings were found. Check Health permissions.",
                "Erişilebilir EKG kaydı bulunamadı. Sağlık izinlerini kontrol edin."
            ),
            "loading": ("Loading ECG recordings...", "EKG kayıtları yükleniyor..."),
            "recordings": ("Recordings", "Kayıtlar"),
            "selectAll": ("Select All", "Tümünü Seç"),
            "deselectAll": ("Deselect All", "Seçimi Kaldır"),
            "samples": ("samples", "örnek"),
            "selected": ("recording(s) selected", "kayıt seçildi"),
            "export": ("Export Selected ECGs", "Seçilen EKG'leri Dışa Aktar"),
            "exporting": ("Exporting...", "Dışa aktarılıyor..."),
            "share": ("Save or Share File", "Dosyayı Kaydet veya Paylaş"),
            "exportComplete": ("Export Complete", "Dışa Aktarma Tamamlandı"),
            "exportFailed": ("Export Failed", "Dışa Aktarma Başarısız"),
            "healthError": ("HealthKit Error", "HealthKit Hatası"),
            "ok": ("OK", "Tamam"),
            "subject": ("Subject", "Katılımcı"),
            "notAssigned": ("Not assigned", "Atanmadı"),
            "subjectID": ("Subject ID", "Katılımcı Kimliği"),
            "subjectPrompt": (
                "Assign an ID to this ECG recording.",
                "Bu EKG kaydına katılımcı kimliği atayın."
            ),
            "save": ("Save", "Kaydet"),
            "cancel": ("Cancel", "İptal"),
            "editSubject": ("Edit Subject ID", "Katılımcı Kimliğini Düzenle"),
            "exportReady": (
                "The file is ready to save or share.",
                "Dosya kaydedilmeye veya paylaşılmaya hazır."
            ),
            "exportedCount": ("Recordings exported", "Dışa aktarılan kayıtlar"),
            "sampleCount": ("Voltage samples", "Voltaj örnekleri")
        ]

        guard let value = translations[key] else {
            return key
        }

        return language == AppLanguage.turkish.rawValue
            ? value.1
            : value.0
    }
}

