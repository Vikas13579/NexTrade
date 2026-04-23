import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:nextrade/hive_service.dart';
import '../model.dart';
import 'market_store.dart';

class MarketSimulator {
  static Timer? _timer;

  static void start(VoidCallback onUpdate) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      for (var stock in MarketStore.stocks) {
        _updateStock(stock);
      }

      // sync holdings
      final holdings = HiveService.holdingsBox.values.toList();

      for (var h in holdings) {
        final stock = MarketStore.stocks.firstWhere(
              (s) => s.symbol == h.symbol,
          orElse: () => MarketStore.stocks.first,
        );

        h.currentPrice = stock.currentPrice;
        h.save();
      }

      onUpdate();
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static void _updateStock(StockModel stock) {
    final rand = Random();

    final volatility = (stock.symbol.hashCode % 5 == 0)
        ? stock.currentPrice * 0.005
        : stock.currentPrice * 0.002;

    final delta = (rand.nextDouble() - 0.5) * volatility;

    stock.currentPrice += delta;
    stock.currentPrice = stock.currentPrice.clamp(1, double.infinity);

    if (stock.currentPrice > stock.highPrice) {
      stock.highPrice = stock.currentPrice;
    }

    if (stock.currentPrice < stock.lowPrice) {
      stock.lowPrice = stock.currentPrice;
    }

    stock.volume += rand.nextDouble() * 1000;

    if (stock.sparklineData.length > 20) {
      stock.sparklineData = [
        ...stock.sparklineData.sublist(1),
        stock.currentPrice,
      ];
    } else {
      stock.sparklineData.add(stock.currentPrice);
    }
  }
}