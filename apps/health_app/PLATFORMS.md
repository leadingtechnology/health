# Supported Platforms

This Flutter application supports the following platforms:

## ✅ Supported Platforms

### 📱 Mobile
- **iOS** - iPhone and iPad support
- **Android** - Phone and tablet support

### 🌐 Web
- **Web** - Progressive Web App (PWA) support
  - Chrome
  - Safari
  - Firefox
  - Edge

## ❌ Unsupported Platforms

The following desktop platforms have been explicitly removed:
- **Windows** - Not supported
- **macOS** - Not supported  
- **Linux** - Not supported

## Build Commands

```bash
# iOS
flutter build ios

# Android
flutter build apk
flutter build appbundle

# Web
flutter build web
```

## Development

To run the app in development mode:

```bash
# List available devices
flutter devices

# Run on specific platform
flutter run -d chrome        # Web
flutter run -d emulator-5554 # Android emulator
flutter run -d <device-id>   # iOS device
```