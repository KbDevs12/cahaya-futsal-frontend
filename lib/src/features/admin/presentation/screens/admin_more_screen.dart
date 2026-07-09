import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'admin_accounts_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_reports_screen.dart';

class AdminMoreScreen extends ConsumerWidget {
  const AdminMoreScreen({super.key});

  static const route = '/admin/more';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value;
    final isSuperAdmin = session?.role == 'superadmin';

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Admin')),
      body: PagePadding(
        child: ListView(
          children: [
            AppCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session?.name ?? 'Admin', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                        Text('${session?.email ?? '-'} • ${session?.role ?? '-'}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.bar_chart_rounded,
                    title: 'Laporan',
                    subtitle: 'Lihat revenue dan rekap booking per periode',
                    onTap: () => context.push(AdminReportsScreen.route),
                  ),
                  const Divider(height: 1),
                  _MenuTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Monitoring Notifikasi',
                    subtitle: 'Cek semua notifikasi yang dikirim ke customer',
                    onTap: () => context.push(AdminNotificationsScreen.route),
                  ),
                  if (isSuperAdmin) ...[
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.manage_accounts_rounded,
                      title: 'Akun Admin',
                      subtitle: 'Khusus superadmin: tambah, edit, dan hapus admin',
                      onTap: () => context.push(AdminAccountsScreen.route),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go(LoginScreen.route);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar dari akun admin'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
