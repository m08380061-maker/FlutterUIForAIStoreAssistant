import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/widgets/app_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _themeMode = 'system';
  String _language = 'en';
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _themeMode = StorageService.instance.getThemeMode() ?? 'system';
    _language = StorageService.instance.getLanguage();
  }

  Future<void> _logout() async {
    final tr = context.tr;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.logout),
        content: Text(tr.logoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(tr.logout),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await AuthService.instance.logout();
      if (mounted) context.go('/login');
    }
  }

  Future<void> _setTheme(String mode) async {
    await StorageService.instance.setThemeMode(mode);
    setState(() => _themeMode = mode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr.themeChanged),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final user = AuthService.instance.currentUser;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(tr.settings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: Text(
                      user?.initials ?? '?',
                      style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.fullName ?? tr.user, style: textTheme.titleMedium),
                        Text(user?.email ?? '', style: textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Text(
                            _capitalize(user?.role ?? tr.user),
                            style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: tr.appearance),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr.theme, style: textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _ThemeOption(label: tr.light, icon: Icons.light_mode_rounded, value: 'light', current: _themeMode, onTap: _setTheme)),
                      const SizedBox(width: 8),
                      Expanded(child: _ThemeOption(label: tr.dark, icon: Icons.dark_mode_rounded, value: 'dark', current: _themeMode, onTap: _setTheme)),
                      const SizedBox(width: 8),
                      Expanded(child: _ThemeOption(label: tr.system, icon: Icons.brightness_auto_rounded, value: 'system', current: _themeMode, onTap: _setTheme)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr.language, style: textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _LangOption(label: tr.english, value: 'en', current: _language, onTap: (v) {
                          LocaleProvider.instance.setLocale(Locale(v));
                          setState(() => _language = v);
                        }),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _LangOption(label: tr.arabic, value: 'ar', current: _language, onTap: (v) {
                          LocaleProvider.instance.setLocale(Locale(v));
                          setState(() => _language = v);
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: tr.notifications),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  _ToggleTile(
                    label: tr.pushNotifications,
                    subtitle: tr.pushNotificationsDesc,
                    value: _notifications,
                    onChanged: (v) => setState(() => _notifications = v),
                  ),
                  const Divider(height: 1),
                  _ToggleTile(
                    label: tr.lowStockAlerts,
                    subtitle: tr.lowStockAlertsDesc,
                    value: true,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: tr.accountSecurity),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _NavTile(icon: Icons.lock_outline_rounded, label: tr.changePassword, onTap: () {}),
                  const Divider(height: 1),
                  _NavTile(icon: Icons.fingerprint_rounded, label: tr.biometricLogin, onTap: () {}),
                  const Divider(height: 1),
                  _NavTile(icon: Icons.delete_outline_rounded, label: tr.deleteAccount, onTap: () {}, color: AppColors.error),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: tr.subscription),
            const SizedBox(height: 8),
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: AppColors.warning, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr.freePlan, style: textTheme.titleSmall),
                        Text(tr.upgradeSubtitle, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(tr.upgrade),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: tr.about),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _NavTile(icon: Icons.info_outline_rounded, label: tr.aboutApp, onTap: () {}),
                  const Divider(height: 1),
                  _NavTile(icon: Icons.privacy_tip_outlined, label: tr.privacyPolicy, onTap: () {}),
                  const Divider(height: 1),
                  _NavTile(icon: Icons.description_outlined, label: tr.termsOfService, onTap: () {}),
                  const Divider(height: 1),
                  _NavTile(icon: Icons.star_outline_rounded, label: tr.rateTheApp, onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: Text(tr.logout),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${tr.versionLabel}${AppConstants.appVersion}',
                style: textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.outline,
          ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.label, required this.icon, required this.value, required this.current, required this.onTap});
  final String label;
  final IconData icon;
  final String value;
  final String current;
  final Future<void> Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: active ? AppColors.primary : Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: active ? AppColors.primary : null),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: active ? AppColors.primary : null)),
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({required this.label, required this.value, required this.current, required this.onTap});
  final String label;
  final String value;
  final String current;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: active ? AppColors.primary : Theme.of(context).colorScheme.outline),
        ),
        child: Center(
          child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: active ? AppColors.primary : null)),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({required this.label, required this.subtitle, required this.value, required this.onChanged});
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: color != null ? TextStyle(color: color) : null),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
