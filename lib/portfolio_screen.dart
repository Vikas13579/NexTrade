// lib/presentation/screens/portfolio/portfolio_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nextrade/widgets.dart';

import 'app_theme.dart';
import 'data_service.dart';
import 'model.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<HoldingModel> _holdings = MockDataService.getMockHoldings();
  final List<TransactionModel> _transactions = MockDataService.getMockTransactions();

  double get totalInvested =>
      _holdings.fold(0, (sum, h) => sum + h.investedAmount);
  double get currentValue =>
      _holdings.fold(0, (sum, h) => sum + h.currentValue);
  double get totalPnL => currentValue - totalInvested;
  double get totalPnLPercent => (totalPnL / totalInvested) * 100;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: NexTradeColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          _buildSectorPieSection(),
          TabBar(
            controller: _tabController,
            indicatorColor: NexTradeColors.primary,
            labelColor: NexTradeColors.primary,
            unselectedLabelColor: NexTradeColors.textMuted,
            dividerColor: NexTradeColors.border,
            tabs: const [
              Tab(text: 'Holdings'),
              Tab(text: 'Transactions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHoldingsTab(),
                _buildTransactionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final isProfit = totalPnL >= 0;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1520), Color(0xFF111D2C)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexTradeColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Value',
                      style: TextStyle(color: NexTradeColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (b) => NexTradeColors.primaryGradient.createShader(b),
                    child: Text(
                      '₹${currentValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total P&L',
                      style: TextStyle(color: NexTradeColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${isProfit ? '+' : ''}₹${totalPnL.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isProfit ? NexTradeColors.profit : NexTradeColors.loss,
                    ),
                  ),
                  PriceChangeBadge(
                    change: totalPnL,
                    changePercent: totalPnLPercent,
                    compact: true,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.75,
            backgroundColor: NexTradeColors.border,
            valueColor: AlwaysStoppedAnimation(
              isProfit ? NexTradeColors.profit : NexTradeColors.loss,
            ),
            borderRadius: BorderRadius.circular(4),
            minHeight: 4,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat('Invested', '₹${totalInvested.toStringAsFixed(0)}'),
              _buildMiniStat('Day P&L', '+₹3,456.20'),
              _buildMiniStat('Holdings', '${_holdings.length}'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 11)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(
                color: NexTradeColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  Widget _buildSectorPieSection() {
    final sectorData = <String, double>{};
    for (var h in _holdings) {
      sectorData[h.sector] = (sectorData[h.sector] ?? 0) + h.currentValue;
    }
    final total = sectorData.values.fold(0.0, (a, b) => a + b);

    final colors = [
      NexTradeColors.primary,
      NexTradeColors.secondary,
      NexTradeColors.profit,
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: PieChart(
              PieChartData(
                sections: sectorData.entries.toList().asMap().entries.map((e) {
                  return PieChartSectionData(
                    color: colors[e.key % colors.length],
                    value: e.value.value,
                    showTitle: false,
                    radius: 28,
                  );
                }).toList(),
                centerSpaceRadius: 14,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: sectorData.entries.toList().asMap().entries.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors[e.key % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${e.value.key} ${(e.value.value / total * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          color: NexTradeColors.textSecondary, fontSize: 11),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _holdings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _buildHoldingCard(_holdings[i]),
    );
  }

  Widget _buildHoldingCard(HoldingModel holding) {
    final isProfit = holding.isProfitable;
    return NexCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: NexTradeColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    holding.symbol.substring(0, 2),
                    style: const TextStyle(
                      color: NexTradeColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(holding.symbol,
                        style: const TextStyle(
                            color: NexTradeColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    Text(
                      '${holding.quantity} shares · Avg ₹${holding.averagePrice.toStringAsFixed(2)}',
                      style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${holding.currentValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: NexTradeColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                  Text(
                    '${isProfit ? '+' : ''}₹${holding.pnl.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isProfit ? NexTradeColors.profit : NexTradeColors.loss,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: holding.currentValue / (holding.investedAmount * 1.5),
                    backgroundColor: NexTradeColors.border,
                    valueColor: AlwaysStoppedAnimation(
                        isProfit ? NexTradeColors.profit : NexTradeColors.loss),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PriceChangeBadge(
                change: holding.pnl,
                changePercent: holding.pnlPercent,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _buildTransactionTile(_transactions[i]),
    );
  }

  Widget _buildTransactionTile(TransactionModel txn) {
    final isCredit = txn.isCredit;
    final iconMap = {
      'CREDIT': Icons.add_circle_outline,
      'DEBIT': Icons.remove_circle_outline,
      'BUY': Icons.shopping_bag_outlined,
      'SELL': Icons.sell_outlined,
      'DIVIDEND': Icons.star_outline_rounded,
    };

    final colorMap = {
      'CREDIT': NexTradeColors.profit,
      'DEBIT': NexTradeColors.loss,
      'BUY': NexTradeColors.secondary,
      'SELL': NexTradeColors.profit,
      'DIVIDEND': NexTradeColors.primary,
    };

    final color = colorMap[txn.type] ?? NexTradeColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: NexTradeColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexTradeColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconMap[txn.type] ?? Icons.swap_horiz, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.description,
                    style: const TextStyle(
                        color: NexTradeColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(
                  '${txn.date.day}/${txn.date.month}/${txn.date.year} · ${txn.status}',
                  style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}₹${txn.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isCredit ? NexTradeColors.profit : NexTradeColors.loss,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}