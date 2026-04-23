// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:fl_chart/fl_chart.dart';
// //
// // import 'package:nextrade/widgets.dart';
// //
// // import 'app_theme.dart';
// // import 'market_store.dart';
// // import 'model.dart';
// //
// // class MarketScreen extends StatefulWidget {
// //   const MarketScreen({super.key, String? initialFilter});
// //
// //   @override
// //   State<MarketScreen> createState() => _MarketScreenState();
// // }
// //
// // class _MarketScreenState extends State<MarketScreen> {
// //   final TextEditingController _searchController = TextEditingController();
// //
// //   List<StockModel> _allStocks = [];
// //   List<StockModel> _filteredStocks = [];
// //
// //   String _selectedFilter = 'All';
// //   String _sortBy = '% Change';
// //
// //   Timer? _refreshTimer;
// //
// //   final List<String> _filters = [
// //     'All',
// //     'Gainers',
// //     'Losers',
// //     'IT',
// //     'Banking',
// //     'Energy',
// //     'Pharma',
// //   ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     _allStocks = MarketStore.stocks;
// //     _filteredStocks = _allStocks;
// //
// //     _searchController.addListener(_filterStocks);
// //
// //     // 🔥 ONLY UI REFRESH (NOT SIMULATION)
// //     _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
// //       if (mounted) {
// //         setState(() {
// //           _filterStocks();
// //         });
// //       }
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _refreshTimer?.cancel();
// //     _searchController.dispose();
// //     super.dispose();
// //   }
// //
// //   void _filterStocks() {
// //     final query = _searchController.text.toLowerCase();
// //
// //     var filtered = _allStocks.where((s) {
// //       final matchesSearch =
// //           s.symbol.toLowerCase().contains(query) ||
// //               s.name.toLowerCase().contains(query);
// //
// //       final matchesFilter =
// //           _selectedFilter == 'All' ||
// //               (_selectedFilter == 'Gainers' && s.isGainer) ||
// //               (_selectedFilter == 'Losers' && !s.isGainer) ||
// //               s.sector == _selectedFilter;
// //
// //       return matchesSearch && matchesFilter;
// //     }).toList();
// //
// //     // 🔥 SORT
// //     switch (_sortBy) {
// //       case '% Change':
// //         filtered.sort((a, b) => b.changePercent.compareTo(a.changePercent));
// //         break;
// //       case 'Price':
// //         filtered.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
// //         break;
// //       case 'Name':
// //         filtered.sort((a, b) => a.symbol.compareTo(b.symbol));
// //         break;
// //     }
// //
// //     _filteredStocks = filtered;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: NexTradeColors.background,
// //       appBar: AppBar(title: const Text("Market")),
// //       body: Column(
// //         children: [
// //           _buildSearch(),
// //           _buildFilters(),
// //
// //           Expanded(
// //             child: ListView.builder(
// //               itemCount: _filteredStocks.length,
// //               itemBuilder: (context, i) {
// //                 return _buildStockRow(_filteredStocks[i]);
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSearch() {
// //     return Padding(
// //       padding: const EdgeInsets.all(12),
// //       child: TextField(
// //         controller: _searchController,
// //         decoration: const InputDecoration(
// //           hintText: "Search stocks...",
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFilters() {
// //     return SizedBox(
// //       height: 40,
// //       child: ListView.builder(
// //         scrollDirection: Axis.horizontal,
// //         itemCount: _filters.length,
// //         itemBuilder: (context, i) {
// //           final filter = _filters[i];
// //
// //           return GestureDetector(
// //             onTap: () {
// //               setState(() {
// //                 _selectedFilter = filter;
// //                 _filterStocks();
// //               });
// //             },
// //             child: Container(
// //               margin: const EdgeInsets.symmetric(horizontal: 6),
// //               padding: const EdgeInsets.symmetric(horizontal: 14),
// //               decoration: BoxDecoration(
// //                 color: _selectedFilter == filter
// //                     ? NexTradeColors.primary
// //                     : NexTradeColors.surface,
// //                 borderRadius: BorderRadius.circular(20),
// //               ),
// //               child: Center(child: Text(filter)),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStockRow(StockModel stock) {
// //     return ListTile(
// //       title: Text(stock.symbol),
// //       subtitle: Text(stock.name),
// //       trailing: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Text(stock.formattedPrice),
// //           PriceChangeBadge(
// //             change: stock.change,
// //             changePercent: stock.changePercent,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// // lib/presentation/screens/market/market_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:nextrade/widgets.dart';
//
// import 'app_theme.dart';
// import 'data_service.dart';
// import 'model.dart';
//
// class MarketScreen extends StatefulWidget {
//   const MarketScreen({super.key, String? initialFilter});
//
//   @override
//   State<MarketScreen> createState() => _MarketScreenState();
// }
//
// class _MarketScreenState extends State<MarketScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<StockModel> _allStocks = [];
//   List<StockModel> _filteredStocks = [];
//   String _selectedFilter = 'All';
//   String _sortBy = 'Name';
//   bool _sortAsc = true;
//
//   final List<String> _filters = [
//     'All',
//     'Gainers',
//     'Losers',
//     'IT',
//     'Banking',
//     'Energy',
//     'Pharma',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _allStocks = MockDataService.getMockStocks();
//     _filteredStocks = _allStocks;
//     _searchController.addListener(_filterStocks);
//   }
//
//   void _filterStocks() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       var filtered = _allStocks.where((s) {
//         final matchesSearch =
//             s.symbol.toLowerCase().contains(query) ||
//                 s.name.toLowerCase().contains(query);
//         final matchesFilter =
//             _selectedFilter == 'All' ||
//                 (_selectedFilter == 'Gainers' && s.isGainer) ||
//                 (_selectedFilter == 'Losers' && !s.isGainer) ||
//                 s.sector == _selectedFilter;
//         return matchesSearch && matchesFilter;
//       }).toList();
//
//       switch (_sortBy) {
//         case 'Name':
//           filtered.sort((a, b) => a.symbol.compareTo(b.symbol));
//           break;
//         case 'Price':
//           filtered.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
//           break;
//         case '% Change':
//           filtered.sort((a, b) => a.changePercent.compareTo(b.changePercent));
//           break;
//         case 'Market Cap':
//           filtered.sort((a, b) => a.marketCap.compareTo(b.marketCap));
//           break;
//       }
//       if (!_sortAsc) filtered = filtered.reversed.toList();
//       _filteredStocks = filtered;
//     });
//   }
//
//   Widget _buildIndex(String name, String value, String change, bool up) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           name,
//           style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 11),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             color: NexTradeColors.textPrimary,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         Text(
//           change,
//           style: TextStyle(
//             color: up ? NexTradeColors.profit : NexTradeColors.loss,
//             fontSize: 11,
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: NexTradeColors.background,
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text('Market'),
//             Text(
//               'Live prices',
//               style: TextStyle(fontSize: 11, color: NexTradeColors.textMuted),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.tune_rounded,
//               color: NexTradeColors.textPrimary,
//             ),
//             onPressed: _showSortOptions,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//             child: NexCard(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildIndex("NIFTY 50", "22,450", "+120 (0.54%)", true),
//                   _buildIndex("SENSEX", "73,200", "-80 (0.10%)", false),
//                   _buildIndex("BANK", "48,900", "+300 (0.61%)", true),
//                 ],
//               ),
//             ).animate().fadeIn(),
//           ),
//           // Search
//           Container(
//             margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: NexTradeColors.surface,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: NexTradeColors.border),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.search, color: NexTradeColors.textMuted),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     style: const TextStyle(color: NexTradeColors.textPrimary),
//                     decoration: const InputDecoration(
//                       hintText: "Search stocks (e.g. RELIANCE)",
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 if (_searchController.text.isNotEmpty)
//                   IconButton(
//                     icon: const Icon(Icons.close, size: 18),
//                     onPressed: () {
//                       _searchController.clear();
//                       _filterStocks();
//                     },
//                   ),
//               ],
//             ),
//           ),
//
//           // Filter chips
//           SizedBox(
//             height: 36,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: _filters.length,
//               separatorBuilder: (_, __) => const SizedBox(width: 8),
//               itemBuilder: (context, i) {
//                 final filter = _filters[i];
//                 final isSelected = _selectedFilter == filter;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() => _selectedFilter = filter);
//                     _filterStocks();
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 7,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? NexTradeColors.primary
//                           : NexTradeColors.surface,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: isSelected
//                             ? NexTradeColors.primary
//                             : NexTradeColors.border,
//                       ),
//                     ),
//                     child: Text(
//                       filter,
//                       style: TextStyle(
//                         color: isSelected
//                             ? NexTradeColors.background
//                             : NexTradeColors.textSecondary,
//                         fontSize: 12,
//                         fontWeight: isSelected
//                             ? FontWeight.w700
//                             : FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 12),
//
//           // Column headers
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Row(
//               children: [
//                 const Expanded(
//                   flex: 3,
//                   child: Text(
//                     'Stock',
//                     style: TextStyle(
//                       color: NexTradeColors.textMuted,
//                       fontSize: 11,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 50,
//                   child: Text(
//                     'Chart',
//                     style: TextStyle(
//                       color: NexTradeColors.textMuted,
//                       fontSize: 11,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Text(
//                     'Price / Change',
//                     style: const TextStyle(
//                       color: NexTradeColors.textMuted,
//                       fontSize: 11,
//                     ),
//                     textAlign: TextAlign.right,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(color: NexTradeColors.border, height: 1),
//           const SizedBox(height: 10),
//
//           // 🔥 SECTION HEADER (ADD HERE)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 const Text(
//                   "All Stocks",
//                   style: TextStyle(
//                     color: NexTradeColors.textPrimary,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   "${_filteredStocks.length} items",
//                   style: const TextStyle(
//                     color: NexTradeColors.textMuted,
//                     fontSize: 11,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Stock list
//           Expanded(
//             child: _filteredStocks.isEmpty
//                 ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.search_off,
//                     color: NexTradeColors.textMuted,
//                     size: 48,
//                   ),
//                   SizedBox(height: 12),
//                   Text(
//                     'No stocks found',
//                     style: TextStyle(color: NexTradeColors.textMuted),
//                   ),
//                 ],
//               ),
//             )
//                 : ListView.separated(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 8,
//               ),
//               itemCount: _filteredStocks.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 6),
//               itemBuilder: (context, i) {
//                 return _buildStockRow(
//                   _filteredStocks[i],
//                 ).animate().fadeIn(delay: Duration(milliseconds: i * 30));
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStockRow(StockModel stock) {
//     return GestureDetector(
//       onTap: () =>
//           Navigator.pushNamed(context, '/stock-detail', arguments: stock),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: NexTradeColors.surface,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: NexTradeColors.border),
//         ),
//         child: Row(
//           children: [
//             // Stock info
//             Expanded(
//               flex: 3,
//               child: Row(
//                 children: [
//                   Container(
//                     width: 38,
//                     height: 38,
//                     decoration: BoxDecoration(
//                       color: NexTradeColors.surfaceHighlight,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Center(
//                       child: Text(
//                         stock.symbol.substring(0, 2),
//                         style: const TextStyle(
//                           color: NexTradeColors.primary,
//                           fontWeight: FontWeight.w800,
//                           fontSize: 11,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           stock.symbol,
//                           style: const TextStyle(
//                             color: NexTradeColors.textPrimary,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 13,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         Text(
//                           stock.sector,
//                           style: const TextStyle(
//                             color: NexTradeColors.textMuted,
//                             fontSize: 10,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Sparkline
//             SizedBox(
//               width: 50,
//               height: 28,
//               child: LineChart(
//                 LineChartData(
//                   gridData: const FlGridData(show: false),
//                   titlesData: const FlTitlesData(show: false),
//                   borderData: FlBorderData(show: false),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: stock.sparklineData
//                           .asMap()
//                           .entries
//                           .map((e) => FlSpot(e.key.toDouble(), e.value))
//                           .toList(),
//                       isCurved: true,
//                       color: stock.isGainer
//                           ? NexTradeColors.profit
//                           : NexTradeColors.loss,
//                       barWidth: 1.5,
//                       dotData: const FlDotData(show: false),
//                     ),
//                   ],
//                   lineTouchData: const LineTouchData(enabled: false),
//                 ),
//               ),
//             ),
//
//             const SizedBox(width: 8),
//
//             // Price info
//             Expanded(
//               flex: 2,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     stock.formattedPrice,
//                     style: const TextStyle(
//                       color: NexTradeColors.textPrimary,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 13,
//                     ),
//                   ),
//                   const SizedBox(height: 3),
//                   PriceChangeBadge(
//                     change: stock.change,
//                     changePercent: stock.changePercent,
//                     compact: true,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showSortOptions() {
//     final sortOptions = ['Name', 'Price', '% Change', 'Market Cap'];
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: NexTradeColors.surface,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (ctx) => Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Sort By',
//               style: TextStyle(
//                 color: NexTradeColors.textPrimary,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 18,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ...sortOptions.map(
//                   (s) => ListTile(
//                 title: Text(
//                   s,
//                   style: const TextStyle(color: NexTradeColors.textPrimary),
//                 ),
//                 trailing: _sortBy == s
//                     ? Icon(
//                   _sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
//                   color: NexTradeColors.primary,
//                 )
//                     : null,
//                 onTap: () {
//                   setState(() {
//                     if (_sortBy == s) {
//                       _sortAsc = !_sortAsc;
//                     } else {
//                       _sortBy = s;
//                       _sortAsc = true;
//                     }
//                   });
//                   _filterStocks();
//                   Navigator.pop(ctx);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nextrade/widgets.dart';

import 'app_theme.dart';
import 'market_store.dart';
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
  Timer? _timer;

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

    _allStocks = MarketStore.stocks;
    _filteredStocks = _allStocks;

    _searchController.addListener(_filterStocks);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _filterStocks();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // 🔥 FILTER LOGIC
  void _filterStocks() {
    final query = _searchController.text.toLowerCase();

    _filteredStocks = _allStocks.where((s) {
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
  }

  // 🔥 INDEX CALCULATION
  Map<String, dynamic> _calculateIndex(List<StockModel> stocks) {
    if (stocks.isEmpty) {
      return {"value": 0, "change": 0, "percent": 0, "isUp": true};
    }

    double total = 0;
    double prev = 0;

    for (var s in stocks) {
      total += s.currentPrice;
      prev += s.previousClose;
    }

    final change = total - prev;
    final percent = (change / prev) * 100;

    return {
      "value": total / stocks.length,
      "change": change / stocks.length,
      "percent": percent,
      "isUp": change >= 0,
    };
  }

  Widget _buildIndex(String name, Map data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name,
            style: const TextStyle(
                color: NexTradeColors.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          data["value"].toStringAsFixed(0),
          style: const TextStyle(
              color: NexTradeColors.textPrimary,
              fontWeight: FontWeight.bold),
        ),
        Text(
          "${data["change"].toStringAsFixed(0)} (${data["percent"].toStringAsFixed(2)}%)",
          style: TextStyle(
            color: data["isUp"]
                ? NexTradeColors.profit
                : NexTradeColors.loss,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final nifty = _calculateIndex(_allStocks);
    final banking = _calculateIndex(
        _allStocks.where((e) => e.sector == "Banking").toList());
    final it = _calculateIndex(
        _allStocks.where((e) => e.sector == "IT").toList());

    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Market"),
            Text("Live prices", style: TextStyle(fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          // INDEX CARD
          Padding(
            padding: const EdgeInsets.all(16),
            child: NexCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIndex("NIFTY", nifty),
                  _buildIndex("BANK", banking),
                  _buildIndex("IT", it),
                ],
              ),
            ),
          ),

          // SEARCH
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: NexTradeColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search stocks"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // FILTERS
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
                final selected = _selectedFilter == f;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = f;
                      _filterStocks();
                    });
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? NexTradeColors.primary
                          : NexTradeColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: selected
                            ? NexTradeColors.background
                            : NexTradeColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Expanded(child: Text("Stock")),
                SizedBox(width: 60, child: Text("Chart")),
                Expanded(
                    child: Text("Price",
                        textAlign: TextAlign.end)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredStocks.length,
              itemBuilder: (_, i) {
                final stock = _filteredStocks[i];

                return _buildStockRow(stock)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: i * 30));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockRow(StockModel stock) {
    final isUp = stock.isGainer;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: NexTradeColors.surface,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: NexTradeColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(stock.symbol.substring(0, 2)),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock.symbol),
                Text(stock.sector,
                    style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),

          SizedBox(
            width: 60,
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
                        .map((e) =>
                        FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: isUp
                        ? NexTradeColors.profit
                        : NexTradeColors.loss,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(stock.formattedPrice),
              Text(
                "${isUp ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%",
                style: TextStyle(
                  color: isUp
                      ? NexTradeColors.profit
                      : NexTradeColors.loss,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}