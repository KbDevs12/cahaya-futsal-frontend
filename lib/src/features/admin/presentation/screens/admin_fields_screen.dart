import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_common.dart';

class AdminFieldsScreen extends ConsumerWidget {
  const AdminFieldsScreen({super.key});

  static const route = '/admin/fields';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(adminFieldsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Lapangan'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(adminFieldsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFieldForm(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Lapangan'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminFieldsProvider.future),
        child: PagePadding(
          child: ListView(
            children: [
              AdminAsyncList<AdminFieldRow>(
                value: fields,
                emptyTitle: 'Belum ada lapangan',
                emptyMessage: 'Tambahkan lapangan agar bisa dipesan customer.',
                onRetry: () => ref.invalidate(adminFieldsProvider),
                itemBuilder: (field) => _FieldCard(
                  field: field,
                  onTap: () => _showFieldDetail(context, ref, field),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFieldForm(BuildContext context, WidgetRef ref, [AdminFieldRow? field]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FieldFormSheet(field: field),
    );
    ref.invalidate(adminFieldsProvider);
  }

  Future<void> _showFieldDetail(BuildContext context, WidgetRef ref, AdminFieldRow field) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FieldDetailSheet(field: field),
    );
    ref.invalidate(adminFieldsProvider);
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.field, required this.onTap});

  final AdminFieldRow field;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon: Icons.stadium_rounded, color: field.isAvailable ? AppColors.primary : Colors.grey),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${field.type} • ${formatRupiah(field.pricePerHour)}/jam'),
                Text(field.isAvailable ? 'Tersedia' : 'Tidak tersedia'),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _FieldDetailSheet extends ConsumerWidget {
  const _FieldDetailSheet({required this.field});

  final AdminFieldRow field;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(adminFieldSchedulesProvider(field.id));
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text(field.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                IconButton(
                  onPressed: () => _showFieldForm(context, ref, field),
                  icon: const Icon(Icons.edit_rounded),
                ),
                IconButton(
                  onPressed: () async {
                    final ok = await confirmDanger(context, title: 'Hapus lapangan?', message: 'Lapangan ${field.name} akan dihapus bersama jadwalnya.');
                    if (!ok || !context.mounted) return;
                    try {
                      await ref.read(adminRepositoryProvider).deleteField(field.id);
                      if (context.mounted) {
                        showSnack(context, 'Lapangan berhasil dihapus');
                        Navigator.of(context).pop();
                      }
                    } catch (error) {
                      if (context.mounted) showAdminError(context, error);
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AdminInfoRow(label: 'Harga', value: formatRupiah(field.pricePerHour)),
            AdminInfoRow(label: 'Status', value: field.isAvailable ? 'Tersedia' : 'Tidak tersedia'),
            AdminInfoRow(label: 'Deskripsi', value: field.description),
            const SizedBox(height: 18),
            SectionHeader(
              title: 'Jadwal Khusus',
              subtitle: 'Atur jam buka/tutup per tanggal.',
              trailing: TextButton.icon(
                onPressed: () => _showScheduleForm(context, ref, field.id),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Jadwal'),
              ),
            ),
            const SizedBox(height: 10),
            schedules.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Gagal load jadwal: $error'),
              data: (items) => items.isEmpty
                  ? const Text('Belum ada jadwal khusus.')
                  : Column(
                      children: items.map((schedule) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(readableDate(schedule.date)),
                            subtitle: Text(schedule.isClosed ? 'Tutup' : '${readableClock(schedule.openTime)}-${readableClock(schedule.closeTime)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () async {
                                try {
                                  await ref.read(adminRepositoryProvider).deleteSchedule(field.id, schedule.date);
                                  ref.invalidate(adminFieldSchedulesProvider(field.id));
                                  if (context.mounted) showSnack(context, 'Jadwal dihapus');
                                } catch (error) {
                                  if (context.mounted) showAdminError(context, error);
                                }
                              },
                            ),
                          )).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFieldForm(BuildContext context, WidgetRef ref, AdminFieldRow field) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FieldFormSheet(field: field),
    );
    ref.invalidate(adminFieldsProvider);
  }

  Future<void> _showScheduleForm(BuildContext context, WidgetRef ref, String fieldId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScheduleFormSheet(fieldId: fieldId),
    );
    ref.invalidate(adminFieldSchedulesProvider(fieldId));
  }
}

class _FieldFormSheet extends ConsumerStatefulWidget {
  const _FieldFormSheet({this.field});

  final AdminFieldRow? field;

  @override
  ConsumerState<_FieldFormSheet> createState() => _FieldFormSheetState();
}

class _FieldFormSheetState extends ConsumerState<_FieldFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  bool _isAvailable = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final field = widget.field;
    _nameController = TextEditingController(text: field?.name ?? '');
    _priceController = TextEditingController(text: field?.pricePerHour.toString() ?? '');
    _descriptionController = TextEditingController(text: field?.description ?? '');
    _isAvailable = field?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final payload = {
      'name': _nameController.text.trim(),
      'type': 'futsal',
      'price_per_hour': int.parse(_priceController.text.trim()),
      'description': _descriptionController.text.trim(),
      if (widget.field != null) 'is_available': _isAvailable,
    };
    try {
      if (widget.field == null) {
        await ref.read(adminRepositoryProvider).createField(payload);
      } else {
        await ref.read(adminRepositoryProvider).updateField(widget.field!.id, payload);
      }
      if (!mounted) return;
      showSnack(context, widget.field == null ? 'Lapangan dibuat' : 'Lapangan diperbarui');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) showAdminError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.field == null ? 'Tambah Lapangan' : 'Edit Lapangan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              AppTextField(controller: _nameController, label: 'Nama lapangan', prefixIcon: Icons.stadium_rounded, validator: (v) => v == null || v.trim().length < 3 ? 'Minimal 3 karakter' : null),
              const SizedBox(height: 12),
              AppTextField(controller: _priceController, label: 'Harga per jam', prefixIcon: Icons.attach_money_rounded, keyboardType: TextInputType.number, validator: (v) => int.tryParse(v ?? '') == null ? 'Harga tidak valid' : null),
              const SizedBox(height: 12),
              AppTextField(controller: _descriptionController, label: 'Deskripsi', prefixIcon: Icons.notes_rounded, maxLines: 3),
              if (widget.field != null)
                SwitchListTile(
                  value: _isAvailable,
                  onChanged: (value) => setState(() => _isAvailable = value),
                  title: const Text('Lapangan tersedia'),
                  contentPadding: EdgeInsets.zero,
                ),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Simpan', icon: Icons.save_rounded, isLoading: _saving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleFormSheet extends ConsumerStatefulWidget {
  const _ScheduleFormSheet({required this.fieldId});

  final String fieldId;

  @override
  ConsumerState<_ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends ConsumerState<_ScheduleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController(text: ymd(DateTime.now()));
  final _openController = TextEditingController(text: '08:00');
  final _closeController = TextEditingController(text: '23:00');
  bool _isClosed = false;
  bool _saving = false;

  @override
  void dispose() {
    _dateController.dispose();
    _openController.dispose();
    _closeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).upsertSchedule(widget.fieldId, {
        'date': _dateController.text.trim(),
        'open_time': _openController.text.trim(),
        'close_time': _closeController.text.trim(),
        'is_closed': _isClosed,
      });
      if (!mounted) return;
      showSnack(context, 'Jadwal tersimpan');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) showAdminError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Atur Jadwal', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              AppTextField(controller: _dateController, label: 'Tanggal (YYYY-MM-DD)', prefixIcon: Icons.calendar_month_rounded, validator: (v) => v == null || DateTime.tryParse(v) == null ? 'Tanggal tidak valid' : null),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: AppTextField(controller: _openController, label: 'Buka', prefixIcon: Icons.access_time_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(controller: _closeController, label: 'Tutup', prefixIcon: Icons.access_time_filled_rounded)),
                ],
              ),
              SwitchListTile(
                value: _isClosed,
                onChanged: (value) => setState(() => _isClosed = value),
                title: const Text('Tutup seharian'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Simpan Jadwal', icon: Icons.save_rounded, isLoading: _saving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
