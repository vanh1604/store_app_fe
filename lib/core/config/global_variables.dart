import 'dart:io';

String getBaseUrl() {
  if (Platform.isAndroid) {
    // Android Emulator truy cập host qua 10.0.2.2
    return 'http://10.0.2.2:3000';
  } else if (Platform.isIOS) {
    // iOS Simulator: kHostIp = 'localhost'
    // iPhone thật: kHostIp = IP Mac (được inject bởi Xcode pre-action)
    return 'http://172.20.10.2:3000';
  } else {
    return 'http://172.20.10.2:3000';
  }
}

// Sử dụng
String uri = getBaseUrl();
