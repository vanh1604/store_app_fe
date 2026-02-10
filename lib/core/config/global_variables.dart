import 'dart:io';

String getBaseUrl() {
  if (Platform.isAndroid) {
    // Dành cho Android Emulator
    return 'http://10.0.2.2:3000';
  } else if (Platform.isIOS) {
    // Dành cho iOS Simulator
    return 'http://localhost:3000';
  } else {
    // Fallback cho các trường hợp khác
    return 'http://localhost:3000';
  }
}

// Sử dụng
String uri = getBaseUrl();
