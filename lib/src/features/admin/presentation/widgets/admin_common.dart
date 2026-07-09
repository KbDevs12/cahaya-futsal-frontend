import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/status_chip.dart';

class AdminAsyncList<T> extends StatelessWidget {
  const AdminAsyncList({
    required this.value,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.itemBuilder,
    this.onRetry,
    this.separatorHeight = 12,
    super.key,
  });

  final AsyncValue<List<T>> value;
  final String emptyTitle;
  final String emptyMessage;
  final Widget Function(T item) itemBuilder;
  final VoidCallback? onRetry;
  final double separatorHeight;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ErrorView(error: error, onRetry: onRetry),
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            title: emptyTitle,
            message: emptyMessage,
            icon: Icons.inbox_rounded,
          );
        }
        return Column(
          children: items
              .map((item) => Padding(
                    padding: EdgeInsets.only(bottom: separatorHeight),
                    child: itemBuilder(item),
                  ))
              .toList(),
        );
      },
    );
  }
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          IconBadge(icon: icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminInfoRow extends StatelessWidget {
  const AdminInfoRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminStatusLine extends StatelessWidget {
  const AdminStatusLine({required this.status, this.secondary, super.key});

  final String status;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatusChip(status: status),
        if (secondary != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              secondary!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        ],
      ],
    );
  }
}

String readableClock(String value) {
  if (value.length >= 5) return value.substring(0, 5);
  return value;
}

String readableDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return formatDate(parsed);
}

String readableDateTime(DateTime? value) {
  if (value == null) return '-';
  return formatDateTime(value.toLocal());
}

Future<bool> confirmDanger(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Hapus',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}

void showAdminError(BuildContext context, Object error) {
  showSnack(context, friendlyErrorMessage(error), isError: true);
}
