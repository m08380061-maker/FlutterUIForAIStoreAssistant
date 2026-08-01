import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utilities/app_validators.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.role});
  final String role;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _storeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  bool get _isMerchant => widget.role == AppConstants.roleMerchant;

  IconData get _roleIcon {
    switch (widget.role) {
      case AppConstants.roleMerchant: return Icons.store_rounded;
      case AppConstants.roleWorker: return Icons.badge_rounded;
      default: return Icons.person_rounded;
    }
  }

  String _roleLabel(BuildContext context) {
    switch (widget.role) {
      case AppConstants.roleMerchant: return context.tr.merchant;
      case AppConstants.roleWorker: return context.tr.worker;
      default: return context.tr.customerLabel;
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    final result = await AuthService.instance.register(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      phone: _phoneCtrl.text.trim(),
      role: widget.role,
      storeName: _isMerchant ? _storeCtrl.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      _goHome();
    } else {
      setState(() => _error = result.errorMessage ?? context.tr.registrationFailed);
    }
  }

  void _goHome() {
    switch (widget.role) {
      case AppConstants.roleMerchant: context.go('/merchant/dashboard');
      case AppConstants.roleWorker: context.go('/worker/dashboard');
      default: context.go('/customer/search');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _storeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final roleLabel = _roleLabel(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/account-type')),
        title: Text('${context.tr.createAccount} - $roleLabel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_roleIcon, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(roleLabel, style: textTheme.labelMedium?.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(_error!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
                ),
                const SizedBox(height: 16),
              ],

              CustomTextField(
                label: context.tr.yourFullName,
                hint: context.tr.yourFullName,
                controller: _nameCtrl,
                prefixIcon: const Icon(Icons.person_outlined),
                textInputAction: TextInputAction.next,
                validator: (v) => AppValidators.required(v, context.tr.yourFullName),
              ),
              const SizedBox(height: 16),
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
                label: context.tr.phone,
                hint: context.tr.phoneHint,
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.phone_outlined),
                validator: AppValidators.phone,
              ),
              if (_isMerchant) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: context.tr.storeName,
                  hint: context.tr.yourStoreName,
                  controller: _storeCtrl,
                  prefixIcon: const Icon(Icons.store_outlined),
                  textInputAction: TextInputAction.next,
                  validator: (v) => AppValidators.required(v, context.tr.storeName),
                ),
              ],
              const SizedBox(height: 16),
              CustomTextField(
                label: context.tr.password,
                hint: context.tr.passwordHint,
                controller: _passCtrl,
                obscureText: true,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.lock_outlined),
                validator: AppValidators.password,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: context.tr.confirmPassword,
                hint: context.tr.passwordHint,
                controller: _confirmCtrl,
                obscureText: true,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.lock_outlined),
                validator: (v) => AppValidators.confirmPassword(v, _passCtrl.text),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: context.tr.register,
                onPressed: _submit,
                isLoading: _loading,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(context.tr.alreadyHaveAccount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
