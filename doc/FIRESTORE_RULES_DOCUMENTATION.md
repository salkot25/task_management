# Cloud Firestore Security Rules Documentation

## Overview

Firestore security rules ini dirancang khusus untuk aplikasi Task Management dengan fitur:

- Authentication & User Profiles
- Account Management
- Task Planning
- Financial Tracking (Cashcard)
- Budget Management
- Secure Vault
- App Settings

## Struktur Database

```
/users/{userId}
├── /accounts/{accountId}         # Account management data
├── /tasks/{taskId}              # Task planning data
├── /transactions/{transactionId} # Financial transactions
├── /budgets/{budgetId}          # Budget categories
├── /vault/{vaultId}             # Secure vault items
├── /settings/{settingId}        # App settings
└── /audit_logs/{logId}          # Audit trail (read-only)
```

## Security Features

### 1. **Authentication Required**

- Semua operasi memerlukan user yang sudah authenticated
- User hanya bisa mengakses data mereka sendiri (user-level isolation)

### 2. **Data Validation**

- **String validation**: Minimum/maximum length checking
- **Number validation**: Range validation untuk amounts/balances
- **Email validation**: Format email yang valid
- **Timestamp validation**: Memastikan timestamp yang valid
- **Enum validation**: Restricted values untuk kategori/tipe

### 3. **Field-Level Security**

- Required fields validation
- Optional fields validation
- Immutable fields (seperti `createdAt`)
- Type checking untuk setiap field

### 4. **Collection-Specific Rules**

#### Users Collection (`/users/{userId}`)

```javascript
// Profile user dengan validasi email dan nama
- name: 1-100 karakter
- email: format valid
- photoUrl, phoneNumber, bio: optional
```

#### Accounts Collection (`/users/{userId}/accounts/{accountId}`)

```javascript
// Data akun keuangan
- name: 1-100 karakter
- type: ['bank', 'cash', 'credit_card', 'e_wallet', 'investment', 'other']
- balance: -999,999,999 sampai 999,999,999
- currency: ['IDR', 'USD', 'EUR', 'SGD']
```

#### Tasks Collection (`/users/{userId}/tasks/{taskId}`)

```javascript
// Data task/todo
- title: 1-200 karakter
- description: 0-1000 karakter
- priority: ['low', 'medium', 'high', 'urgent']
- tags: maksimal 10 items, tidak boleh duplikat
```

#### Transactions Collection (`/users/{userId}/transactions/{transactionId}`)

```javascript
// Data transaksi keuangan
- amount: 0.01 sampai 999,999,999
- type: ['income', 'expense']
- description: 1-255 karakter
- category, tags, location: optional
```

#### Budgets Collection (`/users/{userId}/budgets/{budgetId}`)

```javascript
// Data budget categories
- name: 1-100 karakter
- budgetAmount, spentAmount: 0 sampai 999,999,999
- period: ['monthly', 'weekly', 'yearly', 'custom']
- alertThreshold: 0-100 (percentage)
```

#### Vault Collection (`/users/{userId}/vault/{vaultId}`)

```javascript
// Data sensitif terenkripsi
- title: 1-100 karakter
- type: ['password', 'card', 'note', 'document', 'other']
- encryptedData: 1-10,000 karakter (data terenkripsi)
```

#### Settings Collection (`/users/{userId}/settings/{settingId}`)

```javascript
// App settings dengan whitelist keys
- Allowed keys: 'theme_mode', 'language', 'currency_default',
                'notification_enabled', 'biometric_enabled',
                'backup_enabled', 'sync_frequency'
```

## Best Practices Implemented

### 1. **Principle of Least Privilege**

- User hanya bisa mengakses data mereka sendiri
- Tidak ada akses cross-user
- Audit logs read-only untuk user

### 2. **Input Validation**

- Semua input divalidasi untuk tipe dan range
- String length limits untuk mencegah DoS
- Enum values untuk mencegah invalid data

### 3. **Data Integrity**

- `createdAt` immutable setelah creation
- Required fields validation
- Consistent timestamp handling

### 4. **Performance Considerations**

- Efficient helper functions
- Minimal nested validation
- Optimized for common operations

## Deployment Instructions

### **Prerequisites**

1. **Install Firebase CLI:**

   ```bash
   npm install -g firebase-tools
   ```

2. **Login ke Firebase:**

   ```bash
   firebase login
   ```

3. **Set Active Project:**

   ```bash
   # List available projects
   firebase projects:list

   # Set active project
   firebase use tasks-man-25
   ```

### **Deploy Rules**

1. **Deploy hanya Firestore rules:**

   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Deploy Firestore rules dan indexes:**

   ```bash
   firebase deploy --only firestore
   ```

3. **Deploy semua (hosting + firestore):**
   ```bash
   firebase deploy
   ```

### **Testing dengan Firebase Emulator**

1. **Start Firebase Emulator untuk testing:**

   ```bash
   # Start hanya Firestore emulator
   firebase emulators:start --only firestore

   # Start semua emulators (auth + firestore + hosting)
   firebase emulators:start
   ```

2. **Access Emulator UI:**
   - Emulator UI: http://localhost:4000
   - Firestore Emulator: http://localhost:8080

### **Troubleshooting Common Errors**

#### **Error: "No currently active project"**

```bash
# Solution: Set active project
firebase use tasks-man-25
```

#### **Error: "Cannot understand what targets to deploy"**

```bash
# Solution: Check firebase.json configuration
# Ensure firestore section exists in firebase.json
```

#### **Error: "Compilation errors in firestore.rules"**

```bash
# Common issues:
# 1. Variable name conflicts (e.g., 'timestamp')
# 2. Syntax errors in rules
# 3. Missing semicolons or brackets
```

### **Monitor Rules di Production**

- Check Firebase Console > Firestore > Rules tab
- Monitor denied requests di Monitoring section
- Review performance di Firestore Usage tab## Security Recommendations

### 1. **Client-Side Additional Validation**

```dart
// Tambahkan validasi di client sebelum Firestore write
bool validateTransaction(Transaction transaction) {
  return transaction.amount > 0 &&
         transaction.description.isNotEmpty &&
         ['income', 'expense'].contains(transaction.type);
}
```

### 2. **Error Handling**

```dart
try {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('transactions')
      .add(transactionData);
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    // Handle permission error
    showError('Tidak memiliki izin untuk operasi ini');
  }
}
```

### 3. **Indexes untuk Performance**

```javascript
// Tambahkan indexes di Firebase Console untuk:
- users/{userId}/transactions: ['date', 'type', 'amount']
- users/{userId}/tasks: ['dueDate', 'priority', 'isCompleted']
- users/{userId}/accounts: ['type', 'isActive']
```

### 4. **Regular Security Audits**

- Review rules setiap 3-6 bulan
- Monitor denied requests
- Update validation rules sesuai kebutuhan aplikasi

## Testing

Gunakan Firebase Emulator untuk testing:

```bash
# Start emulator
firebase emulators:start --only firestore

# Test dengan different scenarios:
# 1. Authenticated user mengakses data sendiri ✅
# 2. Authenticated user mengakses data user lain ❌
# 3. Unauthenticated access ❌
# 4. Invalid data format ❌
# 5. Valid data format ✅
```

Rules ini memberikan keamanan yang kuat sambil tetap fleksibel untuk pengembangan aplikasi Anda.
