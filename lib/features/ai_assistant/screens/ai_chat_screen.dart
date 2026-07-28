import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../services/ai_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _ai = AiService.instance;
  bool _loading = false;
  bool _listening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;

  final _suggestionsAr = const [
    'كم ربحت اليوم؟',
    'ما المنتجات التي تحتاج طلب؟',
    'أضف منتج بيبسي سعره 500 كمية 200',
    'أضف دين للعميل أحمد 10000',
    'أظهر تقرير اليوم',
  ];

  final _suggestionsEn = const [
    'How much profit did I make today?',
    'What products should I order?',
    'Add product Pepsi price 500 qty 200',
    'Add debt for customer Ahmed 10000',
    'Show me today\'s report',
  ];

  bool get _isArabic => _ai.isArabic;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    if (_ai.history.isEmpty) {
      _ai.sendMessage('__init__');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _loading) return;
    _inputCtrl.clear();
    setState(() => _loading = true);
    await _ai.sendMessage(text.trim());
    if (mounted) setState(() => _loading = false);
    _scrollToBottom();
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isArabic ? 'التعرف الصوتي غير متوفر' : 'Speech recognition not available')),
      );
      return;
    }
    if (_listening) {
      _speech.stop();
      setState(() => _listening = false);
      if (_inputCtrl.text.trim().isNotEmpty) _sendMessage(_inputCtrl.text);
      return;
    }
    setState(() => _listening = true);
    final locale = _isArabic ? 'ar-SA' : 'en-US';
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _inputCtrl.text = result.recognizedWords;
          _inputCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _inputCtrl.text.length));
        });
        if (result.finalResult) {
          setState(() => _listening = false);
          if (result.recognizedWords.trim().isNotEmpty) _sendMessage(result.recognizedWords);
        }
      },
      localeId: locale,
      listenMode: stt.ListenMode.dictation,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final messages = _ai.history;
    final suggestions = _isArabic ? _suggestionsAr : _suggestionsEn;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.accentOrange.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.psychology_rounded, color: AppColors.accentOrange, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_isArabic ? 'المساعد الذكي' : 'AI Assistant', style: const TextStyle(fontSize: 16)),
                  Text(_isArabic ? 'مساعد ذكي' : 'AI Agent', style: textTheme.bodySmall?.copyWith(fontSize: 11)),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.language_rounded),
              tooltip: _isArabic ? 'English' : 'العربية',
              onPressed: () { _ai.toggleLanguage(); setState(() {}); },
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: _isArabic ? 'مسح' : 'Clear',
              onPressed: () { _ai.clearHistory(); setState(() {}); },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? _WelcomeState(suggestions: suggestions, onSuggestion: _sendMessage, isArabic: _isArabic)
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(AppConstants.paddingMD),
                      itemCount: messages.length + (_loading ? 1 : 0),
                      itemBuilder: (ctx, i) {
                        if (i == messages.length) return const _TypingIndicator();
                        final msg = messages[i];
                        if (msg.text == '__init__') return const SizedBox.shrink();
                        return _MessageBubble(message: msg, isArabic: _isArabic);
                      },
                    ),
            ),
            if (!_loading && messages.length <= 2)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) => GestureDetector(
                    onTap: () => _sendMessage(suggestions[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Text(suggestions[i], style: textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                    ),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _listening ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_listening ? Icons.mic_rounded : Icons.mic_none_rounded, color: _listening ? AppColors.error : AppColors.primary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
                      minLines: 1, maxLines: 4,
                      decoration: InputDecoration(
                        hintText: _isArabic ? 'اكتب أو تحدث...' : 'Ask me anything...',
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusFull), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusFull), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_inputCtrl.text),
                    child: Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isArabic});
  final AiMessage message;
  final bool isArabic;
  bool get _isUser => message.role == AiRole.user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.accentOrange.withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.psychology_rounded, color: AppColors.accentOrange, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _isUser ? AppColors.primary : message.isError ? AppColors.error.withOpacity(0.1) : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(_isUser ? 16 : 4), bottomRight: Radius.circular(_isUser ? 4 : 16),
                ),
                border: _isUser ? null : Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Text(
                message.text,
                style: textTheme.bodyMedium?.copyWith(color: _isUser ? Colors.white : message.isError ? AppColors.error : null),
                textDirection: isArabic && !_isUser ? TextDirection.rtl : TextDirection.ltr,
                textAlign: isArabic && !_isUser ? TextAlign.right : TextAlign.start,
              ),
            ),
          ),
          if (_isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(radius: 16, backgroundColor: AppColors.primary, child: Icon(Icons.person_rounded, size: 18, color: Colors.white)),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppColors.accentOrange.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.psychology_rounded, color: AppColors.accentOrange, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4), bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => Padding(padding: EdgeInsets.only(left: i > 0 ? 4 : 0), child: _Dot(delay: i * 200))),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.delay});
  final int delay;
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _a = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () { if (mounted) _c.repeat(reverse: true); });
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _a, child: Container(width: 7, height: 7, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outline, shape: BoxShape.circle)));
  }
}

class _WelcomeState extends StatelessWidget {
  const _WelcomeState({required this.suggestions, required this.onSuggestion, required this.isArabic});
  final List<String> suggestions;
  final void Function(String) onSuggestion;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLG),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.accentOrange.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.psychology_rounded, color: AppColors.accentOrange, size: 44),
          ),
          const SizedBox(height: 20),
          Text(isArabic ? 'مساعد المتجر الذكي' : 'AI Store Assistant', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            isArabic ? 'مرحباً! اسألني عن الأرباح، المخزون، الديون، والمزيد. استخدم الميكروفون للتحدث.'
                : 'Hello! Ask me anything about your store — profits, inventory, restocking, debts, and more. Use the mic to speak.',
            style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(isArabic ? 'جرّب أن تسأل:' : 'Try asking:', style: textTheme.titleSmall),
          const SizedBox(height: 12),
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  onTap: () => onSuggestion(s),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s, style: textTheme.bodyMedium)),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
