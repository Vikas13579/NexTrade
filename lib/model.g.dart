// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockModelAdapter extends TypeAdapter<StockModel> {
  @override
  final int typeId = 0;

  @override
  StockModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockModel(
      symbol: fields[0] as String,
      name: fields[1] as String,
      exchange: fields[2] as String,
      currentPrice: fields[3] as double,
      previousClose: fields[4] as double,
      openPrice: fields[5] as double,
      highPrice: fields[6] as double,
      lowPrice: fields[7] as double,
      volume: fields[8] as double,
      marketCap: fields[9] as double,
      sector: fields[10] as String,
      isWatchlisted: fields[11] as bool,
      sparklineData: (fields[12] as List).cast<double>(),
      logoUrl: fields[13] as String,
      weekHigh52: fields[14] as double,
      weekLow52: fields[15] as double,
      peRatio: fields[16] as double,
      dividendYield: fields[17] as double,
    );
  }

  @override
  void write(BinaryWriter writer, StockModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.exchange)
      ..writeByte(3)
      ..write(obj.currentPrice)
      ..writeByte(4)
      ..write(obj.previousClose)
      ..writeByte(5)
      ..write(obj.openPrice)
      ..writeByte(6)
      ..write(obj.highPrice)
      ..writeByte(7)
      ..write(obj.lowPrice)
      ..writeByte(8)
      ..write(obj.volume)
      ..writeByte(9)
      ..write(obj.marketCap)
      ..writeByte(10)
      ..write(obj.sector)
      ..writeByte(11)
      ..write(obj.isWatchlisted)
      ..writeByte(12)
      ..write(obj.sparklineData)
      ..writeByte(13)
      ..write(obj.logoUrl)
      ..writeByte(14)
      ..write(obj.weekHigh52)
      ..writeByte(15)
      ..write(obj.weekLow52)
      ..writeByte(16)
      ..write(obj.peRatio)
      ..writeByte(17)
      ..write(obj.dividendYield);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      availableBalance: fields[4] as double,
      totalInvested: fields[5] as double,
      portfolioValue: fields[6] as double,
      panNumber: fields[7] as String,
      isKycVerified: fields[8] as bool,
      isBiometricEnabled: fields[9] as bool,
      profileImageUrl: fields[10] as String,
      joinedAt: fields[11] as DateTime,
      accountType: fields[12] as String,
      dematAccountId: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.availableBalance)
      ..writeByte(5)
      ..write(obj.totalInvested)
      ..writeByte(6)
      ..write(obj.portfolioValue)
      ..writeByte(7)
      ..write(obj.panNumber)
      ..writeByte(8)
      ..write(obj.isKycVerified)
      ..writeByte(9)
      ..write(obj.isBiometricEnabled)
      ..writeByte(10)
      ..write(obj.profileImageUrl)
      ..writeByte(11)
      ..write(obj.joinedAt)
      ..writeByte(12)
      ..write(obj.accountType)
      ..writeByte(13)
      ..write(obj.dematAccountId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HoldingModelAdapter extends TypeAdapter<HoldingModel> {
  @override
  final int typeId = 2;

  @override
  HoldingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HoldingModel(
      symbol: fields[0] as String,
      name: fields[1] as String,
      quantity: fields[2] as int,
      averagePrice: fields[3] as double,
      currentPrice: fields[4] as double,
      logoUrl: fields[5] as String,
      sector: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HoldingModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.averagePrice)
      ..writeByte(4)
      ..write(obj.currentPrice)
      ..writeByte(5)
      ..write(obj.logoUrl)
      ..writeByte(6)
      ..write(obj.sector);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HoldingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 3;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      id: fields[0] as String,
      symbol: fields[1] as String,
      name: fields[2] as String,
      orderType: fields[3] as String,
      productType: fields[4] as String,
      priceType: fields[5] as String,
      quantity: fields[6] as int,
      price: fields[7] as double,
      triggerPrice: fields[8] as double,
      status: fields[9] as String,
      createdAt: fields[10] as DateTime,
      executedAt: fields[11] as DateTime?,
      executedPrice: fields[12] as double,
      logoUrl: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.orderType)
      ..writeByte(4)
      ..write(obj.productType)
      ..writeByte(5)
      ..write(obj.priceType)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.price)
      ..writeByte(8)
      ..write(obj.triggerPrice)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.executedAt)
      ..writeByte(12)
      ..write(obj.executedPrice)
      ..writeByte(13)
      ..write(obj.logoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchlistModelAdapter extends TypeAdapter<WatchlistModel> {
  @override
  final int typeId = 4;

  @override
  WatchlistModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchlistModel(
      id: fields[0] as String,
      name: fields[1] as String,
      symbols: (fields[2] as List).cast<String>(),
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WatchlistModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.symbols)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchlistModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 5;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String,
      type: fields[1] as String,
      amount: fields[2] as double,
      description: fields[3] as String,
      date: fields[4] as DateTime,
      stockSymbol: fields[5] as String?,
      status: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.stockSymbol)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
