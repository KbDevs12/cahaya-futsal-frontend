import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../bookings/data/models/booking.dart';
import '../../../bookings/presentation/providers/booking_providers.dart';
import '../../../payments/presentation/screens/payment_qr_screen.dart';
import '../../data/models/field_availability.dart';
import '../providers/availability_providers.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  const CreateBookingScreen({required this.field, super.key});

  static const route = '/create-booking';

  final FieldAvailability field;

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  String? _startTime;
  String? _endTime;
  bool _loading = false;

  int _minutesOfDay(String value) {
    final parts = value.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    return hour * 60 + minute;
  }

  String _formatMinutes(int value) {
    final normalized = value.clamp(0, 24 * 60);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(String value) => value.substring(0, 5);

  List<String> _startOptions() {
    if (!widget.field.isAvailable || widget.field.isClosed) return [];

    final open = _minutesOfDay(widget.field.openTime);
    final close = _minutesOfDay(widget.field.closeTime);
    if (close <= open) return [];

    return [
      for (var minute = open; minute < close; minute += 60)
        _formatMinutes(minute),
    ];
  }

  List<String> _endOptions() {
    if (_startTime == null) return [];

    final start = _minutesOfDay(_startTime!);
    final close = _minutesOfDay(widget.field.closeTime);
    final nextBookedStart = widget.field.bookedSlots
        .map((slot) => _minutesOfDay(slot.startTime))
        .where((minute) => minute > start)
        .fold<int?>(null, (current, minute) {
          if (current == null || minute < current) return minute;
          return current;
        });
    final limit = nextBookedStart == null
        ? close
        : nextBookedStart.clamp(0, close);

    return [
      for (var minute = start + 60; minute <= limit; minute += 60)
        _formatMinutes(minute),
    ];
  }

  bool _hasBookedOverlap(String startTime, String endTime) {
    final start = _minutesOfDay(startTime);
    final end = _minutesOfDay(endTime);
    return widget.field.bookedSlots.any((slot) {
      final bookedStart = _minutesOfDay(slot.startTime);
      final bookedEnd = _minutesOfDay(slot.endTime);
      return start < bookedEnd && end > bookedStart;
    });
  }

  bool _isBooked(String startTime) {
    final start = _minutesOfDay(startTime);
    final end = start + 60;
    return widget.field.bookedSlots.any((slot) {
      final bookedStart = _minutesOfDay(slot.startTime);
      final bookedEnd = _minutesOfDay(slot.endTime);
      return start < bookedEnd && end > bookedStart;
    });
  }

  DateTime? _bookingDate() {
    final parsed = DateTime.tryParse(widget.field.date);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  bool _isTodayBookingDate() {
    final bookingDate = _bookingDate();
    if (bookingDate == null) return false;

    final now = DateTime.now();
    return bookingDate.year == now.year &&
        bookingDate.month == now.month &&
        bookingDate.day == now.day;
  }

  bool _isPastStartTime(String startTime) {
    if (!_isTodayBookingDate()) return false;

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    return _minutesOfDay(startTime) <= nowMinutes;
  }

  bool _isOutsideSchedule(String startTime, String endTime) {
    final start = _minutesOfDay(startTime);
    final end = _minutesOfDay(endTime);
    final open = _minutesOfDay(widget.field.openTime);
    final close = _minutesOfDay(widget.field.closeTime);
    return start < open || end > close || end <= start;
  }

  Future<void> _submit() async {
    if (!widget.field.isAvailable || widget.field.isClosed) {
      showSnack(context, 'Lapangan tutup pada tanggal ini');
      return;
    }

    if (_startTime == null || _endTime == null) {
      showSnack(context, 'Pilih jam mulai dan selesai dulu');
      return;
    }

    if (_isPastStartTime(_startTime!)) {
      showSnack(context, 'Jam tersebut sudah lewat untuk hari ini');
      return;
    }

    if (_isOutsideSchedule(_startTime!, _endTime!)) {
      showSnack(
        context,
        'Jam booking harus di antara ${_formatTime(widget.field.openTime)}-${_formatTime(widget.field.closeTime)}',
      );
      return;
    }

    if (_hasBookedOverlap(_startTime!, _endTime!)) {
      showSnack(context, 'Rentang jam tersebut sudah dibooking');
      return;
    }

    setState(() => _loading = true);
    try {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .create(
            CreateBookingRequest(
              fieldId: widget.field.fieldId,
              date: widget.field.date,
              startTime: _startTime!,
              endTime: _endTime!,
            ),
          );
      ref.invalidate(myBookingsProvider);
      ref.invalidate(availabilityProvider);
      if (!mounted) return;
      context.go('${PaymentQrScreen.route}/${booking.id}');
    } catch (error) {
      if (mounted) showSnack(context, AppException('').errorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startOptions = _startOptions();
    final endOptions = _endOptions();
    final closed = widget.field.isClosed || !widget.field.isAvailable;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Booking')),
      body: PagePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.field.fieldName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.field.isClosed
                          ? '${widget.field.date} • Tutup full day'
                          : '${widget.field.date} • ${_formatTime(widget.field.openTime)}-${_formatTime(widget.field.closeTime)}',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${formatRupiah(widget.field.pricePerHour)} / jam',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    if (closed) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Lapangan tidak bisa dibooking pada tanggal ini.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Jam mulai',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: startOptions.map((hour) {
                final booked = _isBooked(hour);
                final past = _isPastStartTime(hour);
                final disabled = booked || past;
                final selected = _startTime == hour;
                return ChoiceChip(
                  label: Text(hour),
                  selected: selected,
                  onSelected: disabled
                      ? null
                      : (_) => setState(() {
                          _startTime = hour;
                          _endTime = null;
                        }),
                  disabledColor: Colors.grey.shade200,
                );
              }).toList(),
            ),
            if (startOptions.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Tidak ada slot mulai yang bisa dipilih untuk tanggal ini.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ] else if (_isTodayBookingDate()) ...[
              const SizedBox(height: 8),
              const Text(
                'Jam yang sudah lewat untuk hari ini otomatis dinonaktifkan.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
            const SizedBox(height: 22),
            Text(
              'Jam selesai',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: endOptions.map((hour) {
                final selected = _endTime == hour;
                return ChoiceChip(
                  label: Text(hour),
                  selected: selected,
                  onSelected: (_) => setState(() => _endTime = hour),
                );
              }).toList(),
            ),
            if (_startTime != null && endOptions.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Tidak ada jam selesai yang valid karena terbentur booking atau jam tutup.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
            const Spacer(),
            PrimaryButton(
              label: 'Booking Sekarang',
              isLoading: _loading,
              onPressed: closed ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
