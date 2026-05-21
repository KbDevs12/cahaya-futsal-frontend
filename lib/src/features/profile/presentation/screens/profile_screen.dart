import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../bookings/presentation/providers/booking_providers.dart';
import '../../../bookings/presentation/screens/my_bookings_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../data/models/user_profile.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const route = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final bookings = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (user) {
          final bookingCount = bookings.maybeWhen(
            data: (items) => items.length,
            orElse: () => 0,
          );
          final pendingCount = bookings.maybeWhen(
            data: (items) => items
                .where(
                  (item) =>
                      item.status == 'pending_payment' ||
                      item.status == 'awaiting_verification',
                )
                .length,
            orElse: () => 0,
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(profileProvider);
              ref.invalidate(myBookingsProvider);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _ProfileHero(user: user),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Booking',
                        value: '$bookingCount',
                        icon: Icons.receipt_long_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Perlu Dicek',
                        value: '$pendingCount',
                        icon: Icons.schedule_rounded,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const SectionHeader(
                  title: 'Informasi akun',
                  subtitle:
                      'Lengkapi profil agar admin mudah menghubungi kamu.',
                ),
                const SizedBox(height: 12),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.mail_outline_rounded,
                        title: 'Email',
                        subtitle: user.email,
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.phone_outlined,
                        title: 'Nomor HP',
                        subtitle: user.phone.isEmpty
                            ? 'Belum diisi'
                            : user.phone,
                        trailingText: user.phone.isEmpty ? 'Lengkapi' : null,
                        onTap: () => _showEditProfile(context, ref, user),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.verified_user_outlined,
                        title: 'Status email',
                        subtitle: user.emailVerified
                            ? 'Terverifikasi'
                            : 'Belum terverifikasi',
                        color: user.emailVerified
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.calendar_today_outlined,
                        title: 'Bergabung sejak',
                        subtitle: _formatDate(user.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const SectionHeader(title: 'Aksi cepat'),
                const SizedBox(height: 12),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ActionTile(
                        icon: Icons.edit_rounded,
                        title: 'Edit profile',
                        subtitle: 'Ubah nama dan nomor HP',
                        onTap: () => _showEditProfile(context, ref, user),
                      ),
                      const Divider(height: 1),
                      _ActionTile(
                        icon: Icons.receipt_long_rounded,
                        title: 'Booking saya',
                        subtitle: 'Lihat status booking dan pembayaran',
                        onTap: () => context.go(MyBookingsScreen.route),
                      ),
                      const Divider(height: 1),
                      _ActionTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifikasi',
                        subtitle: 'Update pembayaran dari admin',
                        onTap: () => context.push(NotificationsScreen.route),
                      ),
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
                  label: const Text('Keluar dari akun'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final local = date.toLocal();
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  Future<void> _showEditProfile(
    BuildContext context,
    WidgetRef ref,
    UserProfile user,
  ) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _EditProfileSheet(user: user),
    );

    if (saved == true && context.mounted) {
      showSnack(context, 'Profile berhasil diperbarui');
    }
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.user});

  final UserProfile user;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    var resetSavingState = true;
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );
      ref.invalidate(profileProvider);

      if (!mounted) return;
      resetSavingState = false;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      showSnack(context, friendlyErrorMessage(error), isError: true);
    } finally {
      if (mounted && resetSavingState) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Edit profile',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Data ini dipakai admin untuk menghubungi kamu terkait booking.',
            style: TextStyle(color: AppColors.muted, height: 1.45),
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: _nameController,
            label: 'Nama lengkap',
            prefixIcon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _phoneController,
            label: 'Nomor HP',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Simpan Perubahan',
                  icon: Icons.check_rounded,
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final initial = user.name.trim().isNotEmpty
        ? user.name.trim()[0].toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(.24)),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isEmpty ? 'User' : user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    user.emailVerified
                        ? 'Email terverifikasi'
                        : 'Email belum verifikasi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, size: 42),
          const SizedBox(height: 14),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color = AppColors.primary,
    this.trailingText,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: IconBadge(icon: icon, color: color, size: 42),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailingText == null
          ? null
          : Text(
              trailingText!,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: IconBadge(icon: icon, size: 42),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
