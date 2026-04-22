// lib/presentation/screens/orders/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nextrade/widgets.dart';

import 'app_theme.dart';
import 'data_service.dart';
import 'model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<OrderModel> _orders = MockDataService.getMockOrders();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  List<OrderModel> get _pendingOrders =>
      _orders.where((o) => o.status == 'PENDING').toList();
  List<OrderModel> get _executedOrders =>
      _orders.where((o) => o.status == 'EXECUTED').toList();
  List<OrderModel> get _cancelledOrders =>
      _orders.where((o) => o.status == 'CANCELLED' || o.status == 'REJECTED').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: NexTradeColors.primary,
          labelColor: NexTradeColors.primary,
          unselectedLabelColor: NexTradeColors.textMuted,
          dividerColor: NexTradeColors.border,
          tabs: [
            Tab(text: 'Pending (${_pendingOrders.length})'),
            Tab(text: 'Executed (${_executedOrders.length})'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(_pendingOrders, showCancel: true),
          _buildOrderList(_executedOrders),
          _buildOrderList(_cancelledOrders),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, {bool showCancel = false}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.receipt_long_outlined, size: 64, color: NexTradeColors.textMuted),
            SizedBox(height: 12),
            Text('No orders', style: TextStyle(color: NexTradeColors.textMuted)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        return _buildOrderCard(orders[i], showCancel: showCancel)
            .animate()
            .fadeIn(delay: Duration(milliseconds: i * 50));
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, {bool showCancel = false}) {
    final isBuy = order.orderType == 'BUY';
    final statusColors = {
      'PENDING': NexTradeColors.secondary,
      'EXECUTED': NexTradeColors.profit,
      'CANCELLED': NexTradeColors.textMuted,
      'REJECTED': NexTradeColors.loss,
    };
    final statusColor = statusColors[order.status] ?? NexTradeColors.textMuted;

    return NexCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isBuy ? NexTradeColors.profitBg : NexTradeColors.lossBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.orderType,
                  style: TextStyle(
                    color: isBuy ? NexTradeColors.profit : NexTradeColors.loss,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NexTradeColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    order.symbol.substring(0, 2),
                    style: const TextStyle(
                        color: NexTradeColors.primary, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.symbol,
                        style: const TextStyle(
                            color: NexTradeColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    Text(order.name,
                        style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                          color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: NexTradeColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOrderDetail('Qty', '${order.quantity}'),
              _buildOrderDetail('Type', '${order.priceType} / ${order.productType}'),
              _buildOrderDetail(
                  'Price', '₹${(order.executedPrice > 0 ? order.executedPrice : order.price).toStringAsFixed(2)}'),
              _buildOrderDetail('Value', '₹${order.totalValue.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 12, color: NexTradeColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 11),
              ),
              const Spacer(),
              if (showCancel)
                GestureDetector(
                  onTap: () => _cancelOrder(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: NexTradeColors.loss),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: NexTradeColors.loss, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: NexTradeColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  void _cancelOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexTradeColors.surface,
        title: const Text('Cancel Order', style: TextStyle(color: NexTradeColors.textPrimary)),
        content: Text('Cancel order for ${order.quantity} ${order.symbol}?',
            style: const TextStyle(color: NexTradeColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(color: NexTradeColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                order.status = 'CANCELLED';
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexTradeColors.loss),
            child: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}