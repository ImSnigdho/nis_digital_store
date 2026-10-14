import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/promo_code.dart';
import '../../services/promo_code_service.dart';

class AdminPromoCodesScreen extends StatefulWidget {
  const AdminPromoCodesScreen({super.key});

  @override
  State<AdminPromoCodesScreen> createState() => _AdminPromoCodesScreenState();
}

class _AdminPromoCodesScreenState extends State<AdminPromoCodesScreen> {
  final PromoCodeService _service = PromoCodeService();
  List<PromoCode> _promoCodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final codes = await _service.getAllPromoCodes();
      setState(() => _promoCodes = codes);
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.of(context).error),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.of(context).success),
    );
  }

  void _openDialog({PromoCode? promo}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PromoCodeDialog(
        promo: promo,
        service: _service,
        onSaved: () {
          _fetch();
          _showSuccess(promo == null ? 'Promo code created!' : 'Promo code updated!');
        },
        onError: _showError,
      ),
    );
  }

  Future<void> _delete(PromoCode promo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(context).surface,
        title: Text('Delete "${promo.code}"?',
            style: TextStyle(color: AppColors.of(context).textColor)),
        content: Text('This cannot be undone.',
            style: TextStyle(color: AppColors.of(context).textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.of(context).error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _service.deletePromoCode(promo.id);
        _fetch();
        _showSuccess('Deleted "${promo.code}"');
      } catch (e) {
        _showError('Delete failed: $e');
      }
    }
  }

  String _discountLabel(PromoCode p) {
    if (p.discountType == 'percentage') {
      return '${p.percentageValue?.toStringAsFixed(0) ?? '?'}% OFF';
    } else {
      return '${p.fixedAmount?.toStringAsFixed(0) ?? '?'} ${p.fixedCurrency ?? ''} OFF';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Promo Codes',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('CREATE PROMO'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _promoCodes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_offer_outlined,
                                size: 64,
                                color: AppColors.of(context).textSecondary),
                            const SizedBox(height: 16),
                            Text('No promo codes yet.',
                                style: TextStyle(
                                    color: AppColors.of(context).textSecondary,
                                    fontSize: 16)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _openDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Create First Promo Code'),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 620;

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            itemCount: _promoCodes.length,
                            itemBuilder: (context, index) {
                              final promo = _promoCodes[index];

                              if (isMobile) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: GlassDecoration(context: context),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Text(
                                                  promo.code,
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.of(context)
                                                              .primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      letterSpacing: 1),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.of(context)
                                                        .success
                                                        .withValues(alpha: 0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    _discountLabel(promo),
                                                    style: TextStyle(
                                                        color: AppColors.of(
                                                                context)
                                                            .success,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Switch(
                                            value: promo.isActive,
                                            activeThumbColor:
                                                AppColors.of(context).primary,
                                            onChanged: (val) async {
                                              try {
                                                await _service.toggleActive(
                                                    promo.id, val);
                                                _fetch();
                                              } catch (e) {
                                                _showError(
                                                    'Toggle failed: $e');
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Wrap(
                                              spacing: 12,
                                              runSpacing: 4,
                                              children: [
                                                Text(
                                                  'Used: ${promo.timesUsed}/${promo.usageLimit ?? '∞'}',
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.of(context)
                                                              .textColor,
                                                      fontSize: 12),
                                                ),
                                                if (promo.minOrderAmount > 0)
                                                  Text(
                                                    'Min: ${promo.minOrderAmount.toStringAsFixed(0)}',
                                                    style: TextStyle(
                                                        color: AppColors.of(
                                                                context)
                                                            .textSecondary,
                                                        fontSize: 12),
                                                  ),
                                                if (promo.expiresAt != null)
                                                  Text(
                                                    'Expires ${DateFormat('MMM d, yyyy').format(promo.expiresAt!)}',
                                                    style: TextStyle(
                                                        color: promo.expiresAt!
                                                                .isBefore(
                                                                    DateTime
                                                                        .now())
                                                            ? AppColors.of(
                                                                    context)
                                                                .error
                                                            : AppColors.of(
                                                                    context)
                                                                .textSecondary,
                                                        fontSize: 12),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit,
                                                    color: AppColors.of(context)
                                                        .primary,
                                                    size: 20),
                                                onPressed: () =>
                                                    _openDialog(promo: promo),
                                                padding:
                                                    const EdgeInsets.all(4),
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: AppColors.of(context)
                                                        .error,
                                                    size: 20),
                                                onPressed: () => _delete(promo),
                                                padding:
                                                    const EdgeInsets.all(4),
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: GlassDecoration(context: context),
                                child: Row(
                                  children: [
                                    // Code
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            promo.code,
                                            style: TextStyle(
                                                color: AppColors.of(context)
                                                    .primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                letterSpacing: 1),
                                          ),
                                          if (promo.expiresAt != null)
                                            Text(
                                              'Expires ${DateFormat('MMM d, yyyy').format(promo.expiresAt!)}',
                                              style: TextStyle(
                                                  color: promo.expiresAt!
                                                          .isBefore(
                                                              DateTime.now())
                                                      ? AppColors.of(context)
                                                          .error
                                                      : AppColors.of(context)
                                                          .textSecondary,
                                                  fontSize: 11),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Discount
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        _discountLabel(promo),
                                        style: TextStyle(
                                            color:
                                                AppColors.of(context).success,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                    ),
                                    // Usage
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Used: ${promo.timesUsed}/${promo.usageLimit ?? '∞'}',
                                            style: TextStyle(
                                                color: AppColors.of(context)
                                                    .textColor,
                                                fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (promo.minOrderAmount > 0)
                                            Text(
                                              'Min order: ${promo.minOrderAmount.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                  color: AppColors.of(context)
                                                      .textSecondary,
                                                  fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Actions
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Switch(
                                          value: promo.isActive,
                                          activeThumbColor:
                                              AppColors.of(context).primary,
                                          onChanged: (val) async {
                                            try {
                                              await _service.toggleActive(
                                                  promo.id, val);
                                              _fetch();
                                            } catch (e) {
                                              _showError('Toggle failed: $e');
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color:
                                                  AppColors.of(context).primary,
                                              size: 20),
                                          onPressed: () =>
                                              _openDialog(promo: promo),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color:
                                                  AppColors.of(context).error,
                                              size: 20),
                                          onPressed: () => _delete(promo),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ──── Add/Edit Dialog ────

class _PromoCodeDialog extends StatefulWidget {
  final PromoCode? promo;
  final PromoCodeService service;
  final VoidCallback onSaved;
  final void Function(String) onError;

  const _PromoCodeDialog({
    this.promo,
    required this.service,
    required this.onSaved,
    required this.onError,
  });

  @override
  State<_PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<_PromoCodeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeCtrl;
  late TextEditingController _percentCtrl;
  late TextEditingController _fixedAmountCtrl;
  late TextEditingController _minOrderCtrl;
  late TextEditingController _usageLimitCtrl;

  String _discountType = 'percentage';
  String _fixedCurrency = 'BDT';
  bool _isActive = true;
  DateTime? _expiresAt;
  bool _isSaving = false;

  bool get isEdit => widget.promo != null;

  @override
  void initState() {
    super.initState();
    final p = widget.promo;
    _codeCtrl = TextEditingController(text: p?.code ?? '');
    _percentCtrl = TextEditingController(
        text: p?.percentageValue?.toStringAsFixed(0) ?? '');
    _fixedAmountCtrl =
        TextEditingController(text: p?.fixedAmount?.toStringAsFixed(0) ?? '');
    _minOrderCtrl = TextEditingController(
        text: p != null && p.minOrderAmount > 0
            ? p.minOrderAmount.toStringAsFixed(0)
            : '');
    _usageLimitCtrl =
        TextEditingController(text: p?.usageLimit?.toString() ?? '');
    _discountType = p?.discountType ?? 'percentage';
    _fixedCurrency = p?.fixedCurrency ?? 'BDT';
    _isActive = p?.isActive ?? true;
    _expiresAt = p?.expiresAt;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _percentCtrl.dispose();
    _fixedAmountCtrl.dispose();
    _minOrderCtrl.dispose();
    _usageLimitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      if (isEdit) {
        await widget.service.updatePromoCode(
          id: widget.promo!.id,
          code: _codeCtrl.text,
          discountType: _discountType,
          percentageValue: _discountType == 'percentage'
              ? double.tryParse(_percentCtrl.text)
              : null,
          fixedAmount: _discountType == 'fixed'
              ? double.tryParse(_fixedAmountCtrl.text)
              : null,
          fixedCurrency: _discountType == 'fixed' ? _fixedCurrency : null,
          minOrderAmount: double.tryParse(_minOrderCtrl.text) ?? 0,
          usageLimit: _usageLimitCtrl.text.isNotEmpty
              ? int.tryParse(_usageLimitCtrl.text)
              : null,
          expiresAt: _expiresAt,
          isActive: _isActive,
        );
      } else {
        await widget.service.createPromoCode(
          code: _codeCtrl.text,
          discountType: _discountType,
          percentageValue: _discountType == 'percentage'
              ? double.tryParse(_percentCtrl.text)
              : null,
          fixedAmount: _discountType == 'fixed'
              ? double.tryParse(_fixedAmountCtrl.text)
              : null,
          fixedCurrency: _discountType == 'fixed' ? _fixedCurrency : null,
          minOrderAmount: double.tryParse(_minOrderCtrl.text) ?? 0,
          usageLimit: _usageLimitCtrl.text.isNotEmpty
              ? int.tryParse(_usageLimitCtrl.text)
              : null,
          expiresAt: _expiresAt,
          isActive: _isActive,
        );
      }
      if (mounted) Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      setState(() => _isSaving = false);
      widget.onError('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.of(context).surface,
      title: Text(
        isEdit ? 'Edit Promo Code' : 'Create Promo Code',
        style: TextStyle(color: AppColors.of(context).textColor),
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  'Promo Code *',
                  _codeCtrl,
                  hint: 'e.g. SAVE20',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Discount Type
                Text('Discount Type',
                    style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _discountType,
                  onChanged: (v) => setState(() => _discountType = v!),
                  style: TextStyle(color: AppColors.of(context).textColor),
                  dropdownColor: AppColors.of(context).surface,
                  decoration: _inputDeco(context),
                  items: const [
                    DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
                    DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount')),
                  ],
                ),
                const SizedBox(height: 12),

                if (_discountType == 'percentage')
                  _buildField('Discount % *', _percentCtrl,
                      hint: 'e.g. 20',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),

                if (_discountType == 'fixed') ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildField('Amount *', _fixedAmountCtrl,
                            hint: 'e.g. 100',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Currency',
                                style: TextStyle(
                                    color: AppColors.of(context).textSecondary,
                                    fontSize: 13)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _fixedCurrency,
                              onChanged: (v) =>
                                  setState(() => _fixedCurrency = v!),
                              style: TextStyle(
                                  color: AppColors.of(context).textColor),
                              dropdownColor: AppColors.of(context).surface,
                              decoration: _inputDeco(context),
                              items: const [
                                DropdownMenuItem(value: 'BDT', child: Text('BDT (৳)')),
                                DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildField('Min Order Amount', _minOrderCtrl,
                          hint: '0', keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField('Usage Limit', _usageLimitCtrl,
                          hint: 'Leave blank for unlimited',
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Expiry date
                Text('Expiry Date (optional)',
                    style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 13)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.of(context).glassBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16,
                            color: AppColors.of(context).textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          _expiresAt != null
                              ? DateFormat('MMM d, yyyy').format(_expiresAt!)
                              : 'No expiry',
                          style: TextStyle(
                              color: _expiresAt != null
                                  ? AppColors.of(context).textColor
                                  : AppColors.of(context).textSecondary),
                        ),
                        const Spacer(),
                        if (_expiresAt != null)
                          GestureDetector(
                            onTap: () => setState(() => _expiresAt = null),
                            child: Icon(Icons.clear,
                                size: 16,
                                color: AppColors.of(context).textSecondary),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Text('Active: ',
                        style: TextStyle(
                            color: AppColors.of(context).textSecondary)),
                    Switch(
                      value: _isActive,
                      activeThumbColor: AppColors.of(context).primary,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(color: AppColors.of(context).textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.of(context).primary,
              foregroundColor: Colors.white),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'Save Changes' : 'Create'),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: AppColors.of(context).textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          validator: validator,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.of(context).textColor),
          decoration: _inputDeco(context).copyWith(hintText: hint),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(BuildContext context) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.of(context).background,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.of(context).glassBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.of(context).glassBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColors.of(context).primary, width: 1.5)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
