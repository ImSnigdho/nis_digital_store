import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../utils/currency_formatter.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Order order;
  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late String _currentStatus;
  String? _profileDiscord;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
    _fetchDiscordFromProfile();
  }

  Future<void> _fetchDiscordFromProfile() async {
    // If order already has discord username, nothing to fetch
    if (widget.order.discordUsername != null &&
        widget.order.discordUsername!.isNotEmpty) {
      return;
    }
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('discord_username')
          .eq('id', widget.order.userId)
          .maybeSingle();
      if (res != null && res['discord_username'] != null && mounted) {
        setState(() {
          _profileDiscord = res['discord_username'] as String?;
        });
      }
    } catch (_) {
      // Ignore if user profile has no discord or fails
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == _currentStatus || _isUpdating) return;

    final prevStatus = _currentStatus;
    setState(() {
      _currentStatus = newStatus;
      _isUpdating = true;
    });

    try {
      await context
          .read<OrderProvider>()
          .updateOrderStatus(widget.order.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Order status updated to ${newStatus.toUpperCase()} successfully'),
            backgroundColor: AppColors.of(context).success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentStatus = prevStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.of(context).error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if OrderProvider has updated order data
    final allOrders = context.watch<OrderProvider>().allOrders;
    final order = allOrders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    // Keep status in sync with provider if not currently updating
    if (!_isUpdating && order.status != _currentStatus) {
      _currentStatus = order.status;
    }

    final effectiveDiscord = (order.discordUsername?.isNotEmpty == true)
        ? order.discordUsername!
        : (_profileDiscord?.isNotEmpty == true ? _profileDiscord! : 'Not set');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status update section — responsive Wrap to avoid overflow
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: GlassDecoration(context: context),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Order #${order.id.length >= 8 ? order.id.substring(0, 8) : order.id}',
                        style: TextStyle(
                          color: AppColors.of(context).textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.createdAt != null
                            ? DateFormat('MMMM d, yyyy - h:mm a')
                                .format(order.createdAt!)
                            : 'N/A',
                        style: TextStyle(
                            color: AppColors.of(context).textSecondary),
                      ),
                    ],
                  ),
                  _buildStatusDropdown(context),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Details Grid
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoCard(
                        'Customer Information',
                        [
                          _DetailItem('Name', order.customerName ?? 'N/A'),
                          _DetailItem('Email', order.deliveryEmail ?? 'N/A'),
                          _DetailItem('Phone', order.customerPhone ?? 'N/A'),
                          _DetailItem('Reference / In-Game Name', order.reference ?? 'Not provided'),
                          _DetailItem('Discord', effectiveDiscord),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        'Payment Information',
                        [
                          _DetailItem('Method',
                              (order.paymentMethod ?? 'N/A').toUpperCase()),
                          _DetailItem('TXID', order.paymentRef ?? 'N/A'),
                          _DetailItem(
                              'Total Paid',
                              CurrencyFormatter.format(
                                  order.totalBdt, 'BDT')),
                        ],
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Customer Information',
                        [
                          _DetailItem('Name', order.customerName ?? 'N/A'),
                          _DetailItem('Email', order.deliveryEmail ?? 'N/A'),
                          _DetailItem('Phone', order.customerPhone ?? 'N/A'),
                          _DetailItem('Reference / In-Game Name', order.reference ?? 'Not provided'),
                          _DetailItem('Discord', effectiveDiscord),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildInfoCard(
                        'Payment Information',
                        [
                          _DetailItem('Method',
                              (order.paymentMethod ?? 'N/A').toUpperCase()),
                          _DetailItem('TXID', order.paymentRef ?? 'N/A'),
                          _DetailItem(
                              'Total Paid',
                              CurrencyFormatter.format(
                                  order.totalBdt, 'BDT')),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Order Items
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: GlassDecoration(context: context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Items (${order.items.length})',
                    style: TextStyle(
                      color: AppColors.of(context).primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  if (order.items.isEmpty)
                    Text('No items found in this order',
                        style: TextStyle(
                            color: AppColors.of(context).textSecondary))
                  else
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Text(
                                '${item.quantity}x',
                                style: TextStyle(
                                  color: AppColors.of(context).textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.productName,
                                  style: TextStyle(
                                    color: AppColors.of(context).textColor,
                                    fontSize: 15,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                CurrencyFormatter.format(
                                    item.priceBdt * item.quantity, 'BDT'),
                                style: TextStyle(
                                  color: AppColors.of(context).textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    Color color;
    switch (_currentStatus) {
      case 'completed':
        color = AppColors.of(context).success;
        break;
      case 'refunded':
        color = Colors.blueGrey;
        break;
      case 'cancelled':
        color = AppColors.of(context).error;
        break;
      default:
        color = AppColors.of(context).warning; // pending
    }

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _currentStatus,
          icon: _isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.arrow_drop_down, color: color),
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.bold),
          dropdownColor: AppColors.of(context).surface,
          onChanged: _isUpdating
              ? null
              : (newStatus) {
                  if (newStatus != null) _updateStatus(newStatus);
                },
          items:
              ['pending', 'completed', 'refunded', 'cancelled'].map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.toUpperCase()),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<_DetailItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GlassDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.of(context).primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 20),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        item.label,
                        style: TextStyle(
                            color: AppColors.of(context).textSecondary,
                            fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: TextStyle(
                          color: AppColors.of(context).textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  _DetailItem(this.label, this.value);
}
