import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/repositories/branch_repository.dart';
import '../../../shared/repositories/repository_exceptions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/loading_overlay.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  final BranchRepository _repository = BranchRepository();
  List<BranchRecord> _branches = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final branches = await _repository.getBranches();
      setState(() => _branches = branches);
    } on RepositoryException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddBranch() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr.addBranch, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: context.tr.branchName, hintText: context.tr.branchNameHint)),
            const SizedBox(height: 12),
            TextField(controller: addressCtrl, decoration: InputDecoration(labelText: context.tr.address, hintText: context.tr.addressHint)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty) {
                  try {
                    await _repository.createBranch(name: nameCtrl.text.trim(), address: addressCtrl.text.trim());
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    await _loadBranches();
                  } on RepositoryException catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: AppColors.error));
                  }
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: Text(context.tr.addBranch),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr.branchManagement)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _branches.isEmpty
              ? EmptyState(
                  icon: Icons.store_outlined,
                  title: context.tr.noBranchesYet,
                  subtitle: context.tr.addFirstBranch,
                  action: ElevatedButton.icon(
                    onPressed: _showAddBranch,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(context.tr.addBranch),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppConstants.paddingMD),
                  itemCount: _branches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _BranchCard(
                    branch: _branches[i],
                    onToggle: () async {
                      try {
                        await _repository.toggleBranch(_branches[i].id);
                        await _loadBranches();
                      } on RepositoryException catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: AppColors.error));
                      }
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBranch,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(context.tr.addBranch, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch, required this.onToggle});
  final BranchRecord branch;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (branch.isActive ? AppColors.primary : AppColors.lightTextHint).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(
                  Icons.store_rounded,
                  color: branch.isActive ? AppColors.primary : AppColors.lightTextHint,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(branch.name, style: textTheme.titleMedium),
                    if (branch.address.isNotEmpty)
                      Text(branch.address, style: textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Switch(value: branch.isActive, onChanged: (_) => onToggle(), activeColor: AppColors.primary),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _BranchStat(label: context.tr.todaySales, value: context.tr.formatCurrency(branch.dailySales)),
              const SizedBox(width: 12),
              _BranchStat(label: context.tr.workers, value: '${branch.workerCount}'),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (branch.isActive ? AppColors.success : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  branch.isActive ? context.tr.active : context.tr.inactive,
                  style: textTheme.labelSmall?.copyWith(color: branch.isActive ? AppColors.success : AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BranchStat extends StatelessWidget {
  const _BranchStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}
