import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/repositories/customer_repository.dart';
import '../../../shared/repositories/repository_exceptions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _repository = CustomerRepository();

  late final Stream<List<UserModel>> _customersStream;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _customersStream = _repository.watchCustomers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ));
  }

  Future<void> _deleteCustomer(UserModel customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr.deleteCustomer),
        content: Text('${context.tr.deleteCustomer} ${customer.fullName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.tr.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.tr.delete)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.deleteCustomer(customer.id);
      _showMessage(context.tr.customerRemoved);
    } on RepositoryException catch (e) {
      _showMessage(e.message, isError: true);
    }
  }

  void _showEditCustomer(UserModel customer) {
    final nameCtrl = TextEditingController(text: customer.fullName);
    final phoneCtrl = TextEditingController(text: customer.phone);
    final emailCtrl = TextEditingController(text: customer.email);
    final addressCtrl = TextEditingController(text: '');
    final noteCtrl = TextEditingController(text: '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr.editCustomer,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                CustomTextField(
                    label: context.tr.fullName,
                    controller: nameCtrl,
                    validator: (v) =>
                        (v?.trim().isEmpty ?? true) ? context.tr.required : null),
                const SizedBox(height: 12),
                CustomTextField(
                    label: context.tr.phoneOptional,
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                CustomTextField(
                    label: context.tr.emailOptional,
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                CustomTextField(
                    label: context.tr.addressOptional,
                    controller: addressCtrl,
                    maxLines: 2),
                const SizedBox(height: 20),
                CustomButton(
                    label: context.tr.saveChanges,
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      try {
                        await _repository.updateCustomer(
                          id: customer.id,
                          fullName: nameCtrl.text,
                          phone: phoneCtrl.text.trim().isEmpty
                              ? null
                              : phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim().isEmpty
                              ? null
                              : emailCtrl.text.trim(),
                          address: addressCtrl.text.trim().isEmpty
                              ? null
                              : addressCtrl.text.trim(),
                          note: noteCtrl.text.trim().isEmpty
                              ? null
                              : noteCtrl.text.trim(),
                        );
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        _showMessage(context.tr.customerUpdated);
                      } on RepositoryException catch (e) {
                        if (!mounted) return;
                        _showMessage(e.message, isError: true);
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCustomer() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr.addCustomer,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                CustomTextField(
                    label: context.tr.fullName,
                    controller: nameCtrl,
                    validator: (v) =>
                        (v?.trim().isEmpty ?? true) ? context.tr.required : null),
                const SizedBox(height: 12),
                CustomTextField(
                    label: context.tr.phoneOptional,
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                CustomTextField(
                    label: context.tr.emailOptional,
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                CustomTextField(
                    label: context.tr.addressOptional,
                    controller: addressCtrl,
                    maxLines: 2),
                const SizedBox(height: 20),
                CustomButton(
                    label: context.tr.addCustomer,
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      try {
                        await _repository.createCustomer(
                          fullName: nameCtrl.text,
                          phone: phoneCtrl.text.trim().isEmpty
                              ? null
                              : phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim().isEmpty
                              ? null
                              : emailCtrl.text.trim(),
                          address: addressCtrl.text.trim().isEmpty
                              ? null
                              : addressCtrl.text.trim(),
                        );
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        _showMessage(context.tr.customerAdded);
                      } on RepositoryException catch (e) {
                        if (!mounted) return;
                        _showMessage(e.message, isError: true);
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.customers),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMD),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: context.tr.searchCustomers,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _customersStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '${context.tr.errorLoadingCustomers}: ${snapshot.error}',
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final customers = snapshot.data!;
                final filtered = customers.where((customer) {
                  if (_query.isEmpty) return true;
                  final q = _query.toLowerCase();
                  return customer.fullName.toLowerCase().contains(q) ||
                      customer.phone.toLowerCase().contains(q) ||
                      customer.email.toLowerCase().contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.person_outline_rounded,
                    title: context.tr.noCustomersFound,
                    subtitle: _query.isEmpty
                        ? context.tr.addFirstCustomer
                        : context.tr.tryDifferentSearch,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _CustomerRow(
                    customer: filtered[i],
                    onEdit: _showEditCustomer,
                    onDelete: _deleteCustomer,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomer,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label:
            Text(context.tr.addCustomer, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow(
      {required this.customer, required this.onEdit, required this.onDelete});
  final UserModel customer;
  final ValueChanged<UserModel> onEdit;
  final ValueChanged<UserModel> onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            child: Text(
              customer.initials,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.fullName, style: textTheme.titleSmall),
                if (customer.phone.isNotEmpty)
                  Text(customer.phone, style: textTheme.bodySmall),
                if (customer.email.isNotEmpty)
                  Text(customer.email,
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconBtn(
                  icon: Icons.edit_outlined, onTap: () => onEdit(customer)),
              const SizedBox(height: 4),
              _IconBtn(
                  icon: Icons.delete_outline_rounded,
                  onTap: () => onDelete(customer),
                  color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color ?? AppColors.primary),
      ),
    );
  }
}
