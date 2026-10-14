import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/currency_formatter.dart';

import '../auth/login_screen.dart';
import 'admin_products_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_promo_codes_screen.dart';
import 'admin_customization_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardOverview(),
    const AdminProductsScreen(),
    const AdminCategoriesScreen(),
    const AdminOrdersScreen(),
    const AdminPromoCodesScreen(),
    const AdminCustomizationScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Products',
    'Categories',
    'Orders',
    'Promo Codes',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAllOrders();
      context.read<ProductProvider>().loadProducts();
      context.read<ProductProvider>().loadCategories();
    });
  }

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.of(context).primary),
              tooltip: 'Refresh',
              onPressed: _refreshData,
            ),
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.of(context).error),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Promos'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// ──── Dashboard Overview ────

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final productProvider = context.watch<ProductProvider>();

    final allOrders = orderProvider.allOrders;
    final completedOrders = allOrders.where((o) => o.status == 'completed').toList();
    final totalRevenue = completedOrders.fold<double>(0, (sum, o) => sum + o.totalBdt);
    final pendingOrders = allOrders.where((o) => o.status == 'pending').length;
    final totalProducts = productProvider.products.length;
    final totalOrders = allOrders.length;

    // Recent orders (last 5)
    final recentOrders = allOrders.take(5).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Welcome text
        Text(
          'Welcome, Admin',
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Summary cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildStatCard(context, 'TOTAL PRODUCTS', totalProducts.toString(),
                Icons.inventory_2, AppColors.of(context).primary),
            _buildStatCard(context, 'TOTAL REVENUE',
                CurrencyFormatter.format(totalRevenue, 'BDT'),
                Icons.currency_exchange, AppColors.of(context).success),
            _buildStatCard(context, 'TOTAL ORDERS', totalOrders.toString(),
                Icons.shopping_cart, AppColors.of(context).accent),
            _buildStatCard(context, 'PENDING ORDERS', pendingOrders.toString(),
                Icons.pending_actions, AppColors.of(context).warning),
          ],
        ),
        const SizedBox(height: 24),

        // Recent Orders
        Container(
          padding: const EdgeInsets.all(16),
          decoration: GlassDecoration(context: context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Orders',
                    style: TextStyle(
                      color: AppColors.of(context).primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Orders tab — find the parent state
                      final state = context.findAncestorStateOfType<_AdminDashboardScreenState>();
                      state?.switchTab(3);
                    },
                    child: Text('VIEW ALL', style: TextStyle(color: AppColors.of(context).primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentOrders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text('No orders yet', style: TextStyle(color: AppColors.of(context).textSecondary)),
                  ),
                )
              else
                ...recentOrders.map((order) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '#${order.id.substring(0, 8)}',
                          style: TextStyle(color: AppColors.of(context).textColor, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          order.customerName ?? 'N/A',
                          style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          CurrencyFormatter.format(order.totalBdt, 'BDT'),
                          style: TextStyle(color: AppColors.of(context).textColor, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildStatusPill(context, order.status),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 2,
                        child: Text(
                          order.createdAt != null ? DateFormat('MMM d').format(order.createdAt!) : '',
                          style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 11),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick Actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: GlassDecoration(context: context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.of(context).primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildQuickAction(context, '+ ADD PRODUCT', AppColors.of(context).primary, () {
                    final state = context.findAncestorStateOfType<_AdminDashboardScreenState>();
                    state?.switchTab(1);
                  }),
                  _buildQuickAction(context, '+ ADD CATEGORY', AppColors.of(context).success, () {
                    final state = context.findAncestorStateOfType<_AdminDashboardScreenState>();
                    state?.switchTab(2);
                  }),
                  _buildQuickAction(context, 'VIEW ORDERS', AppColors.of(context).accent, () {
                    final state = context.findAncestorStateOfType<_AdminDashboardScreenState>();
                    state?.switchTab(3);
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const Spacer(),
          Text(value, style: TextStyle(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          Align(alignment: Alignment.bottomRight, child: Icon(icon, color: color.withValues(alpha: 0.6), size: 28)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Widget _buildStatusPill(BuildContext context, String status) {
    Color color;
    switch (status) {
      case 'completed':
        color = AppColors.of(context).success;
        break;
      case 'refunded':
        color = Colors.blueGrey;
        break;
      case 'cancelled':
        color = AppColors.of(context).error;
        break;
      default: // pending
        color = AppColors.of(context).warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
