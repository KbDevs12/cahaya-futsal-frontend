import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const route = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (user) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary.withOpacity(.12),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user.name.isEmpty ? 'User' : user.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              tileColor: Colors.white,
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit profile'),
              subtitle: Text(
                user.phone.isEmpty ? 'Nomor HP belum diisi' : user.phone,
              ),
              onTap: () =>
                  _showEditProfile(context, ref, user.name, user.phone),
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              tileColor: Colors.white,
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Keluar'),
              onTap: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go(LoginScreen.route);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProfile(
    BuildContext context,
    WidgetRef ref,
    String name,
    String phone,
  ) async {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Profile',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            AppTextField(controller: nameController, label: 'Nama'),
            const SizedBox(height: 12),
            AppTextField(
              controller: phoneController,
              label: 'Nomor HP',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () async {
                try {
                  await ref
                      .read(profileRepositoryProvider)
                      .updateProfile(
                        name: nameController.text,
                        phone: phoneController.text,
                      );
                  ref.invalidate(profileProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    showSnack(context, 'Profile diperbarui');
                  }
                } catch (error) {
                  if (context.mounted)
                    showSnack(context, AppException("").errorMessage(error));
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    phoneController.dispose();
  }
}
