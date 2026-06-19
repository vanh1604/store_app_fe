/// Định dạng số tiền theo kiểu Việt Nam: 1234567 -> "1.234.567".
///
/// Dùng chung cho toàn app để tránh lặp lại logic ở nhiều màn hình.
/// Thường hiển thị kèm hậu tố " VND" tại nơi gọi.
String formatCurrency(double amount) {
  return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
}
