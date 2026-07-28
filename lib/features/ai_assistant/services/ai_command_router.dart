import '../providers/ai_provider.dart';
import '../providers/llama_cpp_provider.dart';
import '../providers/rule_based_provider.dart';
import 'ai_context_service.dart';

class AiCommandRouter {
  AiCommandRouter._();
  static final AiCommandRouter instance = AiCommandRouter._();

  final AiContextService _contextService = AiContextService.instance;

  final List<AiProvider> _providers = const [
    LlamaCppProvider(),
    RuleBasedProvider(),
  ];

  Future<String> route(String message, {bool isArabic = false}) async {
    final context = await _contextService.buildContext();

    for (final provider in _providers) {
      if (provider.isAvailable) {
        return provider.respond(message, context, isArabic: isArabic);
      }
    }

    return 'I\'m unable to process your request right now. Please try again.';
  }

  void invalidateContext() => _contextService.invalidate();
}
