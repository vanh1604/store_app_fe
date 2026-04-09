#!/bin/bash
# Chạy app trên iPhone thật — tự động lấy IP của Mac
LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)

if [ -z "$LOCAL_IP" ]; then
  echo "❌ Không tìm được IP. Kết nối WiFi trước, hoặc chạy tay:"
  echo "   flutter run --dart-define=HOST_IP=<IP_CUA_MAC>"
  exit 1
fi

echo "📱 Chạy trên iPhone thật với HOST_IP=$LOCAL_IP"
flutter run --dart-define=HOST_IP=$LOCAL_IP "$@"
