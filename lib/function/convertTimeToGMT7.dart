String formatDateTimeToLocal(DateTime dateTime) {
  // Chuyển đổi thành múi giờ số 7
  final localDateTime = dateTime.add(Duration(hours: 7));
  // Định dạng thành chuỗi 'yyyy-MM-dd HH:mm'
  return '${localDateTime.year}-${localDateTime.month.toString().padLeft(2, '0')}-${localDateTime.day.toString().padLeft(2, '0')} ${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
}
