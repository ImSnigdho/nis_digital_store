import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/payment_method.dart';
import '../../services/payment_method_service.dart';
import '../../widgets/app_network_image.dart';

class AdminPaymentMethodsScreen extends StatefulWidget {
  const AdminPaymentMethodsScreen({super.key});

  @override
  State<AdminPaymentMethodsScreen> createState() => _AdminPaymentMethodsScreenState();
}

class _AdminPaymentMethodsScreenState extends State<AdminPaymentMethodsScreen> {
  final PaymentMethodService _service = PaymentMethodService();
  List<PaymentMethod> _methods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMethods();
  }

  Future<void> _fetchMethods() async {
    setState(() => _isLoading = true);
    try {
      final methods = await _service.getAllPaymentMethods();
      setState(() => _methods = methods);
    } catch (e) {
      if (mounted) _showError('Failed to load: $e');
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

  void _openDialog({PaymentMethod? method}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentMethodDialog(
        method: method,
        service: _service,
        onSaved: () {
          _fetchMethods();
          _showSuccess(method == null ? 'Payment method added!' : 'Payment method updated!');
        },
        onError: _showError,
      ),
    );
  }

  Future<void> _delete(PaymentMethod method) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(context).surface,
        title: Text('Delete "${method.name}"?',
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
        await _service.deletePaymentMethod(method.id);
        _fetchMethods();
        _showSuccess('Deleted "${method.name}"');
      } catch (e) {
        _showError('Delete failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.of(context).primary),
            tooltip: 'Add Payment Method',
            onPressed: () => _openDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _methods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment_outlined,
                          size: 64,
                          color: AppColors.of(context).textSecondary),
                      const SizedBox(height: 16),
                      Text('No payment methods yet.',
                          style: TextStyle(
                              color: AppColors.of(context).textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _openDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Payment Method'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _methods.length,
                  itemBuilder: (context, index) {
                    final method = _methods[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: GlassDecoration(context: context),
                      child: Row(
                        children: [
                          // Icon
                          method.iconUrl != null &&
                                  method.iconUrl!.isNotEmpty
                              ? AppNetworkImage(
                                  imageUrl: method.iconUrl!,
                                  width: 48,
                                  height: 48,
                                  memCacheWidth: 100,
                                  memCacheHeight: 100,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(8),
                                  errorWidget: _iconPlaceholder(context),
                                )
                              : _iconPlaceholder(context),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(method.name,
                                    style: TextStyle(
                                        color: AppColors.of(context).textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text('Account: ${method.accountNumber}',
                                    style: TextStyle(
                                        color: AppColors.of(context).textSecondary,
                                        fontSize: 13)),
                                if (method.instructions != null &&
                                    method.instructions!.isNotEmpty)
                                  Text(
                                    method.instructions!,
                                    style: TextStyle(
                                        color: AppColors.of(context).textSecondary,
                                        fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          // Toggle
                          Switch(
                            value: method.isActive,
                            activeThumbColor: AppColors.of(context).primary,
                            onChanged: (val) async {
                              try {
                                await _service.toggleActive(method.id, val);
                                _fetchMethods();
                              } catch (e) {
                                _showError('Toggle failed: $e');
                              }
                            },
                          ),
                          // Edit
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: AppColors.of(context).primary, size: 20),
                            onPressed: () => _openDialog(method: method),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          // Delete
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: AppColors.of(context).error, size: 20),
                            onPressed: () => _delete(method),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _iconPlaceholder(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.of(context).surface,
      child: Icon(Icons.payment,
          size: 28, color: AppColors.of(context).textSecondary),
    );
  }
}

// ──── Dialog for Add/Edit ────

class _PaymentMethodDialog extends StatefulWidget {
  final PaymentMethod? method;
  final PaymentMethodService service;
  final VoidCallback onSaved;
  final void Function(String) onError;

  const _PaymentMethodDialog({
    this.method,
    required this.service,
    required this.onSaved,
    required this.onError,
  });

  @override
  State<_PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<_PaymentMethodDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _accountCtrl;
  late TextEditingController _instructionsCtrl;
  late bool _isActive;
  late int _sortOrder;

  String? _iconUrl;
  Uint8List? _iconBytes;
  String? _iconFileName;
  bool _isSaving = false;
  bool _isUploading = false;

  bool get isEdit => widget.method != null;

  @override
  void initState() {
    super.initState();
    final m = widget.method;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _accountCtrl = TextEditingController(text: m?.accountNumber ?? '');
    _instructionsCtrl = TextEditingController(text: m?.instructions ?? '');
    _isActive = m?.isActive ?? true;
    _sortOrder = m?.sortOrder ?? 0;
    _iconUrl = m?.iconUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _accountCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _iconBytes = result.files.single.bytes;
        _iconFileName = result.files.single.name;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      String? iconUrl = _iconUrl;
      if (_iconBytes != null && _iconFileName != null) {
        setState(() => _isUploading = true);
        iconUrl = await widget.service.uploadIcon(_iconFileName!, _iconBytes!);
        setState(() => _isUploading = false);
      }

      if (isEdit) {
        await widget.service.updatePaymentMethod(
          id: widget.method!.id,
          name: _nameCtrl.text.trim(),
          accountNumber: _accountCtrl.text.trim(),
          iconUrl: iconUrl,
          instructions: _instructionsCtrl.text.trim().isEmpty
              ? null
              : _instructionsCtrl.text.trim(),
          isActive: _isActive,
          sortOrder: _sortOrder,
        );
      } else {
        await widget.service.createPaymentMethod(
          name: _nameCtrl.text.trim(),
          accountNumber: _accountCtrl.text.trim(),
          iconUrl: iconUrl,
          instructions: _instructionsCtrl.text.trim().isEmpty
              ? null
              : _instructionsCtrl.text.trim(),
          isActive: _isActive,
          sortOrder: _sortOrder,
        );
      }

      if (mounted) Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      setState(() { _isSaving = false; _isUploading = false; });
      widget.onError('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.of(context).surface,
      title: Text(
        isEdit ? 'Edit Payment Method' : 'Add Payment Method',
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
                // Icon picker
                Text('Icon Image (optional)',
                    style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _iconBytes != null
                          ? Image.memory(_iconBytes!,
                              width: 56, height: 56, fit: BoxFit.cover)
                          : (_iconUrl != null && _iconUrl!.isNotEmpty
                              ? AppNetworkImage(
                                  imageUrl: _iconUrl!,
                                  width: 56,
                                  height: 56,
                                  memCacheWidth: 120,
                                  memCacheHeight: 120,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(8),
                                  errorWidget: _placeholder(context),
                                )
                              : _placeholder(context)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _pickIcon,
                      icon: const Icon(Icons.upload, size: 16),
                      label: const Text('Upload Icon'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.of(context).primary.withValues(alpha: 0.2),
                          foregroundColor: AppColors.of(context).primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField('Name *', _nameCtrl,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                _buildField('Account Number *', _accountCtrl,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                _buildField(
                    'Instructions (e.g. Send money to the account above, include TXID)',
                    _instructionsCtrl,
                    maxLines: 3),
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
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)),
                    const SizedBox(width: 8),
                    Text(_isUploading ? 'Uploading...' : 'Saving...'),
                  ],
                )
              : Text(isEdit ? 'Save Changes' : 'Add Method'),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {String? Function(String?)? validator, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: AppColors.of(context).textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: AppColors.of(context).textColor),
          decoration: InputDecoration(
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
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
          color: AppColors.of(context).glassBg,
          borderRadius: BorderRadius.circular(8)),
      child: Icon(Icons.payment,
          size: 28, color: AppColors.of(context).textSecondary),
    );
  }
}
