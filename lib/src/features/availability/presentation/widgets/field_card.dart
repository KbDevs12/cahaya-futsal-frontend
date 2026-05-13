import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/field_availability.dart';

class FieldCard extends StatelessWidget {
  const FieldCard({required this.field, required this.onTap, super.key});

  final FieldAvailability field;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = field.isClosed || !field.isAvailable;

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: disabled
                            ? [Colors.grey.shade300, Colors.grey.shade200]
                            : [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.stadium_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.fieldName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${field.fieldType} • ${field.openTime}-${field.closeTime}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    formatRupiah(field.pricePerHour),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Text(' / jam', style: TextStyle(color: AppColors.muted)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: disabled ? Colors.red.withOpacity(.08) : AppColors.primary.withOpacity(.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      disabled ? 'Tutup' : '${field.bookedSlots.length} booked',
                      style: TextStyle(
                        color: disabled ? Colors.red : AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
