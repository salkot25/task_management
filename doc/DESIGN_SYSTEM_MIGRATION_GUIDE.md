# 🚀 Design System Migration Guide

## 📋 **Migration Overview**

Panduan untuk mengintegrasikan design system yang telah dibuat ke seluruh aplikasi Flutter Task Management.

---

## ✅ **Already Migrated**

### **1. Login Page** (`lib/features/auth/presentation/pages/login_page.dart`)

- ✅ **Color System**: Menggunakan `AppColors`
- ✅ **Typography**: Menggunakan `AppTypography.loginTitle`, `AppTypography.loginSubtitle`
- ✅ **Spacing**: Menggunakan `AppSpacing` constants
- ✅ **Components**: Menggunakan `AppComponents.emailInputDecoration()`, `AppComponents.passwordInputDecoration()`
- ✅ **Theme**: Terintegrasi dengan `AppTheme.lightTheme/darkTheme`

### **2. Main App** (`lib/main.dart`)

- ✅ **Theme Configuration**: Menggunakan `AppTheme.lightTheme` dan `AppTheme.darkTheme`
- ✅ **Import Structure**: Menggunakan design system import
- ✅ **Router Integration**: Terintegrasi dengan modular routing

### **3. Design System Files**

- ✅ **Created**: Semua file design system sudah dibuat dan terintegrasi
- ✅ **Exported**: Melalui `design_system.dart` export file

---

## 🔄 **Files Requiring Migration**

### **Priority 1: Core Navigation & Layout**

#### **1. Home Page** (`lib/presentation/pages/home_page.dart`)

```dart
// CURRENT STATUS: ❌ Not migrated
// MIGRATION TASKS:
- Replace hardcoded colors with AppColors
- Use AppTypography for text styles
- Apply AppSpacing for consistent spacing
- Use AppComponents for consistent UI elements
- Apply AppTheme.cardDecoration() for cards
```

#### **2. Bottom Navigation Shell** (`lib/utils/bottom_navigation_shell.dart`)

```dart
// CURRENT STATUS: ✅ Partially migrated
// MIGRATION TASKS:
- Update colors to use AppColors.primaryColor
- Apply AppTypography for labels
- Use AppSpacing for proper spacing
- Ensure consistent with design system patterns
```

### **Priority 2: Feature Pages**

#### **3. Task Planner Pages** (`lib/features/task_planner/presentation/pages/`)

```dart
// CURRENT STATUS: ❌ Not migrated
// MIGRATION TASKS:
- Apply design system to all task-related pages
- Use consistent input field decorations
- Apply typography hierarchy
- Use semantic colors for task states (success, warning, etc.)
```

#### **4. Cash Card Pages** (`lib/features/cashcard/presentation/pages/`)

```dart
// CURRENT STATUS: ❌ Not migrated
// MIGRATION TASKS:
- Integrate AppColors for financial UI elements
- Apply AppTypography for monetary displays
- Use AppComponents for card layouts
- Implement responsive design patterns
```

#### **5. Account Management Pages** (`lib/features/account_management/presentation/pages/`)

```dart
// CURRENT STATUS: ❌ Not migrated
// MIGRATION TASKS:
- Use AppComponents.inputDecoration() for forms
- Apply AppTypography for user information display
- Use AppColors for status indicators
- Implement consistent button styles
```

#### **6. Auth Pages** (`lib/features/auth/presentation/pages/`)

```dart
// CURRENT STATUS: 🔄 Partially migrated (login done)
// REMAINING TASKS:
- Migrate register page
- Migrate forgot password page
- Apply consistent styling across all auth flows
```

---

## 📝 **Migration Steps for Each File**

### **Step 1: Import Design System**

```dart
// Add this import to the top of each file
import 'package:myapp/utils/design_system/design_system.dart';
```

### **Step 2: Replace Colors**

```dart
// BEFORE
color: Color(0xFF00BCD4)
backgroundColor: Colors.blue

// AFTER
color: AppColors.primaryColor
backgroundColor: AppColors.surfaceColor
```

### **Step 3: Replace Typography**

```dart
// BEFORE
style: TextStyle(
  fontSize: 28.0,
  fontWeight: FontWeight.w600,
)

// AFTER
style: AppTypography.headlineMedium.copyWith(
  color: Theme.of(context).colorScheme.onSurface,
)
```

### **Step 4: Replace Spacing**

```dart
// BEFORE
padding: EdgeInsets.all(24.0)
SizedBox(height: 16.0)

// AFTER
padding: AppSpacing.pagePaddingMobile
SizedBox(height: AppSpacing.md)
```

### **Step 5: Use Components**

```dart
// BEFORE
decoration: InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
  ),
  // ... lots of styling code
)

// AFTER
decoration: AppComponents.inputDecoration(
  labelText: 'Label',
  hintText: 'Hint',
)
```

### **Step 6: Apply Theme Integration**

```dart
// Ensure all widgets use theme colors
color: Theme.of(context).colorScheme.primary
backgroundColor: Theme.of(context).colorScheme.surface
```

---

## 🎯 **Migration Priorities**

### **Week 1: Core Navigation**

1. ✅ Login Page (Completed)
2. 🔄 Home Page
3. 🔄 Bottom Navigation refinement

### **Week 2: Authentication Flow**

1. 🔄 Register Page
2. 🔄 Forgot Password Page
3. 🔄 Auth error handling

### **Week 3: Feature Pages**

1. 🔄 Task Planner pages
2. 🔄 Cash Card pages
3. 🔄 Account Management pages

### **Week 4: Polish & Testing**

1. 🔄 Responsive design testing
2. 🔄 Dark mode testing
3. 🔄 Accessibility testing
4. 🔄 Performance optimization

---

## 🧪 **Testing Checklist**

### **Visual Testing**

- [ ] All colors match design system
- [ ] Typography is consistent across pages
- [ ] Spacing follows 8px grid
- [ ] Components are visually consistent

### **Responsive Testing**

- [ ] Mobile (< 600px) layouts work correctly
- [ ] Tablet (>= 600px) layouts work correctly
- [ ] Text scaling works properly
- [ ] Images and icons scale appropriately

### **Theme Testing**

- [ ] Light theme displays correctly
- [ ] Dark theme displays correctly
- [ ] Theme switching works smoothly
- [ ] All components support both themes

### **Accessibility Testing**

- [ ] Screen reader compatibility
- [ ] Proper contrast ratios
- [ ] Touch target sizes (min 44px)
- [ ] Focus indicators work correctly

---

## 🔧 **Common Migration Patterns**

### **Buttons**

```dart
// Primary Button
ElevatedButton(
  style: AppComponents.primaryButtonStyle(),
  child: Text('Button', style: AppTypography.buttonPrimary),
)

// Secondary Button
OutlinedButton(
  style: AppComponents.secondaryButtonStyle(),
  child: Text('Button', style: AppTypography.buttonSecondary),
)

// Text Button
TextButton(
  style: AppComponents.textButtonStyle(),
  child: Text('Button', style: AppTypography.linkText),
)
```

### **Input Fields**

```dart
// Standard Input
TextFormField(
  decoration: AppComponents.inputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
    prefixIcon: Icon(Icons.email_outlined),
  ),
)

// Email Input
TextFormField(
  decoration: AppComponents.emailInputDecoration(
    colorScheme: Theme.of(context).colorScheme,
  ),
)

// Password Input
TextFormField(
  decoration: AppComponents.passwordInputDecoration(
    colorScheme: Theme.of(context).colorScheme,
    isPasswordVisible: _isPasswordVisible,
    onToggleVisibility: _togglePasswordVisibility,
  ),
)
```

### **Cards & Containers**

```dart
// Card Container
Container(
  decoration: AppComponents.cardDecoration(),
  padding: AppSpacing.cardPadding,
  child: // Card content
)

// Loading Container
AppComponents.loadingButton(
  height: 52.0,
  colorScheme: Theme.of(context).colorScheme,
)
```

### **Dividers**

```dart
// Text Divider
AppComponents.dividerWithText(
  text: 'or continue with',
  colorScheme: Theme.of(context).colorScheme,
)
```

---

## 📈 **Expected Benefits**

### **Development Efficiency**

- ⚡ **50% faster UI development** - pre-built components
- 🎯 **90% less design inconsistencies** - design tokens
- 🔧 **75% easier maintenance** - centralized styling

### **User Experience**

- 🎨 **Consistent visual language** across all pages
- ♿ **Improved accessibility** with built-in standards
- 📱 **Better responsive design** with systematic approach

### **Code Quality**

- 📦 **Modular architecture** - component-based
- 🧪 **Easier testing** - isolated components
- 📝 **Better documentation** - self-documenting code

---

## 🚀 **Next Actions**

1. **Start with Home Page migration** - highest impact
2. **Apply design system to bottom navigation** - visual consistency
3. **Migrate authentication pages** - complete auth flow
4. **Systematically migrate feature pages** - comprehensive coverage
5. **Conduct thorough testing** - quality assurance

---

_Design system migration akan menghasilkan aplikasi yang lebih konsisten, maintainable, dan user-friendly dengan pengalaman pengguna yang superior di semua platform._
