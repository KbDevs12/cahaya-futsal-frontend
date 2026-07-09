import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_common.dart';

class AdminAccountsScreen extends ConsumerWidget {
  const AdminAccountsScreen({super.key});

  static const route = '/admin/admins';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admins = ref.watch(adminAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Admin'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(adminAccountsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdminForm(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Admin'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminAccountsProvider.future),
        child: PagePadding(
          child: ListView(
            children: [
              AdminAsyncList<AdminAccountRow>(
                value: admins,
                emptyTitle: 'Belum ada akun admin',
                emptyMessage: 'Akun admin dan superadmin akan tampil di sini.',
                onRetry: () => ref.invalidate(adminAccountsProvider),
                itemBuilder: (admin) => _AdminAccountCard(
                  admin: admin,
                  onTap: () => _showAdminForm(context, ref, admin),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAdminForm(BuildContext context, WidgetRef ref, [AdminAccountRow? admin]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdminFormSheet(admin: admin),
    );
    ref.invalidate(adminAccountsProvider);
  }
}

class _AdminAccountCard extends StatelessWidget {
  const _AdminAccountCard({required this.admin, required this.onTap});

  final AdminAccountRow admin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon: admin.role == 'superadmin' ? Icons.workspace_premium_rounded : Icons.admin_panel_settings_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(admin.username, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(admin.email),
                Text(admin.role),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _AdminFormSheet extends ConsumerStatefulWidget {
  const _AdminFormSheet({this.admin});

  final AdminAccountRow? admin;

  @override
  ConsumerState<_AdminFormSheet> createState() => _AdminFormSheetState();
}

class _AdminFormSheetState extends ConsumerState<_AdminFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  String _role = 'admin';
  bool _disabled = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final admin = widget.admin;
    _usernameController = TextEditingController(text: admin?.username ?? '');
    _emailController = TextEditingController(text: admin?.email ?? '');
    _role = admin?.role ?? 'admin';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final payload = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'role': _role,
        if (widget.admin == null || _passwordController.text.trim().isNotEmpty)
          'password': _passwordController.text.trim(),
        if (widget.admin != null) 'disabled': _disabled,
      };
      if (widget.admin == null) {
        await ref.read(adminRepositoryProvider).createAdmin(payload);
      } else {
        await ref.read(adminRepositoryProvider).updateAdmin(widget.admin!.id, payload);
      }
      if (!mounted) return;
      showSnack(context, widget.admin == null ? 'Admin berhasil dibuat' : 'Admin berhasil diperbarui');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) showAdminError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.admin == null) return;
    final ok = await confirmDanger(
      context,
      title: 'Hapus admin?',
      message: 'Akun ${widget.admin!.username} akan dihapus dari Firebase dan database.',
    );
    if (!ok) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).deleteAdmin(widget.admin!.id);
      if (!mounted) return;
      showSnack(context, 'Admin berhasil dihapus');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) showAdminError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.admin != null;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEdit ? 'Edit Admin' : 'Tambah Admin', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              AppTextField(controller: _usernameController, label: 'Username', prefixIcon: Icons.person_rounded, validator: (v) => v == null || v.trim().length < 3 ? 'Minimal 3 karakter' : null),
              const SizedBox(height: 12),
              AppTextField(controller: _emailController, label: 'Email', prefixIcon: Icons.email_rounded, keyboardType: TextInputType.emailAddress, validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null),
              const SizedBox(height: 12),
              AppTextField(controller: _passwordController, label: isEdit ? 'Password baru (opsional)' : 'Password', prefixIcon: Icons.lock_rounded, obscureText: true, validator: (v) {
                if (!isEdit && (v == null || v.length < 6)) return 'Minimal 6 karakter';
                if (isEdit && v != null && v.isNotEmpty && v.length < 6) return 'Minimal 6 karakter';
                return null;
              }),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'superadmin', child: Text('Superadmin')),
                ],
                onChanged: (value) => setState(() => _role = value ?? _role),
              ),
              if (isEdit)
                SwitchListTile(
                  value: _disabled,
                  onChanged: (value) => setState(() => _disabled = value),
                  title: const Text('Disable akun Firebase'),
                  contentPadding: EdgeInsets.zero,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (isEdit) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : _delete,
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Hapus'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: PrimaryButton(
                      label: 'Simpan',
                      icon: Icons.save_rounded,
                      isLoading: _saving,
                      onPressed: _save,
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
