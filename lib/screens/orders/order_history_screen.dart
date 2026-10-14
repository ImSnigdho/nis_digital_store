import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.of(context).textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Order History',
          style: TextStyle(
            color: AppColors.of(context).textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.of(context).primary),
            );
          }

          if (orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      color: AppColors.of(context).textSecondary.withValues(alpha: 0.5),
                      size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      color: AppColors.of(context).textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your order history will appear here',
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return _buildOrderCard(context, order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final auth = context.read<AuthProvider>();
    final currency = auth.currency;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.of(context).glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).glassBorder, width: 0.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(
                        color: AppColors.of(context).textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.createdAt != null
                          ? DateFormat('MMM dd, yyyy — hh:mm a')
                              .format(order.createdAt!.toLocal())
                          : 'Unknown date',
                      style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(order.status),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(
                        order.getTotal(currency), currency),
                    style: TextStyle(
                      color: AppColors.of(context).primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          iconColor: AppColors.of(context).textSecondary,
          collapsedIconColor: AppColors.of(context).textSecondary,
          children: [
            Divider(color: AppColors.of(context).glassBorder),
            const SizedBox(height: 8),
            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.productName} x${item.quantity}',
                        style: TextStyle(
                          color: AppColors.of(context).textColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(
                          item.getPrice(currency) * item.quantity, currency),
                      style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (order.paymentMethod != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.payment,
                      color: AppColors.of(context).textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Paid via ${order.paymentMethod}',
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        color = AppColors.of(context).success;
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = AppColors.of(context).warning;
        icon = Icons.schedule;
        break;
      case 'refunded':
        color = Colors.blueGrey;
        icon = Icons.replay;
        break;
      case 'cancelled':
        color = AppColors.of(context).error;
        icon = Icons.cancel_outlined;
        break;
      case 'confirmed':
        color = AppColors.of(context).primary;
        icon = Icons.check_circle_outline;
        break;
      case 'shipped':
        color = AppColors.of(context).accent;
        icon = Icons.local_shipping_outlined;
        break;
      default:
        color = AppColors.of(context).textSecondary;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

