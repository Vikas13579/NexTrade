// lib/data/models/stock_model.dart
import 'package:hive/hive.dart';
part 'model.g.dart';

@HiveType(typeId: 0)
class StockModel extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String exchange;

  @HiveField(3)
  double currentPrice;

  @HiveField(4)
  double previousClose;

  @HiveField(5)
  double openPrice;

  @HiveField(6)
  double highPrice;

  @HiveField(7)
  double lowPrice;

  @HiveField(8)
  double volume;

  @HiveField(9)
  double marketCap;

  @HiveField(10)
  String sector;

  @HiveField(11)
  bool isWatchlisted;

  @HiveField(12)
  List<double> sparklineData;

  @HiveField(13)
  String logoUrl;

  @HiveField(14)
  double weekHigh52;

  @HiveField(15)
  double weekLow52;

  @HiveField(16)
  double peRatio;

  @HiveField(17)
  double dividendYield;

  StockModel({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.currentPrice,
    required this.previousClose,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.marketCap,
    required this.sector,
    this.isWatchlisted = false,
    required this.sparklineData,
    this.logoUrl = '',
    required this.weekHigh52,
    required this.weekLow52,
    required this.peRatio,
    required this.dividendYield,
  });

  double get change => currentPrice - previousClose;
  double get changePercent => ((currentPrice - previousClose) / previousClose) * 100;
  bool get isGainer => change >= 0;

  String get formattedPrice => '₹${currentPrice.toStringAsFixed(2)}';
  String get formattedChange =>
      '${isGainer ? '+' : ''}${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)';

  String get formattedMarketCap {
    if (marketCap >= 1e12) return '₹${(marketCap / 1e12).toStringAsFixed(2)}T';
    if (marketCap >= 1e9) return '₹${(marketCap / 1e9).toStringAsFixed(2)}B';
    if (marketCap >= 1e6) return '₹${(marketCap / 1e6).toStringAsFixed(2)}M';
    return '₹${marketCap.toStringAsFixed(0)}';
  }

  StockModel copyWith({
    double? currentPrice,
    bool? isWatchlisted,
    List<double>? sparklineData,
  }) {
    return StockModel(
      symbol: symbol,
      name: name,
      exchange: exchange,
      currentPrice: currentPrice ?? this.currentPrice,
      previousClose: previousClose,
      openPrice: openPrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      volume: volume,
      marketCap: marketCap,
      sector: sector,
      isWatchlisted: isWatchlisted ?? this.isWatchlisted,
      sparklineData: sparklineData ?? this.sparklineData,
      logoUrl: logoUrl,
      weekHigh52: weekHigh52,
      weekLow52: weekLow52,
      peRatio: peRatio,
      dividendYield: dividendYield,
    );
  }
}

// lib/data/models/user_model.dart
@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String phone;

  @HiveField(4)
  double availableBalance;

  @HiveField(5)
  double totalInvested;

  @HiveField(6)
  double portfolioValue;

  @HiveField(7)
  String panNumber;

  @HiveField(8)
  bool isKycVerified;

  @HiveField(9)
  bool isBiometricEnabled;

  @HiveField(10)
  String profileImageUrl;

  @HiveField(11)
  DateTime joinedAt;

  @HiveField(12)
  String accountType; // 'individual', 'joint', 'corporate'

  @HiveField(13)
  String dematAccountId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.availableBalance,
    required this.totalInvested,
    required this.portfolioValue,
    this.panNumber = '',
    this.isKycVerified = false,
    this.isBiometricEnabled = false,
    this.profileImageUrl = '',
    required this.joinedAt,
    this.accountType = 'individual',
    this.dematAccountId = '',
  });

  double get totalPnL => portfolioValue - totalInvested;
  double get totalPnLPercent => totalInvested > 0 ? (totalPnL / totalInvested) * 100 : 0;
  bool get isProfitable => totalPnL >= 0;
}

// lib/data/models/holding_model.dart
@HiveType(typeId: 2)
class HoldingModel extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String name;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double averagePrice;

  @HiveField(4)
  double currentPrice;

  @HiveField(5)
  String logoUrl;

  @HiveField(6)
  String sector;

  HoldingModel({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    this.logoUrl = '',
    this.sector = '',
  });

  double get investedAmount => quantity * averagePrice;
  double get currentValue => quantity * currentPrice;
  double get pnl => currentValue - investedAmount;
  double get pnlPercent => (pnl / investedAmount) * 100;
  bool get isProfitable => pnl >= 0;
}

// lib/data/models/order_model.dart
@HiveType(typeId: 3)
class OrderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String symbol;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String orderType; // 'BUY' or 'SELL'

  @HiveField(4)
  final String productType; // 'MIS' (Intraday), 'CNC' (Delivery)

  @HiveField(5)
  final String priceType; // 'MARKET', 'LIMIT', 'SL', 'SL-M'

  @HiveField(6)
  final int quantity;

  @HiveField(7)
  final double price;

  @HiveField(8)
  final double triggerPrice;

  @HiveField(9)
  String status; // 'PENDING', 'EXECUTED', 'CANCELLED', 'REJECTED'

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  DateTime? executedAt;

  @HiveField(12)
  double executedPrice;

  @HiveField(13)
  String logoUrl;

  OrderModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.orderType,
    required this.productType,
    required this.priceType,
    required this.quantity,
    required this.price,
    this.triggerPrice = 0,
    required this.status,
    required this.createdAt,
    this.executedAt,
    this.executedPrice = 0,
    this.logoUrl = '',
  });

  double get totalValue => quantity * (executedPrice > 0 ? executedPrice : price);
}

// lib/data/models/watchlist_model.dart
@HiveType(typeId: 4)
class WatchlistModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> symbols;

  @HiveField(3)
  DateTime createdAt;

  WatchlistModel({
    required this.id,
    required this.name,
    required this.symbols,
    required this.createdAt,
  });
}

// lib/data/models/transaction_model.dart
@HiveType(typeId: 5)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 'CREDIT', 'DEBIT', 'BUY', 'SELL', 'DIVIDEND'

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? stockSymbol;

  @HiveField(6)
  String status; // 'COMPLETED', 'PENDING', 'FAILED'

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.stockSymbol,
    this.status = 'COMPLETED',
  });

  bool get isCredit => type == 'CREDIT' || type == 'SELL' || type == 'DIVIDEND';
}