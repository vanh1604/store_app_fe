import 'dart:io';

String getBaseUrl() {
  if (Platform.isAndroid) {
    // Android Emulator truy cập host qua 10.0.2.2
    return 'http://10.0.2.2:3000';
  } else if (Platform.isIOS) {
    // iOS Simulator: 'localhost'
    // iOS Real Device: Replace 'localhost' with your Mac's IP address (e.g., '192.168.1.10')
    // and ensure both are on the same Wi-Fi network.
    return 'http://localhost:3000';
  } else {
    return 'http://localhost:3000';
  }
}

// Sử dụng
String uri = getBaseUrl();
