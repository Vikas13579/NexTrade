// lib/presentation/screens/market/market_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nextrade/widgets.dart';

import 'app_theme.dart';
import 'data_service.dart';
import 'model.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key, String? initialFilter});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<StockModel> _allStocks = [];
  List<StockModel> _filteredStocks = [];
  String _selectedFilter = 'All';
  String _sortBy = 'Name';
  bool _sortAsc = true;

  final List<String> _filters = [
    'All',
    'Gainers',
    'Losers',
    'IT',
    'Banking',
    'Energy',
    'Pharma',
  ];

  @override
  void initState() {
    super.initState();
    _allStocks = MockDataService.getMockStocks();
    _filteredStocks = _allStocks;
    _searchController.addListener(_filterStocks);
  }

  void _filterStocks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      var filtered = _allStocks.where((s) {
        final matchesSearch =
            s.symbol.toLowerCase().contains(query) ||
            s.name.toLowerCase().contains(query);
        final matchesFilter =
            _selectedFilter == 'All' ||
            (_selectedFilter == 'Gainers' && s.isGainer) ||
            (_selectedFilter == 'Losers' && !s.isGainer) ||
            s.sector == _selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();

      switch (_sortBy) {
        case 'Name':
          filtered.sort((a, b) => a.symbol.compareTo(b.symbol));
          break;
        case 'Price':
          filtered.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
          break;
        case '% Change':
          filtered.sort((a, b) => a.changePercent.compareTo(b.changePercent));
          break;
        case 'Market Cap':
          filtered.sort((a, b) => a.marketCap.compareTo(b.marketCap));
          break;
      }
      if (!_sortAsc) filtered = filtered.reversed.toList();
      _filteredStocks = filtered;
    });
  }

  Widget _buildIndex(String name, String value, String change, bool up) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: NexTradeColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          change,
          style: TextStyle(
            color: up ? NexTradeColors.profit : NexTradeColors.loss,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Market'),
            Text(
              'Live prices',
              style: TextStyle(fontSize: 11, color: NexTradeColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              color: NexTradeColors.textPrimary,
            ),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: NexCard(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIndex("NIFTY 50", "22,450", "+120 (0.54%)", true),
                  _buildIndex("SENSEX", "73,200", "-80 (0.10%)", false),
                  _buildIndex("BANK", "48,900", "+300 (0.61%)", true),
                ],
              ),
            ).animate().fadeIn(),
          ),
          // Search
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: NexTradeColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: NexTradeColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: NexTradeColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: NexTradeColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: "Search stocks (e.g. RELIANCE)",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _filterStocks();
                    },
                  ),
              ],
            ),
          ),

          // Filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final filter = _filters[i];
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedFilter = filter);
                    _filterStocks();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? NexTradeColors.primary
                          : NexTradeColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? NexTradeColors.primary
                            : NexTradeColors.border,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? NexTradeColors.background
                            : NexTradeColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Stock',
                    style: TextStyle(
                      color: NexTradeColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 50,
                  child: Text(
                    'Chart',
                    style: TextStyle(
                      color: NexTradeColors.textMuted,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Price / Change',
                    style: const TextStyle(
                      color: NexTradeColors.textMuted,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: NexTradeColors.border, height: 1),
          const SizedBox(height: 10),

          // 🔥 SECTION HEADER (ADD HERE)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  "All Stocks",
                  style: TextStyle(
                    color: NexTradeColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  "${_filteredStocks.length} items",
                  style: const TextStyle(
                    color: NexTradeColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Stock list
          Expanded(
            child: _filteredStocks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: NexTradeColors.textMuted,
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No stocks found',
                          style: TextStyle(color: NexTradeColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _filteredStocks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      return _buildStockRow(
                        _filteredStocks[i],
                      ).animate().fadeIn(delay: Duration(milliseconds: i * 30));
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockRow(StockModel stock) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/stock-detail', arguments: stock),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: NexTradeColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NexTradeColors.border),
        ),
        child: Row(
          children: [
            // Stock info
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
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
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.symbol,
                          style: const TextStyle(
                            color: NexTradeColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          stock.sector,
                          style: const TextStyle(
                            color: NexTradeColors.textMuted,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sparkline
            SizedBox(
              width: 50,
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

            const SizedBox(width: 8),

            // Price info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stock.formattedPrice,
                    style: const TextStyle(
                      color: NexTradeColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
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
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    final sortOptions = ['Name', 'Price', '% Change', 'Market Cap'];
    showModalBottomSheet(
      context: context,
      backgroundColor: NexTradeColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(
                color: NexTradeColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ...sortOptions.map(
              (s) => ListTile(
                title: Text(
                  s,
                  style: const TextStyle(color: NexTradeColors.textPrimary),
                ),
                trailing: _sortBy == s
                    ? Icon(
                        _sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                        color: NexTradeColors.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    if (_sortBy == s) {
                      _sortAsc = !_sortAsc;
                    } else {
                      _sortBy = s;
                      _sortAsc = true;
                    }
                  });
                  _filterStocks();
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
