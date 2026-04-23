// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nextrade/stock_detail.dart';
import 'package:nextrade/watchlist_screen.dart';
import 'package:nextrade/widgets.dart';
import 'package:nextrade/market_simulator.dart';

import 'app_theme.dart';
import 'data_service.dart';
import 'hive_service.dart';
import 'market_screen.dart';
import 'market_store.dart';
import 'model.dart';
import 'orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showBalance = true;
  final List<StockModel> _stocks = MarketStore.stocks;
  // final List<StockModel> _stocks = MockDataService.getMockStocks();
  final List<Map<String, dynamic>> _indices =
      MockDataService.getMarketIndices();

  @override
  void initState() {
    super.initState();

    MarketSimulator.start(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    MarketSimulator.stop(); // VERY IMPORTANT
    super.dispose();
  }

  // ── navigation helpers ────────────────────────────────────────
  void _goToStock(StockModel stock) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StockDetailScreen(stock: stock)),
    );
  }

  void _goToMarket({String? filter}) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MarketScreen(initialFilter: filter)),
    );
  }

  void _goTo(Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                ValueListenableBuilder(
                  valueListenable: HiveService.holdingsBox.listenable(),
                  builder: (context, box, _) {
                    return _buildPortfolioCard();
                  },
                ),
                const SizedBox(height: 20),
                _buildIndicesStrip(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 28),
                // Market Movers — See All goes to market filtered by Gainers
                _buildSectionHeader(
                  'Market Movers',
                  onSeeAll: () => _goToMarket(filter: 'Gainers'),
                ),
                const SizedBox(height: 12),
                _buildTopGainers(),
                const SizedBox(height: 28),
                // Trending — See All goes to full market
                _buildSectionHeader(
                  'Trending Now',
                  onSeeAll: () => _goToMarket(),
                ),
                const SizedBox(height: 12),
                ..._stocks.take(6).map((s) => _buildStockTile(s)),
                const SizedBox(height: 28),
                // Top Losers section
                _buildSectionHeader(
                  'Top Losers',
                  onSeeAll: () => _goToMarket(filter: 'Losers'),
                ),
                const SizedBox(height: 12),
                _buildTopLosers(),
                const SizedBox(height: 28),
                // Sector overview
                _buildSectionHeader('By Sector', onSeeAll: () => _goToMarket()),
                const SizedBox(height: 1),
                _buildSectorGrid(),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: NexTradeColors.background,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: NexTradeColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.candlestick_chart_rounded,
              color: NexTradeColors.background,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          ShaderMask(
            shaderCallback: (b) =>
                NexTradeColors.primaryGradient.createShader(b),
            child: const Text(
              'NexTrade',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          const MarketStatusChip(isOpen: true),
          const SizedBox(width: 4),
          // Notification bell with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: NexTradeColors.textPrimary,
                ),
                onPressed: () => _goTo(const NotificationsScreen()),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: NexTradeColors.loss,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          // Search icon
          IconButton(
            icon: const Icon(Icons.search, color: NexTradeColors.textPrimary),
            onPressed: () => _goTo(const SearchScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    final holdings = HiveService.holdingsBox.values.toList();

    double portfolio = holdings.fold(0, (sum, h) => sum + h.currentValue);

    double invested = holdings.fold(0, (sum, h) => sum + h.investedAmount);

    double pnl = portfolio - invested;

    double pnlPercent = invested == 0 ? 0 : (pnl / invested) * 100;

    double available = 0; // until wallet added

    return GestureDetector(
      onTap: () {},
      child: NexCard(
        showGlow: true,
        borderColor: NexTradeColors.primaryDim.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Portfolio Value',
                  style: TextStyle(
                    color: NexTradeColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _showBalance = !_showBalance),
                      child: Icon(
                        _showBalance
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: NexTradeColors.textMuted,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _goTo(const AddFundsScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: NexTradeColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add,
                              size: 12,
                              color: NexTradeColors.background,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Add Funds',
                              style: TextStyle(
                                color: NexTradeColors.background,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// BALANCE
            if (_showBalance) ...[
              ShaderMask(
                shaderCallback: (b) =>
                    NexTradeColors.primaryGradient.createShader(b),
                child: Text(
                  '₹${portfolio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              /// PnL
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: pnl >= 0
                          ? NexTradeColors.profitBg
                          : NexTradeColors.lossBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          pnl >= 0
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 12,
                          color: pnl >= 0
                              ? NexTradeColors.profit
                              : NexTradeColors.loss,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${pnl >= 0 ? '+' : ''}₹${pnl.toStringAsFixed(2)} '
                          '(${pnlPercent.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            color: pnl >= 0
                                ? NexTradeColors.profit
                                : NexTradeColors.loss,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Today',
                    style: TextStyle(
                      color: NexTradeColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ] else
              const Text(
                '₹ ••••••••',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: NexTradeColors.textMuted,
                ),
              ),

            const SizedBox(height: 16),

            _buildMiniChart(),

            const SizedBox(height: 16),

            /// STATS
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Invested',
                    '₹${invested.toStringAsFixed(0)}',
                    null,
                  ),
                ),
                Container(width: 1, height: 40, color: NexTradeColors.border),

                Expanded(
                  child: _buildStatItem(
                    'Returns',
                    '${pnl >= 0 ? '+' : ''}₹${pnl.toStringAsFixed(0)}',
                    pnl >= 0 ? NexTradeColors.profit : NexTradeColors.loss,
                  ),
                ),
                Container(width: 1, height: 40, color: NexTradeColors.border),

                Expanded(
                  child: _buildStatItem(
                    'Available',
                    '₹${available.toStringAsFixed(0)}',
                    null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildMiniChart() {
    final holdings = HiveService.holdingsBox.values.toList();

    if (holdings.isEmpty) {
      return const SizedBox(height: 56);
    }

    final stock = _stocks.firstWhere(
          (s) => s.symbol == holdings.first.symbol,
      orElse: () => _stocks.first,
    );

    final spots = stock.sparklineData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return SizedBox(
      height: 56,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: NexTradeColors.primaryGradient,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    NexTradeColors.primary.withOpacity(0.18),
                    NexTradeColors.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }

  // Widget _buildMiniChart() {
  //   final spots = [
  //     const FlSpot(0, 4.2),
  //     const FlSpot(1, 4.35),
  //     const FlSpot(2, 4.1),
  //     const FlSpot(3, 4.45),
  //     const FlSpot(4, 4.3),
  //     const FlSpot(5, 4.55),
  //     const FlSpot(6, 4.48),
  //     const FlSpot(7, 4.6),
  //     const FlSpot(8, 4.52),
  //     const FlSpot(9, 4.73),
  //     const FlSpot(10, 4.65),
  //     const FlSpot(11, 4.87),
  //   ];
  //   return SizedBox(
  //     height: 56,
  //     child: LineChart(
  //       LineChartData(
  //         gridData: const FlGridData(show: false),
  //         titlesData: const FlTitlesData(show: false),
  //         borderData: FlBorderData(show: false),
  //         lineBarsData: [
  //           LineChartBarData(
  //             spots: spots,
  //             isCurved: true,
  //             gradient: NexTradeColors.primaryGradient,
  //             barWidth: 2,
  //             dotData: const FlDotData(show: false),
  //             belowBarData: BarAreaData(
  //               show: true,
  //               gradient: LinearGradient(
  //                 colors: [
  //                   NexTradeColors.primary.withOpacity(0.18),
  //                   NexTradeColors.primary.withOpacity(0),
  //                 ],
  //                 begin: Alignment.topCenter,
  //                 end: Alignment.bottomCenter,
  //               ),
  //             ),
  //           ),
  //         ],
  //         lineTouchData: const LineTouchData(enabled: false),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatItem(String label, String value, Color? valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? NexTradeColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── Indices Strip ─────────────────────────────────────────────
  Widget _buildIndicesStrip() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _indices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final idx = _indices[i];
          final isGainer = idx['isGainer'] as bool;
          return NexCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            borderColor: isGainer
                ? NexTradeColors.profitBg
                : NexTradeColors.lossBg,
            onTap: () => _goToMarket(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  idx['name'] as String,
                  style: const TextStyle(
                    color: NexTradeColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  (idx['value'] as double).toStringAsFixed(2),
                  style: const TextStyle(
                    color: NexTradeColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                PriceChangeBadge(
                  change: idx['change'] as double,
                  changePercent: idx['changePercent'] as double,
                  compact: true,
                ),
              ],
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ── Quick Actions ─────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.trending_up_rounded,
        'label': 'Invest',
        'onTap': () => _goToMarket(),
      },
      {
        'icon': Icons.account_balance_rounded,
        'label': 'Funds',
        'onTap': () => _goTo(const AddFundsScreen()),
      },
      {
        'icon': Icons.receipt_long_rounded,
        'label': 'Orders',
        'onTap': () => _goTo(const OrdersScreen()),
      },
      {
        'icon': Icons.star_rounded,
        'label': 'Watchlist',
        'onTap': () => _goTo(const WatchlistScreen()),
      },
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Reports',
        'onTap': () => _goTo(const ReportsQuickScreen()),
      },
      {
        'icon': Icons.headset_mic_rounded,
        'label': 'Support',
        'onTap': () => _goTo(const SupportQuickScreen()),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Actions'),
        const SizedBox(height: 12),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: actions.map((a) {
            return NexCard(
              onTap: a['onTap'] as VoidCallback,
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: NexTradeColors.primaryGlow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      a['icon'] as IconData,
                      color: NexTradeColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a['label'] as String,
                    style: const TextStyle(
                      color: NexTradeColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  // ── Section Header ────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: NexTradeColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: NexTradeColors.primaryGlow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'See All',
                style: TextStyle(
                  color: NexTradeColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Top Gainers ───────────────────────────────────────────────
  Widget _buildTopGainers() {

    final gainers = _stocks
        .where((s) => s.isGainer)
        .toList()
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));

    // final gainers = _stocks.where((s) => s.isGainer).take(5).toList();
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: gainers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final stock = gainers[i];
          return GestureDetector(
            onTap: () => _goToStock(stock),
            child: NexCard(
              padding: const EdgeInsets.all(14),
              borderColor: NexTradeColors.profitBg,
              child: SizedBox(
                width: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: NexTradeColors.surfaceHighlight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              stock.symbol.substring(0, 2),
                              style: const TextStyle(
                                color: NexTradeColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        PriceChangeBadge(
                          change: stock.change,
                          changePercent: stock.changePercent,
                          compact: true,
                          showIcon: false,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      stock.symbol,
                      style: const TextStyle(
                        color: NexTradeColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stock.formattedPrice,
                      style: const TextStyle(
                        color: NexTradeColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Tiny sparkline
                    SizedBox(
                      height: 22,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: stock.sparklineData
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                                  .toList(),
                              isCurved: true,
                              color: NexTradeColors.profit,
                              barWidth: 1.5,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                          lineTouchData: const LineTouchData(enabled: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  // ── Top Losers ────────────────────────────────────────────────
  Widget _buildTopLosers() {
    final losers = _stocks
        .where((s) => !s.isGainer)
        .toList()
      ..sort((a, b) => a.changePercent.compareTo(b.changePercent));

    // final losers = _stocks.where((s) => !s.isGainer).take(5).toList();
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: losers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final stock = losers[i];
          return GestureDetector(
            onTap: () => _goToStock(stock),
            child: NexCard(
              padding: const EdgeInsets.all(14),
              borderColor: NexTradeColors.lossBg,
              child: SizedBox(
                width: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: NexTradeColors.surfaceHighlight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              stock.symbol.substring(0, 2),
                              style: const TextStyle(
                                color: NexTradeColors.loss,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        PriceChangeBadge(
                          change: stock.change,
                          changePercent: stock.changePercent,
                          compact: true,
                          showIcon: false,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      stock.symbol,
                      style: const TextStyle(
                        color: NexTradeColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stock.formattedPrice,
                      style: const TextStyle(
                        color: NexTradeColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 22,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: stock.sparklineData
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                                  .toList(),
                              isCurved: true,
                              color: NexTradeColors.loss,
                              barWidth: 1.5,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                          lineTouchData: const LineTouchData(enabled: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  // ── Stock List Tile ───────────────────────────────────────────
  Widget _buildStockTile(StockModel stock) {
    return GestureDetector(
      onTap: () => _goToStock(stock),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: NexTradeColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NexTradeColors.border),
        ),
        child: Row(
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
                  stock.symbol.substring(0, 2),
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
                  Text(
                    stock.symbol,
                    style: const TextStyle(
                      color: NexTradeColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    stock.name,
                    style: const TextStyle(
                      color: NexTradeColors.textMuted,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 52,
              height: 28,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: stock.sparklineData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: stock.isGainer
                          ? NexTradeColors.profit
                          : NexTradeColors.loss,
                      barWidth: 1.5,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  lineTouchData: const LineTouchData(enabled: false),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stock.formattedPrice,
                  style: const TextStyle(
                    color: NexTradeColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                PriceChangeBadge(
                  change: stock.change,
                  changePercent: stock.changePercent,
                  compact: true,
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: NexTradeColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ── Sector Grid ───────────────────────────────────────────────
  Widget _buildSectorGrid() {
    final sectors = [
      {
        'name': 'IT',
        'icon': Icons.computer_rounded,
        'color': NexTradeColors.primary,
        'change': '+1.4%',
      },
      {
        'name': 'Banking',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF6366F1),
        'change': '-0.3%',
      },
      {
        'name': 'Pharma',
        'icon': Icons.medical_services_rounded,
        'color': NexTradeColors.profit,
        'change': '+2.1%',
      },
      {
        'name': 'Energy',
        'icon': Icons.bolt_rounded,
        'color': NexTradeColors.secondary,
        'change': '+0.8%',
      },
      {
        'name': 'Auto',
        'icon': Icons.directions_car_rounded,
        'color': const Color(0xFFEC4899),
        'change': '-1.2%',
      },
      {
        'name': 'FMCG',
        'icon': Icons.shopping_cart_rounded,
        'color': const Color(0xFF14B8A6),
        'change': '+0.5%',
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: sectors.map((s) {
        final color = s['color'] as Color;
        final isPos = (s['change'] as String).startsWith('+');
        return GestureDetector(
          onTap: () => _goToMarket(filter: s['name'] as String),
          child: NexCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s['icon'] as IconData, color: color, size: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  s['name'] as String,
                  style: const TextStyle(
                    color: NexTradeColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s['change'] as String,
                  style: TextStyle(
                    color: isPos ? NexTradeColors.profit : NexTradeColors.loss,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 450.ms);
  }
}

// ════════════════════════════════════════════════════════════════
// NOTIFICATIONS SCREEN
// ════════════════════════════════════════════════════════════════
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'type': 'order',
        'title': 'Order Executed',
        'body': 'RELIANCE BUY order for 10 qty executed at ₹2847.65',
        'time': '2 min ago',
        'read': false,
        'icon': Icons.check_circle_outline,
        'color': NexTradeColors.profit,
      },
      {
        'type': 'price',
        'title': 'Price Alert',
        'body': 'TCS crossed your target of ₹3700. Current: ₹3658.90',
        'time': '1 hr ago',
        'read': false,
        'icon': Icons.notifications_active_outlined,
        'color': NexTradeColors.secondary,
      },
      {
        'type': 'market',
        'title': 'Market Opens in 15 min',
        'body': 'NSE & BSE open at 9:15 AM. Futures suggest gap-up open.',
        'time': '9:00 AM',
        'read': true,
        'icon': Icons.access_time,
        'color': NexTradeColors.primary,
      },
      {
        'type': 'dividend',
        'title': 'Dividend Credited',
        'body': 'TCS Q2 FY25 dividend of ₹1,250 credited to your account.',
        'time': 'Yesterday',
        'read': true,
        'icon': Icons.star_outline,
        'color': const Color(0xFF6366F1),
      },
      {
        'type': 'kyc',
        'title': 'KYC Verified',
        'body': 'Your KYC verification is complete. Happy trading!',
        'time': '3 days ago',
        'read': true,
        'icon': Icons.verified_outlined,
        'color': NexTradeColors.profit,
      },
    ];

    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all read',
              style: TextStyle(color: NexTradeColors.primary, fontSize: 12),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final n = notifications[i];
          final isUnread = !(n['read'] as bool);
          final color = n['color'] as Color;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUnread
                  ? NexTradeColors.surfaceHighlight
                  : NexTradeColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUnread
                    ? NexTradeColors.borderLight
                    : NexTradeColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(n['icon'] as IconData, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            n['title'] as String,
                            style: TextStyle(
                              color: NexTradeColors.textPrimary,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          if (isUnread)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: NexTradeColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n['body'] as String,
                        style: const TextStyle(
                          color: NexTradeColors.textSecondary,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n['time'] as String,
                        style: const TextStyle(
                          color: NexTradeColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: i * 60));
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SEARCH SCREEN
// ════════════════════════════════════════════════════════════════
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final List<StockModel> _stocks = MarketStore.stocks;
  List<StockModel> _results = [];
  bool _hasSearched = false;

  final List<String> _recent = ['RELIANCE', 'TCS', 'INFY', 'HDFCBANK'];
  final List<String> _trending = ['BAJFINANCE', 'WIPRO', 'SBIN', 'MARUTI'];

  void _search(String q) {
    setState(() {
      _hasSearched = q.isNotEmpty;
      _results = _stocks
          .where(
            (s) =>
                s.symbol.toLowerCase().contains(q.toLowerCase()) ||
                s.name.toLowerCase().contains(q.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _search,
          style: const TextStyle(
            color: NexTradeColors.textPrimary,
            fontSize: 16,
          ),
          decoration: const InputDecoration(
            hintText: 'Search stocks, sectors...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: NexTradeColors.textMuted),
              onPressed: () {
                _ctrl.clear();
                _search('');
              },
            ),
        ],
      ),
      body: _hasSearched ? _buildResults() : _buildDiscovery(),
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: NexTradeColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'No results found',
              style: TextStyle(color: NexTradeColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          const Divider(color: NexTradeColors.border, height: 1, indent: 68),
      itemBuilder: (ctx, i) {
        final s = _results[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 4,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: NexTradeColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                s.symbol.substring(0, 2),
                style: const TextStyle(
                  color: NexTradeColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          title: Text(
            s.symbol,
            style: const TextStyle(
              color: NexTradeColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            s.name,
            style: const TextStyle(
              color: NexTradeColors.textMuted,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                s.formattedPrice,
                style: const TextStyle(
                  color: NexTradeColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              PriceChangeBadge(
                change: s.change,
                changePercent: s.changePercent,
                compact: true,
              ),
            ],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StockDetailScreen(stock: s)),
          ),
        );
      },
    );
  }

  Widget _buildDiscovery() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildChipSection(
          'Recent Searches',
          _recent,
          Icons.history,
          NexTradeColors.textMuted,
        ),
        const SizedBox(height: 24),
        _buildChipSection(
          'Trending',
          _trending,
          Icons.trending_up_rounded,
          NexTradeColors.primary,
        ),
      ],
    );
  }

  Widget _buildChipSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((sym) {
            final stock = _stocks.firstWhere(
              (s) => s.symbol == sym,
              orElse: () => _stocks.first,
            );
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StockDetailScreen(stock: stock),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: NexTradeColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: NexTradeColors.border),
                ),
                child: Text(
                  sym,
                  style: const TextStyle(
                    color: NexTradeColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ADD FUNDS SCREEN
// ════════════════════════════════════════════════════════════════
class AddFundsScreen extends StatefulWidget {
  const AddFundsScreen({super.key});

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _amountCtrl = TextEditingController();
  String _selectedMethod = 'UPI';
  bool _isLoading = false;

  final List<int> _quickAmounts = [5000, 10000, 25000, 50000];
  final List<String> _methods = ['UPI', 'Net Banking', 'NEFT/RTGS'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Funds'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: NexTradeColors.primary,
          labelColor: NexTradeColors.primary,
          unselectedLabelColor: NexTradeColors.textMuted,
          dividerColor: NexTradeColors.border,
          tabs: const [
            Tab(text: 'Add Funds'),
            Tab(text: 'Withdraw'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [_buildAddFunds(), _buildWithdraw()],
      ),
    );
  }

  Widget _buildAddFunds() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance card
          NexCard(
            showGlow: true,
            borderColor: NexTradeColors.primaryDim.withOpacity(0.3),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: NexTradeColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹21,374.60',
                      style: TextStyle(
                        color: NexTradeColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: NexTradeColors.primaryGlow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: NexTradeColors.primary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Enter Amount',
            style: TextStyle(color: NexTradeColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: NexTradeColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixText: '₹  ',
              prefixStyle: TextStyle(
                color: NexTradeColors.textSecondary,
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
              hintText: '0',
            ),
          ),
          const SizedBox(height: 16),

          // Quick amounts
          Wrap(
            spacing: 8,
            children: _quickAmounts.map((amt) {
              return GestureDetector(
                onTap: () => setState(() => _amountCtrl.text = amt.toString()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: NexTradeColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: NexTradeColors.border),
                  ),
                  child: Text(
                    '+₹${amt ~/ 1000}K',
                    style: const TextStyle(
                      color: NexTradeColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          const Text(
            'Payment Method',
            style: TextStyle(color: NexTradeColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ..._methods.map((m) => _buildMethodTile(m)),
          const SizedBox(height: 28),

          NexButton(
            text: _amountCtrl.text.isEmpty
                ? 'Enter Amount'
                : 'Add ₹${_amountCtrl.text}',
            isLoading: _isLoading,
            onPressed: _amountCtrl.text.isEmpty ? null : _addFunds,
          ),
        ],
      ),
    );
  }

  Widget _buildWithdraw() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NexCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Withdrawable Balance',
                  style: TextStyle(
                    color: NexTradeColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '₹18,500.00',
                  style: TextStyle(
                    color: NexTradeColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '₹2,874.60 is blocked for open positions',
                  style: TextStyle(
                    color: NexTradeColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Withdraw to Bank',
            style: TextStyle(color: NexTradeColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          NexCard(
            child: const Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: NexTradeColors.primary,
                  size: 22,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HDFC Bank',
                      style: TextStyle(
                        color: NexTradeColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'XXXX XXXX 4521',
                      style: TextStyle(
                        color: NexTradeColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(
                  Icons.check_circle,
                  color: NexTradeColors.profit,
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Amount',
            style: TextStyle(color: NexTradeColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          const TextField(
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: NexTradeColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
            decoration: InputDecoration(prefixText: '₹  ', hintText: '0'),
          ),
          const SizedBox(height: 12),
          const Text(
            '* Funds reflect in your bank account within 1 working day',
            style: TextStyle(color: NexTradeColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 28),
          NexButton(text: 'Withdraw Funds', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildMethodTile(String method) {
    final isSelected = _selectedMethod == method;
    final icons = {
      'UPI': Icons.phone_android_rounded,
      'Net Banking': Icons.language_rounded,
      'NEFT/RTGS': Icons.account_balance_rounded,
    };
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? NexTradeColors.primaryGlow
              : NexTradeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? NexTradeColors.primary : NexTradeColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icons[method],
              color: isSelected
                  ? NexTradeColors.primary
                  : NexTradeColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              method,
              style: TextStyle(
                color: isSelected
                    ? NexTradeColors.primary
                    : NexTradeColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: NexTradeColors.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  void _addFunds() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: NexTradeColors.profit),
              const SizedBox(width: 10),
              Text(
                '₹${_amountCtrl.text} added successfully!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: NexTradeColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

// ════════════════════════════════════════════════════════════════
// REPORTS QUICK SCREEN (from Home quick action)
// ════════════════════════════════════════════════════════════════
class ReportsQuickScreen extends StatelessWidget {
  const ReportsQuickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        'icon': Icons.receipt_long_outlined,
        'title': 'Contract Notes',
        'subtitle': 'Daily trade confirmations',
        'color': NexTradeColors.primary,
      },
      {
        'icon': Icons.account_balance_outlined,
        'title': 'P&L Statement',
        'subtitle': 'Profit & Loss summary',
        'color': NexTradeColors.profit,
      },
      {
        'icon': Icons.savings_outlined,
        'title': 'Capital Gains',
        'subtitle': 'Tax computation',
        'color': NexTradeColors.secondary,
      },
      {
        'icon': Icons.swap_horiz,
        'title': 'Ledger',
        'subtitle': 'Fund inflows & outflows',
        'color': const Color(0xFF6366F1),
      },
    ];

    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: reports.map((r) {
          final color = r['color'] as Color;
          return NexCard(
            onTap: () {},
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(r['icon'] as IconData, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  r['title'] as String,
                  style: const TextStyle(
                    color: NexTradeColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  r['subtitle'] as String,
                  style: const TextStyle(
                    color: NexTradeColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SUPPORT QUICK SCREEN
// ════════════════════════════════════════════════════════════════
class SupportQuickScreen extends StatelessWidget {
  const SupportQuickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildContactCard(
                  Icons.chat_bubble_outline,
                  'Live Chat',
                  'Online now',
                  NexTradeColors.profit,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactCard(
                  Icons.email_outlined,
                  'Email Us',
                  'support@nextrade.in',
                  NexTradeColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildContactCard(
                  Icons.phone_outlined,
                  'Call Us',
                  '1800-123-4567',
                  NexTradeColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactCard(
                  Icons.article_outlined,
                  'Raise Ticket',
                  'Track issues',
                  const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexTradeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexTradeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: NexTradeColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: NexTradeColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
