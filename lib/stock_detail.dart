// lib/presentation/screens/market/stock_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nextrade/trade_bottom.dart';
import 'package:nextrade/widgets.dart';

import 'app_theme.dart';
import 'model.dart';

class StockDetailScreen extends StatefulWidget {
  final StockModel stock;
  const StockDetailScreen({super.key, required this.stock});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRange = '1D';
  bool _isWatchlisted = false;

  final List<String> _ranges = ['1D', '1W', '1M', '3M', '6M', '1Y'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isWatchlisted = widget.stock.isWatchlisted;
  }

  List<FlSpot> get _chartData {
    final base = widget.stock.sparklineData;
    return base
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final stock = widget.stock;
    final isPositive = stock.isGainer;

    return Scaffold(
      backgroundColor: NexTradeColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(stock, isPositive),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildPriceSection(stock, isPositive),
                const SizedBox(height: 20),
                _buildChartSection(stock, isPositive),
                const SizedBox(height: 20),
                _buildTabSection(stock),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildTradeButtons(stock),
    );
  }

  SliverAppBar _buildAppBar(StockModel stock, bool isPositive) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: NexTradeColors.background,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: NexTradeColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
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
                    color: NexTradeColors.primary, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock.symbol,
                    style: const TextStyle(
                        color: NexTradeColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                Text(stock.exchange,
                    style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isWatchlisted ? Icons.star_rounded : Icons.star_outline_rounded,
            color: _isWatchlisted ? NexTradeColors.secondary : NexTradeColors.textMuted,
          ),
          onPressed: () => setState(() => _isWatchlisted = !_isWatchlisted),
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined, color: NexTradeColors.textMuted),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPriceSection(StockModel stock, bool isPositive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stock.formattedPrice,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: NexTradeColors.textPrimary,
            letterSpacing: -1,
          ),
        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: 6),
        Row(
          children: [
            PriceChangeBadge(
              change: stock.change,
              changePercent: stock.changePercent,
            ),
            const SizedBox(width: 8),
            Text(
              '${isPositive ? '+' : ''}₹${stock.change.toStringAsFixed(2)} today',
              style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 12),
            ),
          ],
        ).animate().fadeIn(delay: 100.ms),
      ],
    );
  }

  Widget _buildChartSection(StockModel stock, bool isPositive) {
    return NexCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Range selector
          Row(
            children: _ranges.map((range) {
              final isSelected = _selectedRange == range;
              return GestureDetector(
                onTap: () => setState(() => _selectedRange = range),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? NexTradeColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    range,
                    style: TextStyle(
                      color: isSelected ? NexTradeColors.background : NexTradeColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: NexTradeColors.border,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (val, meta) => Text(
                        val.toStringAsFixed(0),
                        style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _chartData,
                    isCurved: true,
                    gradient: isPositive
                        ? NexTradeColors.profitGradient
                        : NexTradeColors.lossGradient,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          (isPositive ? NexTradeColors.profit : NexTradeColors.loss)
                              .withOpacity(0.15),
                          (isPositive ? NexTradeColors.profit : NexTradeColors.loss)
                              .withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: NexTradeColors.surfaceHighlight, // Older versions
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '₹${s.y.toStringAsFixed(2)}',
                        const TextStyle(
                            color: NexTradeColors.primary, fontWeight: FontWeight.w700),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildTabSection(StockModel stock) {
    return NexCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: NexTradeColors.primary,
            labelColor: NexTradeColors.primary,
            unselectedLabelColor: NexTradeColors.textMuted,
            dividerColor: NexTradeColors.border,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Financials'),
              Tab(text: 'About'),
            ],
          ),
          SizedBox(
            height: 280,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(stock),
                _buildFinancialsTab(stock),
                _buildAboutTab(stock),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildOverviewTab(StockModel stock) {
    final items = [
      {'label': 'Open', 'value': '₹${stock.openPrice.toStringAsFixed(2)}'},
      {'label': 'Prev. Close', 'value': '₹${stock.previousClose.toStringAsFixed(2)}'},
      {'label': "Day's High", 'value': '₹${stock.highPrice.toStringAsFixed(2)}'},
      {'label': "Day's Low", 'value': '₹${stock.lowPrice.toStringAsFixed(2)}'},
      {'label': '52W High', 'value': '₹${stock.weekHigh52.toStringAsFixed(2)}'},
      {'label': '52W Low', 'value': '₹${stock.weekLow52.toStringAsFixed(2)}'},
      {'label': 'Market Cap', 'value': stock.formattedMarketCap},
      {'label': 'Volume', 'value': '${(stock.volume / 1000).toStringAsFixed(0)}K'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3.5,
        children: items.map((item) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item['label']!,
                  style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 12)),
              Text(item['value']!,
                  style: const TextStyle(
                      color: NexTradeColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFinancialsTab(StockModel stock) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFinancialRow('P/E Ratio', stock.peRatio.toStringAsFixed(1)),
          _buildFinancialRow('Dividend Yield', '${stock.dividendYield.toStringAsFixed(2)}%'),
          _buildFinancialRow('Market Cap', stock.formattedMarketCap),
          _buildFinancialRow('Sector', stock.sector),
          _buildFinancialRow('Exchange', stock.exchange),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: NexTradeColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: NexTradeColors.textSecondary, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: NexTradeColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAboutTab(StockModel stock) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stock.name,
            style: const TextStyle(
                color: NexTradeColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            '${stock.name} is a leading company in the ${stock.sector} sector listed on ${stock.exchange}. '
                'The company has consistently delivered strong performance with a market cap of ${stock.formattedMarketCap}.',
            style: const TextStyle(
                color: NexTradeColors.textSecondary, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: NexTradeColors.primaryGlow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              stock.sector,
              style: const TextStyle(
                  color: NexTradeColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeButtons(StockModel stock) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: NexTradeColors.surface,
        border: Border(top: BorderSide(color: NexTradeColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _openTrade(stock, 'SELL'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NexTradeColors.loss,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('SELL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _openTrade(stock, 'BUY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NexTradeColors.profit,
                foregroundColor: NexTradeColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('BUY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  void _openTrade(StockModel stock, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TradeBottomSheet(stock: stock, initialType: type),
    );
  }
}