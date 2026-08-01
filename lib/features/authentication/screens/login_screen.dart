import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utilities/app_validators.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    final result = await AuthService.instance.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      _goHome(result.user?.role);
    } else {
      setState(() => _error = result.errorMessage ?? context.tr.loginError);
    }
  }

  void _goHome(String? role) {
    switch (role) {
      case AppConstants.roleMerchant:
        context.go('/merchant/dashboard');
      case AppConstants.roleWorker:
        context.go('/worker/dashboard');
      case AppConstants.roleCustomer:
        context.go('/customer/search');
      default:
        context.go('/account-type');
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Logo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(context.tr.login, style: textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  context.tr.loginSubtitle,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 32),

                // Error banner
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                CustomTextField(
                  label: context.tr.email,
                  hint: context.tr.emailHint,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: AppValidators.email,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: context.tr.password,
                  hint: context.tr.passwordHint,
                  controller: _passCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: AppValidators.password,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(context.tr.forgotPassword),
                  ),
                ),
                const SizedBox(height: 8),
                CustomButton(
                  label: context.tr.login,
                  onPressed: _submit,
                  isLoading: _loading,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr.noAccount,
                      style: textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go('/account-type'),
                      child: Text(context.tr.register),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
