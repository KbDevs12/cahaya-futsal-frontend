import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_common.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  static const route = '/admin/users';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User'),
        actions: [
          IconButton(
            tooltip: 'Tambah user',
            onPressed: () => _showCreateUser(context, ref),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(adminUsersProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUser(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah User'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminUsersProvider.future),
        child: PagePadding(
          child: ListView(
            children: [
              AdminAsyncList<AdminUserRow>(
                value: users,
                emptyTitle: 'Belum ada user',
                emptyMessage:
                    'Customer yang mendaftar atau ditambahkan admin akan tampil di sini.',
                onRetry: () => ref.invalidate(adminUsersProvider),
                itemBuilder: (user) => _UserCard(
                  user: user,
                  onTap: () => _showUserDetail(context, ref, user),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateUser(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateUserSheet(),
    );
    ref.invalidate(adminUsersProvider);
  }

  Future<void> _showUserDetail(
    BuildContext context,
    WidgetRef ref,
    AdminUserRow user,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserDetailSheet(user: user),
    );
    ref.invalidate(adminUsersProvider);
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onTap});

  final AdminUserRow user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(
            icon: user.emailVerified
                ? Icons.verified_user_rounded
                : Icons.person_outline_rounded,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(user.email),
                Text(user.phone.isEmpty ? 'No HP belum diisi' : user.phone),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _CreateUserSheet extends ConsumerStatefulWidget {
  const _CreateUserSheet();

  @override
  ConsumerState<_CreateUserSheet> createState() => _CreateUserSheetState();
}

class _CreateUserSheetState extends ConsumerState<_CreateUserSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _emailVerified = true;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showSnack(context, 'Nama, email, dan password wajib diisi');
      return;
    }
    if (password.length < 6) {
      showSnack(context, 'Password minimal 6 karakter');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).createUser({
        'name': name,
        'email': email,
        'password': password,
        'phone': _phoneController.text.trim(),
        'email_verified': _emailVerified,
      });
      if (!mounted) return;
      showSnack(context, 'User berhasil ditambahkan');
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tambah User',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _nameController,
              label: 'Nama',
              prefixIcon: Icons.person_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _emailController,
              label: 'Email',
              prefixIcon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _phoneController,
              label: 'No. HP',
              prefixIcon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _passwordController,
              label: 'Password awal',
              prefixIcon: Icons.lock_rounded,
              obscureText: true,
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              value: _emailVerified,
              onChanged: (value) => setState(() => _emailVerified = value),
              title: const Text('Email langsung terverifikasi'),
              subtitle: const Text(
                'Aktifkan agar user bisa login tanpa verifikasi email manual.',
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Tambah User',
              icon: Icons.person_add_alt_1_rounded,
              isLoading: _saving,
              onPressed: _create,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserDetailSheet extends ConsumerStatefulWidget {
  const _UserDetailSheet({required this.user});

  final AdminUserRow user;

  @override
  ConsumerState<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends ConsumerState<_UserDetailSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late bool _emailVerified;
  bool _saving = false;
  late final Future<AdminUserDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = ref
        .read(adminRepositoryProvider)
        .userDetail(widget.user.id);
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _emailVerified = widget.user.emailVerified;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateUser(widget.user.id, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email_verified': _emailVerified,
      });
      if (!mounted) return;
      showSnack(context, 'User berhasil diperbarui');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) showAdminError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDanger(
      context,
      title: 'Hapus user?',
      message:
          'User ${widget.user.name} akan dihapus jika belum punya riwayat booking.',
    );
    if (!ok) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).deleteUser(widget.user.id);
      if (!mounted) return;
      showSnack(context, 'User berhasil dihapus');
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Detail User',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            FutureBuilder<AdminUserDetail>(
              future: _detailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Gagal load detail: ${snapshot.error}');
                }
                final data = snapshot.data;
                if (data == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    AdminInfoRow(
                      label: 'Total booking',
                      value: '${data.totalBookings}',
                    ),
                    AdminInfoRow(
                      label: 'Total belanja',
                      value: formatRupiah(data.totalSpent),
                    ),
                    AdminInfoRow(
                      label: 'Last activity',
                      value: readableDateTime(data.lastActivityAt),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _nameController,
              label: 'Nama',
              prefixIcon: Icons.person_rounded,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _phoneController,
              label: 'No. HP',
              prefixIcon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            AdminInfoRow(label: 'Email', value: widget.user.email),
            SwitchListTile(
              value: _emailVerified,
              onChanged: (value) => setState(() => _emailVerified = value),
              title: const Text('Email terverifikasi'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _delete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Hapus'),
                  ),
                ),
                const SizedBox(width: 12),
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
    );
  }
}
