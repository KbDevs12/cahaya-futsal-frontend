import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';

class DateStrip extends StatelessWidget {
  const DateStrip({
    required this.selectedDate,
    required this.onChanged,
    super.key,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(7, (index) => DateTime(today.year, today.month, today.day + index));

    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final selected = DateUtils.isSameDay(date, selectedDate);
          return InkWell(
            onTap: () => onChanged(date),
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 68,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: selected ? AppColors.primary : AppColors.line),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'id_ID').format(date),
                    style: TextStyle(
                      color: selected ? Colors.white70 : AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
