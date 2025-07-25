# Firebase Deployment Guide

## Quick Start

### 🚀 Deploy Firestore Rules

```bash
# 1. Set active project
firebase use tasks-man-25

# 2. Deploy rules
firebase deploy --only firestore:rules
```

### 🧪 Test dengan Emulator

```bash
# Start emulator
firebase emulators:start --only firestore

# Access Emulator UI di browser
# http://localhost:4000
```

## Project Configuration

### Firebase Project Details

- **Project ID**: `tasks-man-25`
- **Project Number**: `1074161513774`
- **Database**: Cloud Firestore (Native mode)

### Files Configuration

```
firebase.json         # Firebase project configuration
firestore.rules       # Security rules
firestore.indexes.json # Database indexes
.firebaserc           # Project aliases
```

## Deployment Commands

### Option 1: Deploy Only Rules

```bash
firebase deploy --only firestore:rules
```

**Use case**: When you only changed security rules

### Option 2: Deploy Rules + Indexes

```bash
firebase deploy --only firestore
```

**Use case**: When you changed rules and database indexes

### Option 3: Deploy Everything

```bash
firebase deploy
```

**Use case**: Deploy hosting + firestore + functions (if any)

## Common Issues & Solutions

### ❌ Error: "No currently active project"

```bash
# Solution
firebase use tasks-man-25
```

### ❌ Error: "Cannot understand what targets to deploy"

**Cause**: Missing firestore configuration in `firebase.json`

**Solution**: Ensure `firebase.json` has:

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  }
}
```

### ❌ Error: "Compilation errors in firestore.rules"

**Common causes**:

- Variable name conflicts (e.g., using `timestamp` as variable name)
- Missing semicolons
- Syntax errors in functions

**Debug**: Check error line numbers in terminal output

### ❌ Error: "Permission denied"

```bash
# Re-login to Firebase
firebase logout
firebase login
```

## Testing Security Rules

### 1. Start Emulator

```bash
firebase emulators:start --only firestore
```

### 2. Run Flutter Tests

```bash
flutter test test/firestore_rules_test.dart
```

### 3. Manual Testing via Emulator UI

- Open http://localhost:4000
- Go to Firestore tab
- Try different read/write operations
- Check if rules work correctly

## Monitoring Production

### Firebase Console Locations

1. **Rules**: Console > Firestore > Rules
2. **Monitoring**: Console > Firestore > Usage
3. **Indexes**: Console > Firestore > Indexes

### Key Metrics to Monitor

- **Denied Requests**: Indicates potential security issues
- **Read/Write Operations**: Performance metrics
- **Storage Usage**: Database size
- **Index Usage**: Query performance

## Security Best Practices

### ✅ Do's

- Test rules in emulator before production
- Monitor denied requests regularly
- Use principle of least privilege
- Validate all input data
- Use proper field-level security

### ❌ Don'ts

- Don't deploy untested rules
- Don't use overly permissive rules
- Don't skip input validation
- Don't ignore denied request alerts
- Don't use sensitive data in rule conditions

## Emergency Rollback

If you need to rollback rules:

### Option 1: Firebase Console

1. Go to Firebase Console > Firestore > Rules
2. Click "History" tab
3. Select previous version
4. Click "Restore"

### Option 2: Git + Redeploy

```bash
# Revert to previous commit
git checkout HEAD~1 -- firestore.rules

# Deploy reverted rules
firebase deploy --only firestore:rules

# Restore latest commit
git checkout HEAD -- firestore.rules
```

## Performance Tips

### Optimize Rules

- Keep validation functions simple
- Avoid nested validations when possible
- Use efficient helper functions
- Cache repeated validations

### Optimize Indexes

- Create composite indexes for complex queries
- Remove unused indexes
- Monitor index usage in console

### Optimize Queries

- Use where() clauses effectively
- Limit query results
- Use pagination for large datasets
- Avoid large document reads

---

**Last Updated**: July 26, 2025  
**Project**: Task Management App  
**Firebase Project**: tasks-man-25
