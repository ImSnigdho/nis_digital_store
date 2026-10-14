import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/order_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../models/order.dart';
import 'admin_order_detail_screen.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.allOrders;

    final completedOrders =
        orders.where((o) => o.status == 'completed').toList();
    final pendingOrders = orders.where((o) => o.status == 'pending').toList();
    final totalRevenue =
        completedOrders.fold<double>(0, (sum, o) => sum + o.totalBdt);

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
                  'Orders Management',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => orderProvider.loadAllOrders(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('REFRESH'),
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

          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 500 ? 2 : 4;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: crossAxisCount == 2 ? 2.3 : 1.95,
                  children: [
                    _buildSummaryCard(context, 'TOTAL ORDERS',
                        '${orders.length}', AppColors.of(context).primary),
                    _buildSummaryCard(context, 'PENDING',
                        '${pendingOrders.length}', AppColors.of(context).warning),
                    _buildSummaryCard(context, 'COMPLETED',
                        '${completedOrders.length}', AppColors.of(context).success),
                    _buildSummaryCard(
                        context,
                        'REVENUE',
                        CurrencyFormatter.format(totalRevenue, 'BDT'),
                        AppColors.of(context).accent),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // List with LayoutBuilder for responsive mobile vs desktop
          Expanded(
            child: orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64,
                                color: AppColors.of(context).textSecondary),
                            const SizedBox(height: 16),
                            Text('No orders found.',
                                style: TextStyle(
                                    color:
                                        AppColors.of(context).textSecondary,
                                    fontSize: 16)),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 620;

                          if (isMobile) {
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return _buildMobileOrderCard(context, order);
                              },
                            );
                          }

                          return Column(
                            children: [
                              // Table Header (desktop only)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: GlassDecoration(context: context),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text('STATUS',
                                              style: _headerStyle(context))),
                                      Expanded(
                                          flex: 2,
                                          child: Text('DATE',
                                              style: _headerStyle(context))),
                                      Expanded(
                                          flex: 3,
                                          child: Text('CUSTOMER NAME',
                                              style: _headerStyle(context))),
                                      Expanded(
                                          flex: 3,
                                          child: Text('CUSTOMER EMAIL',
                                              style: _headerStyle(context))),
                                      const SizedBox(width: 40),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 4),
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    return _buildDesktopOrderRow(
                                        context, order);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle(BuildContext context) {
    return TextStyle(
      color: AppColors.of(context).primary,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileOrderCard(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: GlassDecoration(context: context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AdminOrderDetailScreen(order: order)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Status Badge + Date + View action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(context, order),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.createdAt != null
                              ? DateFormat('MMM d, yyyy')
                                  .format(order.createdAt!)
                              : 'N/A',
                          style: TextStyle(
                              color: AppColors.of(context).textSecondary,
                              fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.of(context).primary),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Middle row: Customer Name + Total
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.customerName ?? 'Anonymous Customer',
                        style: TextStyle(
                          color: AppColors.of(context).textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.format(order.totalBdt, 'BDT'),
                      style: TextStyle(
                        color: AppColors.of(context).primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (order.deliveryEmail != null &&
                    order.deliveryEmail!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    order.deliveryEmail!,
                    style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopOrderRow(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: GlassDecoration(context: context),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusBadge(context, order),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              order.createdAt != null
                  ? DateFormat('MMM d, yyyy').format(order.createdAt!)
                  : 'N/A',
              style: TextStyle(
                  color: AppColors.of(context).textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              order.customerName ?? 'N/A',
              style: TextStyle(
                  color: AppColors.of(context).textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              order.deliveryEmail ?? 'N/A',
              style: TextStyle(
                  color: AppColors.of(context).textSecondary, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(Icons.remove_red_eye_outlined,
                  color: AppColors.of(context).primary, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AdminOrderDetailScreen(order: order)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, Order order) {
    Color color;
    switch (order.status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        order.status.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
