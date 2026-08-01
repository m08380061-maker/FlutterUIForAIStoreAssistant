import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/auth_service.dart';
import '../services/ai_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AiChatScreen — redesigned as the main hub screen.
//
// Features:
//  • Custom header with role badge + hamburger menu
//  • Left Drawer: user info, chat history, role-dashboard link, settings
//  • Welcome pane: 2-line subtitle + capability cards (fade on first keystroke)
//  • + button left of input → quick-actions bottom sheet (role-aware)
//  • Input: mic icon when empty, animated send arrow when typing
//  • Existing AI chat functionality preserved
// ─────────────────────────────────────────────────────────────────────────────

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _hasText = ValueNotifier<bool>(false);
  final _ai = AiService.instance;
  bool _loading = false;

  String get _role =>
      AuthService.instance.currentRole ?? AppConstants.roleCustomer;
  bool get _isMerchantOrWorker =>
      _role == AppConstants.roleMerchant ||
      _role == AppConstants.roleWorker;

  @override
  void initState() {
    super.initState();
    _inputCtrl.addListener(
        () => _hasText.value = _inputCtrl.text.trim().isNotEmpty);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _hasText.dispose();
    super.dispose();
  }

  // ── Messaging ──────────────────────────────────────────────────────────────

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _loading) return;
    _inputCtrl.clear();
    setState(() => _loading = true);
    final msg = await _ai.sendMessage(text.trim());
    if (mounted) {
      setState(() => _loading = false);
      // Execute in-app navigation commands resolved by the AI router.
      if (msg.navRoute != null) {
        context.push(msg.navRoute!);
      }
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Quick actions sheet ────────────────────────────────────────────────────

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _QuickActionsSheet(
        role: _role,
        tr: ctx.tr,
        onSelect: (route) {
          Navigator.pop(ctx);
          context.push(route);
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    // Filter out the internal __init__ seed message
    final messages =
        _ai.history.where((m) => m.text != '__init__').toList();

    return Scaffold(
      key: _scaffoldKey,
      drawer: _AppDrawer(
        role: _role,
        tr: tr,
        onClearHistory: () {
          _ai.clearHistory();
          setState(() {});
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom header ──────────────────────────────────────────────
            _ChatHeader(
              role: _role,
              tr: tr,
              onMenuTap: () =>
                  _scaffoldKey.currentState?.openDrawer(),
              onClearTap: () {
                _ai.clearHistory();
                setState(() {});
              },
            ),
            const Divider(height: 1),

            // ── Messages / welcome ─────────────────────────────────────────
            Expanded(
              child: messages.isEmpty
                  ? _WelcomePane(
                      hasText: _hasText,
                      isMerchantOrWorker: _isMerchantOrWorker,
                      onSuggestion: _sendMessage,
                      tr: tr,
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount:
                          messages.length + (_loading ? 1 : 0),
                      itemBuilder: (ctx, i) {
                        if (i == messages.length) {
                          return const _TypingIndicator();
                        }
                        return _MessageBubble(msg: messages[i]);
                      },
                    ),
            ),

            // ── Input bar ──────────────────────────────────────────────────
            _InputBar(
              ctrl: _inputCtrl,
              hasText: _hasText,
              isMerchantOrWorker: _isMerchantOrWorker,
              onSend: _sendMessage,
              onPlusTap: _showQuickActions,
              tr: tr,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChatHeader
// ─────────────────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.role,
    required this.tr,
    required this.onMenuTap,
    required this.onClearTap,
  });
  final String role;
  final AppTranslations tr;
  final VoidCallback onMenuTap;
  final VoidCallback onClearTap;

  Color get _roleColor {
    switch (role) {
      case AppConstants.roleMerchant:
        return AppColors.primary;
      case AppConstants.roleWorker:
        return const Color(0xFF059669);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  String _roleLabel(AppTranslations tr) {
    switch (role) {
      case AppConstants.roleMerchant:
        return tr.merchant;
      case AppConstants.roleWorker:
        return tr.worker;
      default:
        return tr.customerLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: onMenuTap,
            ),
            const SizedBox(width: 2),
            // AI logo
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology_rounded,
                  color: AppColors.accentOrange, size: 17),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tr.aiWelcomeTitle,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    tr.poweredByGemini,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ),
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: _roleColor.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusFull),
                border:
                    Border.all(color: _roleColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                _roleLabel(tr),
                style: TextStyle(
                    fontSize: 11,
                    color: _roleColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              tooltip: tr.clearHistory,
              onPressed: onClearTap,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WelcomePane
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomePane extends StatelessWidget {
  const _WelcomePane({
    required this.hasText,
    required this.isMerchantOrWorker,
    required this.onSuggestion,
    required this.tr,
  });
  final ValueNotifier<bool> hasText;
  final bool isMerchantOrWorker;
  final void Function(String) onSuggestion;
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        children: [
          // ── AI icon + 2-line title ────────────────────────────────────────
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_rounded,
                color: AppColors.accentOrange, size: 38),
          ),
          const SizedBox(height: 12),
          Text(
            tr.aiWelcomeTitle,
            style: textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            tr.homeSubtitle,
            style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),

          // ── Capability cards — fade out when typing ───────────────────────
          ValueListenableBuilder<bool>(
            valueListenable: hasText,
            builder: (ctx, typing, child) => AnimatedOpacity(
              opacity: typing ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 220),
              child: IgnorePointer(ignoring: typing, child: child),
            ),
            child: Column(
              children: [
                if (isMerchantOrWorker) ...[
                  Row(
                    children: [
                      _CapCard(
                        icon: Icons.inventory_2_outlined,
                        label: tr.capabilityInventory,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      _CapCard(
                        icon: Icons.point_of_sale_outlined,
                        label: tr.capabilitySales,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _CapCard(
                        icon: Icons.bar_chart_rounded,
                        label: tr.capabilityInsights,
                        color: AppColors.accentOrange,
                      ),
                      const SizedBox(width: 10),
                      _CapCard(
                        icon: Icons.document_scanner_rounded,
                        label: tr.capabilityScan,
                        color: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                // Suggestion prompts
                Text(
                  tr.tryAsking,
                  style: textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 8),
                _SuggestionChip(
                    text: tr.suggestion1, onTap: onSuggestion),
                _SuggestionChip(
                    text: tr.suggestion2, onTap: onSuggestion),
                _SuggestionChip(
                    text: tr.suggestion3, onTap: onSuggestion),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CapCard extends StatelessWidget {
  const _CapCard({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius:
              BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip(
      {required this.text, required this.onTap});
  final String text;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withValues(alpha: 0.25),
          ),
          borderRadius:
              BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 15,
                color: Theme.of(context).colorScheme.outline),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
            Icon(Icons.north_west_rounded,
                size: 13,
                color: Theme.of(context).colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MessageBubble
// ─────────────────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.msg});
  final AiMessage msg;

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == AiRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded,
                  color: AppColors.accentOrange, size: 15),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                msg.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUser ? Colors.white : null,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TypingIndicator
// ─────────────────────────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_rounded,
                color: AppColors.accentOrange, size: 15),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  3, (i) => _AnimatedDot(delay: i * 200)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  const _AnimatedDot({required this.delay});
  final int delay;

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, _) => Container(
        width: 7,
        height: 7 + (_anim.value * 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: AppColors.primary
              .withValues(alpha: 0.4 + _anim.value * 0.6),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _InputBar
// ─────────────────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.ctrl,
    required this.hasText,
    required this.isMerchantOrWorker,
    required this.onSend,
    required this.onPlusTap,
    required this.tr,
  });
  final TextEditingController ctrl;
  final ValueNotifier<bool> hasText;
  final bool isMerchantOrWorker;
  final void Function(String) onSend;
  final VoidCallback onPlusTap;
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          // + button (merchant/worker only)
          if (isMerchantOrWorker) ...[
            Material(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onPlusTap,
                child: const SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(Icons.add_rounded,
                      color: AppColors.primary, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: ctrl,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
                decoration: InputDecoration(
                  hintText: tr.typeMessage,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Mic ↔ Send toggle
          ValueListenableBuilder<bool>(
            valueListenable: hasText,
            builder: (ctx, typing, _) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: typing
                  ? _SendButton(
                      key: const ValueKey('send'),
                      onTap: () => onSend(ctrl.text),
                    )
                  : _MicButton(key: const ValueKey('mic')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_upward_rounded,
            color: Colors.white, size: 22),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withValues(alpha: 0.4),
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.mic_outlined,
        color: Theme.of(context).colorScheme.outline,
        size: 22,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _QuickActionsSheet
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsSheet extends StatelessWidget {
  const _QuickActionsSheet({
    required this.role,
    required this.tr,
    required this.onSelect,
  });
  final String role;
  final AppTranslations tr;
  final void Function(String route) onSelect;

  @override
  Widget build(BuildContext context) {
    final items = _items(tr, role);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(tr.quickActions,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items.map((item) => ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 2),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(item.icon, color: item.color, size: 22),
                ),
                title: Text(item.label,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color:
                        Theme.of(context).colorScheme.outline),
                onTap: () => onSelect(item.route),
              )),
        ],
      ),
    );
  }

  static List<_NavItem> _items(AppTranslations tr, String role) {
    final all = [
      _NavItem(
        icon: Icons.document_scanner_rounded,
        label: tr.quickScanCashier,
        color: const Color(0xFF059669),
        route: '/scanner/live',
      ),
      _NavItem(
        icon: Icons.receipt_long_rounded,
        label: tr.sales,
        color: AppColors.primary,
        route: '/sales',
      ),
      _NavItem(
        icon: Icons.inventory_2_rounded,
        label: tr.inventory,
        color: const Color(0xFF7C3AED),
        route: '/inventory',
      ),
      _NavItem(
        icon: Icons.bar_chart_rounded,
        label: tr.analytics,
        color: AppColors.accentOrange,
        route: '/analytics',
      ),
      _NavItem(
        icon: Icons.person_add_rounded,
        label: tr.debts,
        color: AppColors.error,
        route: '/debts',
      ),
    ];
    if (role == AppConstants.roleWorker) return all.sublist(0, 3);
    return all; // merchant gets all 5
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
  final IconData icon;
  final String label;
  final Color color;
  final String route;
}

// ─────────────────────────────────────────────────────────────────────────────
// _AppDrawer
// ─────────────────────────────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.role,
    required this.tr,
    required this.onClearHistory,
  });
  final String role;
  final AppTranslations tr;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          DrawerHeader(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF1557B0)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    (user?.fullName ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                Text(
                  user?.fullName ?? tr.aiWelcomeTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                if (user?.storeName != null)
                  Text(
                    user!.storeName!,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12),
                  ),
              ],
            ),
          ),

          // ── Chat history ──────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 8, 8, 4),
            child: Row(
              children: [
                Text(
                  tr.chatHistory,
                  style: textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClearHistory,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(tr.clearHistory,
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          ListTile(
            dense: true,
            leading: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chat_rounded,
                  color: AppColors.primary, size: 17),
            ),
            title: Text(tr.newChat,
                style: const TextStyle(fontSize: 13)),
            subtitle: Text(tr.noChatsYet,
                style: const TextStyle(fontSize: 11)),
            selected: true,
            selectedTileColor:
                AppColors.primary.withValues(alpha: 0.05),
          ),

          const Divider(height: 1),

          // ── Role-specific dashboard link ──────────────────────────────────
          if (role == AppConstants.roleMerchant)
            ListTile(
              leading: const Icon(Icons.dashboard_rounded, size: 22),
              title: Text(tr.dashboard),
              onTap: () {
                Navigator.pop(context);
                context.push('/merchant/dashboard');
              },
            )
          else if (role == AppConstants.roleWorker)
            ListTile(
              leading: const Icon(Icons.dashboard_rounded, size: 22),
              title: Text(tr.dashboard),
              onTap: () {
                Navigator.pop(context);
                context.push('/worker/dashboard');
              },
            ),

          const Spacer(),
          const Divider(height: 1),

          // ── Settings ──────────────────────────────────────────────────────
          ListTile(
            leading:
                const Icon(Icons.settings_outlined, size: 22),
            title: Text(tr.settings),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
