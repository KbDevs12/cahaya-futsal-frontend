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
import '../providers/availability_providers.dart';
import '../../../payments/presentation/screens/payment_qr_screen.dart';
import '../../data/models/field_availability.dart';

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

  List<String> _hours() {
    int parseHour(String value) => int.parse(value.split(':').first);
    final open = parseHour(widget.field.openTime);
    final close = parseHour(widget.field.closeTime);
    return [
      for (var h = open; h < close; h++) '${h.toString().padLeft(2, '0')}:00',
    ];
  }

  bool _isBooked(String start) {
    final startHour = int.parse(start.split(':').first);
    return widget.field.bookedSlots.any((slot) {
      final bookedStart = int.parse(slot.startTime.split(':').first);
      final bookedEnd = int.parse(slot.endTime.split(':').first);
      return startHour >= bookedStart && startHour < bookedEnd;
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

  bool _isPastStartTime(String start) {
    if (!_isTodayBookingDate()) return false;

    final now = DateTime.now();
    final currentBookableHour = now.minute == 0 && now.second == 0
        ? now.hour
        : now.hour + 1;
    final startHour = int.parse(start.split(':').first);

    return startHour < currentBookableHour;
  }

  Future<void> _submit() async {
    if (_startTime == null || _endTime == null) {
      showSnack(context, 'Pilih jam mulai dan selesai dulu');
      return;
    }

    if (_isPastStartTime(_startTime!)) {
      showSnack(context, 'Jam tersebut sudah lewat untuk hari ini');
      return;
    }

    if (_isBooked(_startTime!)) {
      showSnack(context, 'Jam mulai tersebut sudah dibooking');
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
      if (mounted) showSnack(context, AppException("").errorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hours = _hours();
    final endOptions = _startTime == null
        ? <String>[]
        : [
            ...hours.where(
              (h) =>
                  int.parse(h.split(':').first) >
                  int.parse(_startTime!.split(':').first),
            ),
            widget.field.closeTime,
          ];

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
                      '${widget.field.date} • ${widget.field.openTime}-${widget.field.closeTime}',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${formatRupiah(widget.field.pricePerHour)} / jam',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
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
              children: hours.map((hour) {
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
            if (_isTodayBookingDate()) ...[
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
            const Spacer(),
            PrimaryButton(
              label: 'Booking Sekarang',
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
