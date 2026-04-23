import '../model.dart';
import '../data_service.dart';

class MarketStore {
  static final List<StockModel> stocks =
  MockDataService.getMockStocks();

  static StockModel? getStock(String symbol) {
    try {
      return stocks.firstWhere((s) => s.symbol == symbol);
    } catch (_) {
      return null;
    }
  }
}