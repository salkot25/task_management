# Auto Sync Integration Guide

Panduan lengkap untuk mengintegrasikan sistem auto sync untuk aplikasi yang dapat bekerja offline.

## 🎯 Fitur Utama

- **Offline-First Architecture**: Aplikasi tetap berfungsi penuh tanpa koneksi internet
- **Automatic Synchronization**: Data otomatis tersinkronisasi ketika koneksi tersedia
- **Smart Retry Logic**: Sistem retry otomatis dengan exponential backoff
- **Real-time Connectivity Detection**: Monitoring koneksi internet secara real-time
- **Queue Management**: Antrian sync yang dapat dipantau dan dikelola
- **Error Handling**: Penanganan error yang robust dengan fallback ke offline data

## 📁 Struktur File

```
lib/
  core/
    sync/
      models/
        sync_item.dart              # Model untuk item sync
      services/
        connectivity_service.dart   # Monitor koneksi internet
        local_sync_storage.dart     # Penyimpanan lokal dengan Hive
        auto_sync_service.dart      # Service utama untuk auto sync
      widgets/
        sync_status_widget.dart     # Widget untuk menampilkan status sync
      providers/
        sync_provider.dart          # Provider untuk inisialisasi sync services
      helpers/
        offline_data_helper.dart    # Helper untuk operasi offline
```

## 🚀 Setup dan Instalasi

### 1. Update main.dart

Ganti `main.dart` dengan `main_with_sync.dart` atau integrasikan manual:

```dart
// Wrap aplikasi dengan SyncServiceProvider
runApp(
  SyncServiceProvider(
    profileRepository: profileRepository,
    transactionRepository: transactionRepository,
    accountRepository: accountRepository,
    child: MultiProvider(
      providers: [
        // Provider lainnya...
      ],
      child: const MyApp(),
    ),
  ),
);
```

### 2. Update Profile Page

Profile page sudah diintegrasikan dengan:

- Sync status widget di app bar
- Auto sync toggle yang terhubung dengan service
- Sync settings di account actions

## 💻 Cara Penggunaan

### 1. Menggunakan Auto Sync di Provider/Repository

```dart
import 'package:myapp/core/sync/helpers/offline_data_helper.dart';

class YourProvider extends ChangeNotifier {

  // Simpan data dengan auto sync
  Future<void> saveDataWithSync({
    required BuildContext context,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Cek apakah online
      if (OfflineDataHelper.isOnline(context)) {
        // Simpan ke backend langsung
        await _saveToBackend(data);
      } else {
        // Tambah ke queue sync untuk nanti
        await OfflineDataHelper.addOperationToSync(
          context: context,
          entityType: SyncEntityType.profile, // atau task, transaction, account
          operationType: SyncOperationType.update,
          data: data,
          customId: entityId,
        );
      }

      // Selalu simpan offline untuk UI update langsung
      await OfflineDataHelper.saveProfileOffline(
        context: context,
        profileId: entityId,
        profileData: data,
      );

    } catch (e) {
      // Jika gagal save online, tambah ke sync queue
      await OfflineDataHelper.addOperationToSync(
        context: context,
        entityType: SyncEntityType.profile,
        operationType: SyncOperationType.update,
        data: data,
        customId: entityId,
      );

      // Tetap simpan offline
      await OfflineDataHelper.saveProfileOffline(
        context: context,
        profileId: entityId,
        profileData: data,
      );
    }
  }

  // Load data dengan offline fallback
  List<Map<String, dynamic>> loadDataWithOfflineFallback(BuildContext context) {
    try {
      // Coba load dari offline storage dulu untuk UI cepat
      final offlineData = OfflineDataHelper.loadProfilesOffline(context);

      if (offlineData.isNotEmpty) {
        // Load online data di background jika connected
        if (OfflineDataHelper.isOnline(context)) {
          _loadOnlineDataInBackground();
        }

        return offlineData;
      }

      // Jika tidak ada offline data dan online, load dari backend
      if (OfflineDataHelper.isOnline(context)) {
        return _loadFromBackend();
      }

      return [];
    } catch (e) {
      // Fallback ke offline data
      return OfflineDataHelper.loadProfilesOffline(context);
    }
  }
}
```

### 2. Menampilkan Status Sync

```dart
// Di app bar atau tempat lain
SyncStatusWidget(
  showDetails: true,
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => const SyncDetailsDialog(),
    );
  },
)
```

### 3. Mengatur Sync Settings

```dart
// Menampilkan sync settings
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => const SyncSettingsBottomSheet(),
);
```

### 4. Manual Sync

```dart
// Trigger manual sync
final autoSyncService = context.read<AutoSyncService>();
await autoSyncService.performManualSync();
```

## 🔧 Konfigurasi

### Auto Sync Settings

- **Interval Sync**: 30 detik (dapat diubah di `AutoSyncService`)
- **Retry Attempts**: 3 kali (dapat diubah di `AutoSyncService`)
- **Connectivity Check**: 5 detik (dapat diubah di `ConnectivityService`)

### Storage Backend

Menggunakan Hive untuk penyimpanan lokal:

- `sync_queue`: Menyimpan queue sync items
- `offline_data`: Menyimpan data untuk offline access

## 📊 Monitoring dan Debug

### 1. Sync Queue Status

```dart
final autoSyncService = context.read<AutoSyncService>();
final status = autoSyncService.getSyncQueueStatus();

print('Pending sync items: ${status['pending']}');
print('Total sync items: ${status['total']}');
print('Last sync time: ${status['lastSyncTime']}');
print('Connection status: ${status['isConnected']}');
```

### 2. Debug Mode

Aktifkan debug mode dengan:

```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  // Log akan muncul di console
}
```

## 🎛️ Widget dan UI Components

### SyncStatusWidget

Menampilkan status sync dengan indikator visual:

- 🟢 Hijau: Tersinkronisasi
- 🟡 Kuning: Ada item pending
- 🔵 Biru: Sedang sync
- 🔴 Merah: Error sync
- ⚪ Abu-abu: Offline

### SyncDetailsDialog

Dialog yang menampilkan:

- Status koneksi
- Jumlah item pending
- Waktu sync terakhir
- Error message (jika ada)
- Breakdown per entity type

### SyncSettingsBottomSheet

Bottom sheet untuk:

- Toggle auto sync on/off
- Manual sync trigger
- Clear sync data
- View sync statistics

## 🚨 Error Handling

### Connectivity Issues

```dart
// Aplikasi akan otomatis:
// 1. Detect koneksi hilang
// 2. Stop auto sync
// 3. Queue semua operasi
// 4. Resume sync ketika koneksi kembali
```

### Sync Failures

```dart
// Sistem akan:
// 1. Retry hingga 3 kali
// 2. Exponential backoff delay
// 3. Remove item setelah max retry
// 4. Log error untuk debugging
```

### Storage Failures

```dart
// Fallback strategy:
// 1. Continue app operation
// 2. Log warning
// 3. Graceful degradation
```

## 🔄 Sync Flow

1. **User Action** → Data operation (create/update/delete)
2. **Connectivity Check** → Online atau offline?
3. **Online Path**:
   - Save to backend immediately
   - Save to offline storage for quick access
4. **Offline Path**:
   - Add to sync queue
   - Save to offline storage
   - Show offline indicator
5. **Auto Sync**:
   - Monitor connectivity
   - Process sync queue when online
   - Retry failed operations
   - Clean up completed items

## 📱 User Experience

### Offline Indicators

- Status widget menunjukkan mode offline
- Snackbar notification untuk sync events
- Loading indicators untuk sync operations

### Data Consistency

- Local-first approach untuk UI responsiveness
- Background sync untuk data consistency
- Conflict resolution (future enhancement)

## 🔮 Future Enhancements

1. **Conflict Resolution**: Handle data conflicts saat sync
2. **Delta Sync**: Hanya sync perubahan, bukan seluruh data
3. **Batch Operations**: Group multiple operations untuk efisiensi
4. **Selective Sync**: User dapat pilih data mana yang di-sync
5. **Background Sync**: Sync di background process
6. **Encrypted Storage**: Enkripsi data offline
7. **Sync Analytics**: Detailed analytics untuk sync performance

## 🧪 Testing

### Unit Tests

```dart
// Test connectivity service
// Test local storage
// Test sync logic
// Test error scenarios
```

### Integration Tests

```dart
// Test end-to-end sync flow
// Test offline-online transitions
// Test data consistency
```

## 📞 Support

Jika ada masalah dengan implementasi auto sync:

1. Check debug logs di console
2. Verify connectivity service status
3. Check sync queue status
4. Clear sync data jika perlu reset
5. Restart aplikasi untuk re-initialization

---

**Happy Coding! 🚀**
