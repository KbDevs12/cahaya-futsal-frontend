import 'package:intl/intl.dart';

final _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

String formatRupiah(num value) => _rupiah.format(value);

String formatDate(DateTime value) => DateFormat('EEEE, d MMM yyyy', 'id_ID').format(value);

String formatDateTime(DateTime value) => DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(value);

String ymd(DateTime value) => DateFormat('yyyy-MM-dd').format(value);

String timeAgo(DateTime value) {
  final now = DateTime.now();
  final diff = now.difference(value.toLocal());

  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';

  return formatDateTime(value.toLocal());
}
