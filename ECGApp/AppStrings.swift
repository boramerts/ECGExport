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
                """
                ECG Exporter respects your privacy and keeps your health data under your control.

                Your ECG recordings are accessed securely through Apple HealthKit with your permission. All ECG measurements are processed locally on your device. The app does not collect or upload your health information to external servers.

                Subject IDs and application preferences are stored locally. ECG recordings are only exported when you explicitly choose to do so. You have full control over where exported files are saved or shared.

                ECG Exporter does not use advertising, analytics, or tracking services, and your original recordings in Apple Health are never modified or deleted.
                """,
                """
                ECG Exporter gizliliğinize saygı duyar ve sağlık verilerinizin kontrolünü size bırakır.

                EKG kayıtlarınıza, izniniz doğrultusunda Apple HealthKit aracılığıyla güvenli bir şekilde erişilir. Tüm EKG ölçümleri cihazınızda yerel olarak işlenir. Uygulama, sağlık bilgilerinizi toplamaz veya harici sunuculara yüklemez.

                Katılımcı kimlikleri ve uygulama tercihleri cihazınızda saklanır. EKG kayıtları yalnızca sizin açıkça dışa aktarma işlemini başlatmanız durumunda dışa aktarılır. Oluşturulan dosyaların nereye kaydedileceği veya kimlerle paylaşılacağı tamamen sizin kontrolünüzdedir.

                ECG Exporter reklam, analiz veya kullanıcı takibi hizmetleri kullanmaz. Apple Sağlık uygulamasındaki orijinal EKG kayıtlarınız hiçbir zaman değiştirilmez veya silinmez.
                """
            ),

            "appTitle": ("ECGExport", "ECGExport"),
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

