// lib/presentation/screens/watchlist/watchlist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nextrade/widgets.dart';

import 'app_theme.dart';
import 'data_service.dart';
import 'model.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<WatchlistModel> _watchlists = [
    WatchlistModel(
      id: 'wl1',
      name: 'My Watchlist',
      symbols: ['RELIANCE', 'TCS', 'ICICIBANK', 'BAJFINANCE', 'SUNPHARMA'],
      createdAt: DateTime.now(),
    ),
    WatchlistModel(
      id: 'wl2',
      name: 'IT Stocks',
      symbols: ['TCS', 'INFY', 'WIPRO'],
      createdAt: DateTime.now(),
    ),
  ];

  int _selectedWatchlist = 0;

  List<StockModel> get _watchlistStocks {
    final allStocks = MockDataService.getMockStocks();
    final symbols = _watchlists[_selectedWatchlist].symbols;
    return allStocks.where((s) => symbols.contains(s.symbol)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: NexTradeColors.primary),
            onPressed: _createWatchlist,
          ),
        ],
      ),
      body: Column(
        children: [
          // Watchlist tabs
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _watchlists.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                if (i == _watchlists.length) {
                  return GestureDetector(
                    onTap: _createWatchlist,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: NexTradeColors.border, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: NexTradeColors.textMuted, size: 16),
                          SizedBox(width: 4),
                          Text('New', style: TextStyle(color: NexTradeColors.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }
                final isSelected = _selectedWatchlist == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedWatchlist = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? NexTradeColors.primary : NexTradeColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? NexTradeColors.primary : NexTradeColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _watchlists[i].name,
                        style: TextStyle(
                          color: isSelected ? NexTradeColors.background : NexTradeColors.textSecondary,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Stock count info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_watchlistStocks.length} stocks',
                  style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '${_watchlistStocks.where((s) => s.isGainer).length} Gainers',
                  style: const TextStyle(color: NexTradeColors.profit, fontSize: 12),
                ),
                const Text(' · ', style: TextStyle(color: NexTradeColors.textMuted)),
                Text(
                  '${_watchlistStocks.where((s) => !s.isGainer).length} Losers',
                  style: const TextStyle(color: NexTradeColors.loss, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Stocks list
          Expanded(
            child: _watchlistStocks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_border_rounded,
                      color: NexTradeColors.textMuted, size: 64),
                  const SizedBox(height: 16),
                  const Text('No stocks in watchlist',
                      style: TextStyle(
                          color: NexTradeColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Add stocks to track them here',
                      style: TextStyle(color: NexTradeColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 20),
                  NexButton(
                    text: 'Browse Market',
                    width: 160,
                    onPressed: () => Navigator.pushNamed(context, '/market'),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _watchlistStocks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                return _buildWatchlistTile(_watchlistStocks[i], i)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: i * 50));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistTile(StockModel stock, int index) {
    return Dismissible(
      key: Key(stock.symbol),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          _watchlists[_selectedWatchlist].symbols.remove(stock.symbol);
        });
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: NexTradeColors.lossBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: NexTradeColors.loss),
      ),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/stock-detail', arguments: stock),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                        color: NexTradeColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.symbol,
                        style: const TextStyle(
                            color: NexTradeColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    Text(stock.name,
                        style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              SizedBox(
                width: 55,
                height: 30,
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
                        color: stock.isGainer ? NexTradeColors.profit : NexTradeColors.loss,
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
                  Text(stock.formattedPrice,
                      style: const TextStyle(
                          color: NexTradeColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const SizedBox(height: 3),
                  PriceChangeBadge(
                      change: stock.change,
                      changePercent: stock.changePercent,
                      compact: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createWatchlist() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexTradeColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Watchlist', style: TextStyle(color: NexTradeColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: NexTradeColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Watchlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: NexTradeColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _watchlists.add(WatchlistModel(
                    id: 'wl${_watchlists.length + 1}',
                    name: controller.text,
                    symbols: [],
                    createdAt: DateTime.now(),
                  ));
                  _selectedWatchlist = _watchlists.length - 1;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}