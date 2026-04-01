# Responsive Design Guide - ScreenUtil Usage

## ✅ Current Implementation Status

All screens in the app use **`.r` for ALL sizing** (fonts, widths, heights, border radius) for uniform proportional scaling!

## 📐 ScreenUtil Extension - Use `.r` for Everything

The app uses `flutter_screenutil` package with **`.r` extension for all sizing** to ensure uniform proportional scaling across all screen sizes.

### Why `.r` for Everything?

Using `.r` for all dimensions ensures:
- **Uniform scaling**: Everything scales proportionally together
- **Consistency**: No need to remember different extensions
- **Simplicity**: One extension for all sizing needs
- **Better web/desktop support**: Works perfectly with ResponsiveWrapper

### All Sizing - `.r`
```dart
// ✅ CORRECT - Use .r for everything
Text('Hello', style: TextStyle(fontSize: 16.r))
SizedBox(height: 24.r, width: 120.r)
Container(height: 56.r, width: 200.r)
BorderRadius.circular(16.r)
Icon(Icons.star, size: 24.r)
EdgeInsets.all(16.r)
EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r)

// ❌ WRONG - Don't use .sp, .w, .h
Text('Hello', style: TextStyle(fontSize: 16.sp))
SizedBox(height: 24.h, width: 120.w)
Container(height: 56.h, width: 200.w)
```

## 🎯 Design Size Configuration

The app is configured with iPhone 14 Pro dimensions:
```dart
ScreenUtilInit(
  designSize: const Size(390, 844),  // iPhone 14 Pro
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) { ... }
)
```

## ✅ Verified Screens

All screens use `.r` for uniform proportional scaling:

### 1. Splash Screen (`splash_screen.dart`)
- ✅ Logo sizes: `width: 200.r, height: 200.r`
- ✅ Font sizes: `fontSize: 18.r`
- ✅ Spacing: `SizedBox(height: 30.r)`

### 2. Language Selection Screen (`language_selection_screen.dart`)
- ✅ Logo: `width: 140.r, height: 80.r`
- ✅ Font sizes: `fontSize: 24.r`, `fontSize: 16.r`, `fontSize: 14.r`
- ✅ Border radius: `BorderRadius.circular(12.r)`, `circular(16.r)`
- ✅ Padding: `EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r)`
- ✅ Button height: `height: 56.r`
- ✅ Icon sizes: `size: 24.r`

### 3. Onboarding Screen (`onboarding_screen.dart`)
- ✅ Logo: `width: 200.r, height: 200.r`
- ✅ Font sizes: `fontSize: 40.r`, `fontSize: 14.r`, `fontSize: 16.r`
- ✅ Border radius: `BorderRadius.circular(16.r)`
- ✅ Padding: `EdgeInsets.symmetric(horizontal: 32.r, vertical: 24.r)`
- ✅ Button sizes: `width: 56.r, height: 56.r`
- ✅ Spacing: `SizedBox(height: 48.r)`, `height: 32.r`

## 🌐 Web/Desktop Support

The app includes `ResponsiveWrapper` that:
- Constrains app to 430px max width on web/desktop
- Centers the app on screen
- Maintains mobile-first design
- All ScreenUtil sizing works perfectly within the constraint

## 📱 Best Practices

### Always Use `.r` for All Sizing

```dart
// ✅ CORRECT - Use .r for everything
Container(
  width: 200.r,
  height: 100.r,
  padding: EdgeInsets.all(16.r),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),
  ),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.r),
  ),
)

// ❌ WRONG - Hardcoded values
Container(
  width: 200,
  height: 100,
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16),
  ),
)
```

### Exception: When NOT to Use `.r`

Only use hardcoded values for:
1. **Multipliers and ratios**: `height: 1.5`, `flex: 2`
2. **Border widths**: `width: 1` (borders should stay 1px)
3. **Opacity values**: `opacity: 0.5`
4. **Infinity**: `width: double.infinity`

```dart
// ✅ CORRECT - These don't need .r
Text('Hello', style: TextStyle(height: 1.5))  // Line height ratio
Divider(height: 1, thickness: 1)  // 1px divider
Opacity(opacity: 0.5, child: ...)  // Opacity value
Container(width: double.infinity)  // Full width
Border.all(width: 1)  // 1px border
```

## 🎨 Common Sizing Guidelines (All use `.r`)

### Font Sizes
- **Headings**: 24.r - 40.r
- **Body text**: 14.r - 16.r
- **Small text**: 12.r - 13.r
- **Buttons**: 16.r - 18.r

### Spacing
- **Small**: 8.r - 12.r
- **Medium**: 16.r - 24.r
- **Large**: 32.r - 48.r

### Border Radius
- **Small**: 8.r - 12.r
- **Medium**: 16.r
- **Large**: 20.r - 24.r

### Button Sizes
- **Standard**: 48.r - 56.r
- **Small**: 40.r
- **Large**: 60.r

### Padding
- **Screen edges**: 24.r or 32.r
- **Card padding**: 16.r or 20.r
- **Button padding**: 16.r - 24.r

## 🔍 How to Check for Issues

Search for hardcoded values or old extensions in your code:

```bash
# Find hardcoded values (should only find exceptions like height: 1.5, width: 1, etc.)
grep -r "fontSize: [0-9]" lib/
grep -r "height: [0-9]" lib/
grep -r "width: [0-9]" lib/

# Find old extensions that should be replaced with .r
grep -r "\.sp" lib/
grep -r "\.w" lib/
grep -r "\.h" lib/
```

## ✨ Result

**All screens now use `.r` for uniform proportional scaling!**

The responsive design is working correctly:
- ✅ Mobile devices: Full responsive scaling
- ✅ Web/Desktop: Constrained to mobile size (430px), centered
- ✅ **All sizing uses `.r`**: fonts, widths, heights, border radius, icons, padding
- ✅ Uniform proportional scaling across all screen sizes
- ✅ Consistent spacing and sizing throughout
- ✅ Simpler to maintain - one extension for everything

## 🚀 For Future Development

When creating new screens or widgets:

1. **Always import ScreenUtil**: Already imported via `flutter_screenutil`
2. **Use `.r` for ALL sizing**: fonts, widths, heights, border radius, icons, padding
3. **Follow sizing guidelines**: Use the common sizes above (all with `.r`)
4. **Test on web**: Verify it looks good in the centered mobile view (430px)
5. **Check with grep**: Search for hardcoded values or old `.sp`, `.w`, `.h` before committing

### Quick Reference

```dart
// ✅ Always use .r
fontSize: 16.r
width: 200.r
height: 100.r
size: 24.r
EdgeInsets.all(16.r)
EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r)
BorderRadius.circular(12.r)
SizedBox(width: 120.r, height: 80.r)

// ❌ Never use these
fontSize: 16.sp  // OLD - use .r instead
width: 200.w     // OLD - use .r instead
height: 100.h    // OLD - use .r instead
```

The app is production-ready with uniform proportional scaling! 🎉
