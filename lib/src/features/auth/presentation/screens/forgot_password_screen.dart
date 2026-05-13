import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const route = '/forgot-password';

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(_emailController.text);
      if (!mounted) return;
      setState(() => _sent = true);
      showSnack(context, 'Link reset password sudah dikirim ke email kamu.');
    } catch (error) {
      if (!mounted) return;
      showSnack(context, AppException('').errorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: PagePadding(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 28),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _sent ? 'Cek email kamu.' : 'Lupa password?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _sent
                    ? 'Kalau email terdaftar di Firebase, link reset password akan masuk ke inbox atau spam. Setelah password baru dibuat, login lagi dari aplikasi.'
                    : 'Masukkan email akun client kamu. Firebase akan mengirim link untuk membuat password baru.',
                style: const TextStyle(color: AppColors.muted, height: 1.55),
              ),
              const SizedBox(height: 28),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'nama@email.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: (value) => value == null || !value.contains('@')
                    ? 'Email tidak valid'
                    : null,
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: _sent ? 'Kirim ulang link' : 'Kirim link reset',
                isLoading: _loading,
                onPressed: _sendResetEmail,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _loading
                    ? null
                    : () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Kembali ke login'),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Fitur ini khusus client/user app. Admin panel tetap pakai mekanisme login admin yang sudah ada.',
                        style: TextStyle(color: AppColors.muted, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
