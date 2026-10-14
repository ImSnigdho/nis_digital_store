import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/payment_method.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/payment_method_service.dart';
import '../../services/promo_code_service.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/app_network_image.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _paymentRefController = TextEditingController();
  final _promoCodeController = TextEditingController();

  List<PaymentMethod> _paymentMethods = [];
  bool _isLoadingMethods = true;
  String? _paymentMethodId;
  
  PromoValidationResult? _promoResult;
  bool _isValidatingPromo = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController.text = auth.profile?.fullName ?? '';
    _phoneController.text = auth.profile?.phone ?? '';

    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await PaymentMethodService().getActivePaymentMethods();
      if (mounted) {
        setState(() {
          _paymentMethods = methods;
          if (methods.isNotEmpty) {
            _paymentMethodId = methods.first.id;
          }
          _isLoadingMethods = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMethods = false);
      }
    }
  }

  Future<void> _applyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isValidatingPromo = true);

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    
    final result = await PromoCodeService().validatePromoCode(
      code,
      auth.currency,
      cart.totalPrice(auth.currency),
    );

    setState(() {
      _promoResult = result;
      _isValidatingPromo = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _paymentRefController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    final selectedMethod = _paymentMethods
        .where((m) => m.id == _paymentMethodId)
        .firstOrNull;

    final order = await orderProvider.placeOrder(
      cartItems: cart.items,
      currency: auth.currency,
      paymentMethodId: _paymentMethodId!,
      paymentRef: _paymentRefController.text.trim(),
      promoCodeId: _promoResult?.valid == true ? _promoResult!.promoId : null,
      discountAmount: _promoResult?.valid == true ? _promoResult!.discountAmount : 0,
      paymentMethodName: selectedMethod?.name,
      shippingAddress: {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      },
    );

    if (order != null && mounted) {
      // Clear cart and navigate back
      await cart.loadCart();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.of(context).surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle,
                      color: AppColors.of(context).success, size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  'Order Placed!',
                  style: TextStyle(
                    color: AppColors.of(context).textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order has been placed successfully and is pending verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.of(context).textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.of(context).primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Continue Shopping'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else if (mounted && orderProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error!),
          backgroundColor: AppColors.of(context).error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.of(context).textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: AppColors.of(context).textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Order Summary
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 12),
            ...cart.items.map((item) {
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.of(context).glassBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.of(context).glassBorder, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product?.name ?? 'Product'} x${item.quantity}',
                        style: TextStyle(
                          color: AppColors.of(context).textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(
                          item.totalPrice(auth.currency), auth.currency),
                      style: TextStyle(
                        color: AppColors.of(context).primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (_promoResult?.valid == true)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.of(context).success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.of(context).success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Promo Discount (${_promoCodeController.text})',
                      style: TextStyle(
                        color: AppColors.of(context).success,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '-${CurrencyFormatter.format(_promoResult!.discountAmount, auth.currency)}',
                      style: TextStyle(
                        color: AppColors.of(context).success,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.of(context).primary.withValues(alpha: 0.1),
                    AppColors.of(context).accent.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: AppColors.of(context).textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(
                        cart.totalPrice(auth.currency) - (_promoResult?.valid == true ? _promoResult!.discountAmount : 0),
                        auth.currency),
                    style: TextStyle(
                      color: AppColors.of(context).primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Promo Code Field
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _promoCodeController,
                    label: 'Promo Code',
                    icon: Icons.local_offer_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isValidatingPromo ? null : _applyPromoCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.of(context).surface,
                      foregroundColor: AppColors.of(context).primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.of(context).primary),
                      ),
                    ),
                    child: _isValidatingPromo 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Apply'),
                  ),
                ),
              ],
            ),
            if (_promoResult != null && !_promoResult!.valid)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  _promoResult!.reason ?? 'Invalid promo code',
                  style: TextStyle(color: AppColors.of(context).error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 28),

            // Shipping Info
            _buildSectionTitle('Shipping Information'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number (11 digits)',
              hintText: '01XXXXXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Phone number is required';
                final clean = v.replaceAll(RegExp(r'\D'), '');
                if (clean.length != 11) {
                  return 'Phone number must be exactly 11 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address (For Delivery)',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(v)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
              child: Text(
                '⚠️ Please enter your correct email carefully. Your digital product will be delivered here.',
                style: TextStyle(
                  color: AppColors.of(context).error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Payment Method
            _buildSectionTitle('Payment Method'),
            const SizedBox(height: 12),
            if (_isLoadingMethods)
              const Center(child: CircularProgressIndicator())
            else if (_paymentMethods.isEmpty)
              Text(
                'No payment methods available',
                style: TextStyle(color: AppColors.of(context).error),
              )
            else
              ..._paymentMethods.map((method) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildPaymentOption(
                    method.id, 
                    method.name, 
                    'Send to: ${method.accountNumber}',
                    iconUrl: method.iconUrl,
                  ),
                );
              }),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _paymentRefController,
              label: 'Transaction ID / Reference (10 digits)',
              hintText: '10-digit Trx ID',
              icon: Icons.receipt_long_outlined,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Payment reference is required';
                final clean = v.trim();
                if (clean.length != 10) {
                  return 'Transaction ID must be exactly 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Place Order Button
            Consumer<OrderProvider>(
              builder: (context, orderProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                        orderProvider.isLoading ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.of(context).primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: orderProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Place Order — ${CurrencyFormatter.format(cart.totalPrice(auth.currency) - (_promoResult?.valid == true ? _promoResult!.discountAmount : 0), auth.currency)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.of(context).textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.of(context).textColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(
            color: AppColors.of(context).textSecondary.withValues(alpha: 0.6)),
        labelStyle: TextStyle(color: AppColors.of(context).textSecondary),
        prefixIcon: Icon(icon, color: AppColors.of(context).textSecondary),
      ),
      validator: validator,
    );
  }

  Widget _buildPaymentOption(
      String methodId, String title, String subtitle, {String? iconUrl}) {
    final isSelected = _paymentMethodId == methodId;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethodId = methodId),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.of(context).primary.withValues(alpha: 0.1)
              : AppColors.of(context).glassBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.of(context).primary : AppColors.of(context).glassBorder,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.of(context).primary
                      : AppColors.of(context).textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.of(context).primary,
                        ),
                      ),
                    )
                  : null,
            ),
            if (iconUrl != null && iconUrl.isNotEmpty) ...[
              const SizedBox(width: 12),
              AppNetworkImage(
                imageUrl: iconUrl,
                width: 32,
                height: 32,
                memCacheWidth: 64,
                memCacheHeight: 64,
                errorWidget: const Icon(Icons.payment),
              ),
            ] else ...[
              const SizedBox(width: 12),
              const Icon(Icons.payment),
            ],
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.of(context).primary
                          : AppColors.of(context).textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 12,
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

