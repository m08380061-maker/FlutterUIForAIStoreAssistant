/// Model Manager screen — lets the user download and manage on-device AI
/// model files without leaving the app.
///
/// ## What this screen does
/// - Shows the current status of the chat model (llama.cpp GGUF) and the
///   vision model (ONNX Runtime) in two cards.
/// - Provides per-model Download / Retry buttons with live progress bars.
/// - Explains where each model comes from and what it is used for.
/// - Never bundles model weights — they are always downloaded on demand.
///
/// ## Navigation
/// Reachable from Settings → "AI Models". Can also be pushed directly
/// via `context.go('/ai-models')` from any screen.
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/ai_assistant/services/model_download_service.dart';
import '../../../features/ai_assistant/services/model_manager.dart';
import '../../../shared/widgets/app_card.dart';

class ModelSetupScreen extends StatefulWidget {
  const ModelSetupScreen({super.key});

  @override
  State<ModelSetupScreen> createState() => _ModelSetupScreenState();
}

class _ModelSetupScreenState extends State<ModelSetupScreen> {
  // ── State per model ────────────────────────────────────────────────────────

  bool _chatReady    = false;
  bool _visionReady  = false;

  // null   = idle
  // 0–1.0  = downloading
  double? _chatProgress;
  double? _visionProgress;

  String? _chatError;
  String? _visionError;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _chatReady   = ModelManager.instance.isChatModelReady;
      _visionReady = ModelManager.instance.isVisionModelReady;
    });
  }

  // ── Download helpers ───────────────────────────────────────────────────────

  Future<void> _downloadChat() async {
    final path = ModelManager.instance.llamaModelPath;
    if (path == null) {
      setState(() => _chatError = 'Could not resolve app documents directory.');
      return;
    }
    setState(() { _chatProgress = 0; _chatError = null; });

    try {
      await ModelDownloadService.instance.download(
        ModelManager.chatModelUrl,
        path,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _chatProgress = total > 0 ? received / total : null;
          });
        },
      );
      if (!mounted) return;
      setState(() { _chatProgress = null; _chatReady = true; });
      _showSnack('Chat model downloaded successfully!', success: true);
    } on ModelDownloadException catch (e) {
      if (!mounted) return;
      setState(() { _chatProgress = null; _chatError = e.message; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _chatProgress = null; _chatError = e.toString(); });
    }
  }

  Future<void> _downloadVision() async {
    final modelPath  = ModelManager.instance.onnxModelPath;
    final labelsPath = ModelManager.instance.onnxLabelsPath;
    if (modelPath == null || labelsPath == null) {
      setState(() => _visionError = 'Could not resolve app documents directory.');
      return;
    }
    setState(() { _visionProgress = 0; _visionError = null; });

    try {
      // Download model file first.
      await ModelDownloadService.instance.download(
        ModelManager.visionModelUrl,
        modelPath,
        onProgress: (received, total) {
          if (!mounted) return;
          // Model is ~90 % of the total download work; scale to 0–0.9.
          setState(() {
            _visionProgress = total > 0 ? (received / total) * 0.9 : null;
          });
        },
      );

      if (!mounted) return;
      setState(() => _visionProgress = 0.92);

      // Download labels file (small, ~50 KB).
      await ModelDownloadService.instance.download(
        ModelManager.visionLabelsUrl,
        labelsPath,
        onProgress: (received, total) {
          if (!mounted) return;
          // Labels are ~10 % of remaining; scale 0.9–1.0.
          setState(() {
            _visionProgress = total > 0
                ? 0.9 + (received / total) * 0.1
                : 0.95;
          });
        },
      );

      if (!mounted) return;
      setState(() { _visionProgress = null; _visionReady = true; });
      _showSnack('Vision model downloaded successfully!', success: true);
    } on ModelDownloadException catch (e) {
      if (!mounted) return;
      setState(() { _visionProgress = null; _visionError = e.message; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _visionProgress = null; _visionError = e.toString(); });
    }
  }

  Future<void> _deleteChat() async {
    final path = ModelManager.instance.llamaModelPath;
    if (path == null) return;
    try {
      await ModelDownloadService.instance.deleteModel(path);
      if (!mounted) return;
      setState(() { _chatReady = false; _chatError = null; });
      _showSnack('Chat model removed.');
    } catch (e) {
      _showSnack('Delete failed: $e', success: false);
    }
  }

  Future<void> _deleteVision() async {
    final modelPath  = ModelManager.instance.onnxModelPath;
    final labelsPath = ModelManager.instance.onnxLabelsPath;
    try {
      if (modelPath  != null) await ModelDownloadService.instance.deleteModel(modelPath);
      if (labelsPath != null) await ModelDownloadService.instance.deleteModel(labelsPath);
      if (!mounted) return;
      setState(() { _visionReady = false; _visionError = null; });
      _showSnack('Vision model removed.');
    } catch (e) {
      _showSnack('Delete failed: $e', success: false);
    }
  }

  void _showSnack(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Models'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh status',
            onPressed: _refresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            _InfoBanner(textTheme: textTheme),
            const SizedBox(height: 20),

            // Chat model card
            _ModelCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat Model',
              subtitle: 'Qwen 2.5 · 0.5 B · Q4_K_M',
              source: 'Qwen/Qwen2.5-0.5B-Instruct-GGUF (Hugging Face)',
              description:
                  'Offline chat assistant. Answers store questions, analyses '
                  'revenue and inventory, and helps with customer queries '
                  '— no internet required after download.',
              sizeLabel: '≈ 397 MB',
              isReady: _chatReady,
              progress: _chatProgress,
              error: _chatError,
              onDownload: _chatProgress != null ? null : _downloadChat,
              onDelete: (_chatReady && _chatProgress == null) ? _deleteChat : null,
            ),
            const SizedBox(height: 16),

            // Vision model card
            _ModelCard(
              icon: Icons.image_search_rounded,
              title: 'Vision Model',
              subtitle: 'MobileNetV2 · ONNX opset 12',
              source: 'ONNX Model Zoo · mobilenetv2-12',
              description:
                  'Image recognition for the product scanner. Identifies '
                  'products from photos and pre-fills the product form. '
                  'Falls back to manual entry when confidence is too low.',
              sizeLabel: '≈ 14 MB',
              isReady: _visionReady,
              progress: _visionProgress,
              error: _visionError,
              onDownload: _visionProgress != null ? null : _downloadVision,
              onDelete: (_visionReady && _visionProgress == null) ? _deleteVision : null,
            ),
            const SizedBox(height: 24),

            // Fallback notice
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'The app always works — the rule-based assistant and '
                      'manual product entry are always available even without '
                      'any downloaded models.',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.textTheme});
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.offline_bolt_rounded,
              size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Models are downloaded once and stored on-device. '
              'After setup the AI works fully offline — no internet '
              'connection is needed.',
              style: textTheme.bodySmall
                  ?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.source,
    required this.description,
    required this.sizeLabel,
    required this.isReady,
    required this.progress,
    required this.error,
    required this.onDownload,
    required this.onDelete,
  });

  final IconData icon;
  final String   title;
  final String   subtitle;
  final String   source;
  final String   description;
  final String   sizeLabel;
  final bool     isReady;
  final double?  progress;   // null=idle, 0–1=downloading
  final String?  error;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDownloading = progress != null;
    final statusColor  = isReady
        ? AppColors.success
        : (error != null ? AppColors.error : AppColors.warning);
    final statusLabel  = isReady
        ? 'Downloaded'
        : (isDownloading ? 'Downloading…' : 'Not downloaded');

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(icon, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: textTheme.labelSmall),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  statusLabel,
                  style: textTheme.labelSmall?.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Source + description
          Text(description, style: textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            'Source: $source · $sizeLabel',
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 11,
            ),
          ),

          // Progress bar (while downloading)
          if (isDownloading) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress! > 0 ? progress : null,
              backgroundColor:
                  AppColors.primary.withValues(alpha: 0.12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text(
              progress! > 0
                  ? '${(progress! * 100).toStringAsFixed(0)}%'
                  : 'Connecting…',
              style:
                  textTheme.labelSmall?.copyWith(color: AppColors.primary),
            ),
          ],

          // Error message
          if (error != null && !isDownloading) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(error!,
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.error)),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons
          const SizedBox(height: 14),
          Row(
            children: [
              if (!isReady && !isDownloading)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(error != null ? 'Retry' : 'Download'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              if (isDownloading)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    label: const Text('Downloading…'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              if (isReady) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check_circle_rounded,
                        size: 18, color: AppColors.success),
                    label: const Text('Ready',
                        style: TextStyle(color: AppColors.success)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.success),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, size: 18),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
