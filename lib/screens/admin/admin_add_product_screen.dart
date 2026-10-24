import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../widgets/app_network_image.dart';

class AdminAddProductScreen extends StatefulWidget {
  final Product? product; // null = create mode, non-null = edit mode

  const AdminAddProductScreen({super.key, this.product});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _shortDescCtrl;
  late TextEditingController _fullDescCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _salePriceCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _referenceHintCtrl;

  String? _selectedCategoryId;
  String _status = 'active';
  bool _isFeatured = false;
  bool _referenceRequired = false;

  static const List<_HintTemplate> _hintTemplates = [
    _HintTemplate(
      'In-Game Name',
      'Enter your exact in-game name (case-sensitive). Example: CubeCraft_99. Your gift will be sent to this account.',
    ),
    _HintTemplate(
      'Player ID / UID',
      'Enter your numeric Player ID / UID (found in Profile > Settings). Example: 5839201746',
    ),
    _HintTemplate(
      'Username + Server',
      'Enter your username and server. Example: Steve123 | Asia Server',
    ),
  ];

  String? _thumbnailUrl;
  String? _fileUrl;
  String? _thumbnailFileName;
  String? _productFileName;
  Uint8List? _thumbnailBytes;
  Uint8List? _productFileBytes;

  bool _isUploading = false;
  bool _isSaving = false;

  bool get isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleCtrl = TextEditingController(text: p?.name ?? '');
    _shortDescCtrl = TextEditingController(text: p?.shortDescription ?? '');
    _fullDescCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p != null ? p.priceBdt.toStringAsFixed(2) : '');
    _salePriceCtrl = TextEditingController(text: p?.salePriceBdt?.toStringAsFixed(2) ?? '');
    _brandCtrl = TextEditingController(text: p?.brand ?? '');
    _stockCtrl = TextEditingController(text: p?.stock.toString() ?? '0');
    _selectedCategoryId = p?.categoryId;
    _status = p?.status ?? 'active';
    _isFeatured = p?.isFeatured ?? false;
    _referenceRequired = p?.referenceRequired ?? false;
    _referenceHintCtrl = TextEditingController(text: p?.referenceHint ?? '');
    _thumbnailUrl = p?.thumbnailUrl;
    _fileUrl = p?.fileUrl;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _shortDescCtrl.dispose();
    _fullDescCtrl.dispose();
    _priceCtrl.dispose();
    _salePriceCtrl.dispose();
    _brandCtrl.dispose();
    _stockCtrl.dispose();
    _referenceHintCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _thumbnailBytes = result.files.single.bytes;
        _thumbnailFileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickProductFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _productFileBytes = result.files.single.bytes;
        _productFileName = result.files.single.name;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<ProductProvider>();

      // Upload thumbnail if new one selected
      String? thumbUrl = _thumbnailUrl;
      if (_thumbnailBytes != null && _thumbnailFileName != null) {
        setState(() => _isUploading = true);
        thumbUrl = await provider.uploadThumbnail(_thumbnailFileName!, _thumbnailBytes!);
      }

      // Upload product file if new one selected
      String? prodFileUrl = _fileUrl;
      if (_productFileBytes != null && _productFileName != null) {
        setState(() => _isUploading = true);
        prodFileUrl = await provider.uploadProductFile(_productFileName!, _productFileBytes!);
      }

      setState(() => _isUploading = false);

      final price = double.tryParse(_priceCtrl.text) ?? 0;
      final salePrice = _salePriceCtrl.text.isNotEmpty ? double.tryParse(_salePriceCtrl.text) : null;

      if (isEditMode) {
        await provider.updateProductFull(
          id: widget.product!.id,
          name: _titleCtrl.text.trim(),
          shortDescription: _shortDescCtrl.text.trim(),
          description: _fullDescCtrl.text.trim(),
          priceBdt: price,
          priceUsd: price / 120, // Simple conversion
          salePriceBdt: salePrice,
          salePriceUsd: salePrice != null ? salePrice / 120 : null,
          categoryId: _selectedCategoryId,
          status: _status,
          isFeatured: _isFeatured,
          thumbnailUrl: thumbUrl,
          fileUrl: prodFileUrl,
          brand: _brandCtrl.text.trim().isNotEmpty ? _brandCtrl.text.trim() : null,
          stock: int.tryParse(_stockCtrl.text) ?? 0,
          referenceRequired: _referenceRequired,
          referenceHint: _referenceHintCtrl.text.trim().isNotEmpty ? _referenceHintCtrl.text.trim() : null,
        );
      } else {
        await provider.createProduct(
          name: _titleCtrl.text.trim(),
          shortDescription: _shortDescCtrl.text.trim(),
          description: _fullDescCtrl.text.trim(),
          priceBdt: price,
          priceUsd: price / 120,
          salePriceBdt: salePrice,
          salePriceUsd: salePrice != null ? salePrice / 120 : null,
          categoryId: _selectedCategoryId,
          status: _status,
          isFeatured: _isFeatured,
          thumbnailUrl: thumbUrl,
          fileUrl: prodFileUrl,
          brand: _brandCtrl.text.trim().isNotEmpty ? _brandCtrl.text.trim() : null,
          stock: int.tryParse(_stockCtrl.text) ?? 0,
          referenceRequired: _referenceRequired,
          referenceHint: _referenceHintCtrl.text.trim().isNotEmpty ? _referenceHintCtrl.text.trim() : null,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Product updated successfully!' : 'Product added successfully!'),
            backgroundColor: AppColors.of(context).success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.of(context).error),
        );
      }
    } finally {
      if (mounted) setState(() { _isSaving = false; _isUploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().categories;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Product' : 'Add New Product'),
        actions: [
          isMobile
              ? IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'BACK TO LIST',
                )
              : TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('BACK TO LIST'),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Success message area (shown after save)
            if (_isSaving)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.of(context).primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.of(context).primary)),
                    const SizedBox(width: 12),
                    Text(_isUploading ? 'Uploading files...' : 'Saving product...', style: TextStyle(color: AppColors.of(context).primary)),
                  ],
                ),
              ),

            // Product Information section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: GlassDecoration(context: context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Information',
                    style: TextStyle(color: AppColors.of(context).primary, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  // Row 1: Title + Category
                  if (isMobile) ...[
                    _buildTextField('Product Title *', _titleCtrl, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      'Category *',
                      categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
                      _selectedCategoryId,
                      (val) => setState(() => _selectedCategoryId = val),
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextField('Product Title *', _titleCtrl, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildDropdownField(
                            'Category *',
                            categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
                            _selectedCategoryId,
                            (val) => setState(() => _selectedCategoryId = val),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Row 2: Short Desc + Status
                  if (isMobile) ...[
                    _buildTextField('Short Description *', _shortDescCtrl, maxLines: 3, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      'Status',
                      ['draft', 'active', 'inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1), overflow: TextOverflow.ellipsis))).toList(),
                      _status,
                      (val) => setState(() => _status = val ?? 'active'),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: Colors.transparent,
                      child: CheckboxListTile(
                        value: _isFeatured,
                        onChanged: (v) => setState(() => _isFeatured = v ?? false),
                        title: Text('Featured Product', style: TextStyle(color: AppColors.of(context).textColor, fontSize: 14)),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextField('Short Description *', _shortDescCtrl, maxLines: 3, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildDropdownField(
                                'Status',
                                ['draft', 'active', 'inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1), overflow: TextOverflow.ellipsis))).toList(),
                                _status,
                                (val) => setState(() => _status = val ?? 'active'),
                              ),
                              const SizedBox(height: 12),
                              Material(
                                color: Colors.transparent,
                                child: CheckboxListTile(
                                  value: _isFeatured,
                                  onChanged: (v) => setState(() => _isFeatured = v ?? false),
                                  title: Text('Featured Product', style: TextStyle(color: AppColors.of(context).textColor, fontSize: 14)),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Full Description
                  _buildTextField('Full Description *', _fullDescCtrl, maxLines: 6, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 16),

                  // Row 3: Price + Sale Price + Brand + Stock
                  if (isMobile) ...[
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Price (৳) *', _priceCtrl, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Sale Price (৳)', _salePriceCtrl, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Brand', _brandCtrl)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Stock *', _stockCtrl, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Price (৳) *', _priceCtrl, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Sale Price (৳)', _salePriceCtrl, keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Brand', _brandCtrl)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Stock *', _stockCtrl, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Delivery reference section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: GlassDecoration(context: context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Reference',
                    style: TextStyle(color: AppColors.of(context).primary, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Info the buyer gives at checkout (e.g. in-game name) so you can deliver.',
                    style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      value: _referenceRequired,
                      onChanged: (v) => setState(() => _referenceRequired = v),
                      title: Text('Reference is mandatory', style: TextStyle(color: AppColors.of(context).textColor, fontSize: 14)),
                      subtitle: Text(
                        _referenceRequired ? 'Buyer must fill it to checkout' : 'Optional - buyer may skip it',
                        style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField('Hint message (shown to buyer when they tap the Reference field)', _referenceHintCtrl, maxLines: 3),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _hintTemplates
                        .map((t) => ActionChip(
                              label: Text(t.label, style: const TextStyle(fontSize: 12)),
                              onPressed: () => setState(() => _referenceHintCtrl.text = t.message),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // File uploads section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: GlassDecoration(context: context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Files & Media',
                    style: TextStyle(color: AppColors.of(context).primary, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  if (isMobile) ...[
                    _buildFilePickerField(
                      label: 'Featured Image',
                      fileName: _thumbnailFileName ?? (_thumbnailUrl != null ? 'Current image' : null),
                      onPick: _pickThumbnail,
                      hasFile: _thumbnailBytes != null || _thumbnailUrl != null,
                    ),
                    const SizedBox(height: 12),
                    _buildFilePickerField(
                      label: 'Product File',
                      fileName: _productFileName ?? (_fileUrl != null ? 'Current file' : null),
                      onPick: _pickProductFile,
                      hasFile: _productFileBytes != null || _fileUrl != null,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        // Featured Image
                        Expanded(
                          child: _buildFilePickerField(
                            label: 'Featured Image',
                            fileName: _thumbnailFileName ?? (_thumbnailUrl != null ? 'Current image' : null),
                            onPick: _pickThumbnail,
                            hasFile: _thumbnailBytes != null || _thumbnailUrl != null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Product File
                        Expanded(
                          child: _buildFilePickerField(
                            label: 'Product File',
                            fileName: _productFileName ?? (_fileUrl != null ? 'Current file' : null),
                            onPick: _pickProductFile,
                            hasFile: _productFileBytes != null || _fileUrl != null,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Preview thumbnail
                  if (_thumbnailBytes != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(_thumbnailBytes!, height: 120, fit: BoxFit.cover),
                    ),
                  ] else if (_thumbnailUrl != null && _thumbnailUrl!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    AppNetworkImage(
                      imageUrl: _thumbnailUrl!,
                      height: 120,
                      fit: BoxFit.cover,
                      memCacheWidth: 240,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save / Cancel buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    side: BorderSide(color: AppColors.of(context).textSecondary),
                  ),
                  child: Text('Cancel', style: TextStyle(color: AppColors.of(context).textSecondary)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(_isSaving ? 'Saving...' : (isEditMode ? 'Update Product' : 'Save Product')),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: AppColors.of(context).textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.of(context).surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.of(context).glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.of(context).glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.of(context).primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>(String label, List<DropdownMenuItem<T>> items, T? value, ValueChanged<T?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          isExpanded: true,
          initialValue: value,
          onChanged: onChanged,
          items: items,
          style: TextStyle(color: AppColors.of(context).textColor),
          dropdownColor: AppColors.of(context).surface,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.of(context).surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.of(context).glassBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.of(context).glassBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.of(context).primary)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerField({required String label, String? fileName, required VoidCallback onPick, bool hasFile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onPick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.of(context).surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: hasFile ? AppColors.of(context).success : AppColors.of(context).glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Choose file', style: TextStyle(color: AppColors.of(context).primary, fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName ?? 'No file chosen',
                    style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasFile) Icon(Icons.check_circle, color: AppColors.of(context).success, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HintTemplate {
  final String label;
  final String message;
  const _HintTemplate(this.label, this.message);
}
