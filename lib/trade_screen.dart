// lib/presentation/screens/trade/trade_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nextrade/widgets.dart';

import 'app_theme.dart';
import 'model.dart';

class TradeBottomSheet extends StatefulWidget {
  final StockModel stock;
  final String initialType;

  const TradeBottomSheet({
    super.key,
    required this.stock,
    required this.initialType,
  });

  @override
  State<TradeBottomSheet> createState() => _TradeBottomSheetState();
}

class _TradeBottomSheetState extends State<TradeBottomSheet> {
  late String _orderType; // BUY or SELL
  String _productType = 'CNC'; // CNC or MIS
  String _priceType = 'MARKET'; // MARKET, LIMIT, SL, SL-M
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _slPriceController = TextEditingController();
  bool _isLoading = false;

  final List<String> _priceTypes = ['MARKET', 'LIMIT', 'SL', 'SL-M'];

  @override
  void initState() {
    super.initState();
    _orderType = widget.initialType;
    _priceController.text = widget.stock.currentPrice.toStringAsFixed(2);
    _slPriceController.text = (widget.stock.currentPrice * 0.97).toStringAsFixed(2);
  }

  double get _quantity => double.tryParse(_quantityController.text) ?? 1;
  double get _price {
    if (_priceType == 'MARKET') return widget.stock.currentPrice;
    return double.tryParse(_priceController.text) ?? widget.stock.currentPrice;
  }

  double get _totalValue => _quantity * _price;
  double get _brokerage => _totalValue * 0.0003; // 0.03%
  double get _taxes => _totalValue * 0.0018; // 0.18% approx
  double get _netAmount => _totalValue + _brokerage + _taxes;

  bool get isBuy => _orderType == 'BUY';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NexTradeColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: NexTradeColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.stock.symbol,
                        style: const TextStyle(
                          color: NexTradeColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.stock.formattedPrice,
                        style: TextStyle(
                          color: widget.stock.isGainer
                              ? NexTradeColors.profit
                              : NexTradeColors.loss,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // BUY/SELL toggle
                  Container(
                    decoration: BoxDecoration(
                      color: NexTradeColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: ['BUY', 'SELL'].map((type) {
                        final isSelected = _orderType == type;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _orderType = type);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (type == 'BUY' ? NexTradeColors.profit : NexTradeColors.loss)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: isSelected
                                    ? NexTradeColors.background
                                    : NexTradeColors.textSecondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(color: NexTradeColors.border, height: 1),

            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                children: [
                  // Product type
                  Row(
                    children: ['CNC', 'MIS', 'CO', 'BO'].map((type) {
                      final isSelected = _productType == type;
                      return GestureDetector(
                        onTap: () => setState(() => _productType = type),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? NexTradeColors.primaryGlow : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? NexTradeColors.primary : NexTradeColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                type,
                                style: TextStyle(
                                  color: isSelected ? NexTradeColors.primary : NexTradeColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                type == 'CNC' ? 'Delivery' : type == 'MIS' ? 'Intraday' : type,
                                style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Price type tabs
                  Container(
                    decoration: BoxDecoration(
                      color: NexTradeColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: _priceTypes.map((type) {
                        final isSelected = _priceType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _priceType = type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? NexTradeColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                type,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? NexTradeColors.background
                                      : NexTradeColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quantity and Price
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'Qty',
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          label: _priceType == 'MARKET' ? 'Price (Market)' : 'Price',
                          controller: _priceController,
                          enabled: _priceType != 'MARKET',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  if (_priceType == 'SL' || _priceType == 'SL-M') ...[
                    const SizedBox(height: 12),
                    _buildInputField(
                      label: 'Trigger Price',
                      controller: _slPriceController,
                      keyboardType: TextInputType.number,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Order summary
                  NexCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildSummaryRow('Qty × Price', '${_quantity.toInt()} × ₹${_price.toStringAsFixed(2)}'),
                        _buildSummaryRow('Sub Total', '₹${_totalValue.toStringAsFixed(2)}'),
                        _buildSummaryRow('Brokerage', '₹${_brokerage.toStringAsFixed(2)}'),
                        _buildSummaryRow('Taxes & Charges', '₹${_taxes.toStringAsFixed(2)}'),
                        const Divider(color: NexTradeColors.border),
                        _buildSummaryRow(
                          isBuy ? 'Total (to pay)' : 'Total (to receive)',
                          '₹${_netAmount.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Available balance
                  if (isBuy)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NexTradeColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available Balance',
                              style: TextStyle(color: NexTradeColors.textMuted, fontSize: 12)),
                          Text(
                            '₹21,374.60',
                            style: TextStyle(
                              color: _netAmount > 21374.60
                                  ? NexTradeColors.loss
                                  : NexTradeColors.profit,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Place order button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isBuy ? NexTradeColors.profit : NexTradeColors.loss,
                        foregroundColor: NexTradeColors.background,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                          : Text(
                        '${_orderType} ${_productType} Order',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: NexTradeColors.textMuted, fontSize: 11)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: NexTradeColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            fillColor: enabled ? NexTradeColors.surface : NexTradeColors.surfaceHighlight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: NexTradeColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: NexTradeColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isBuy ? NexTradeColors.profit : NexTradeColors.loss,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? NexTradeColors.textPrimary : NexTradeColors.textMuted,
              fontSize: isTotal ? 13 : 12,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal
                  ? (isBuy ? NexTradeColors.loss : NexTradeColors.profit)
                  : NexTradeColors.textSecondary,
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isBuy ? Icons.check_circle : Icons.check_circle,
                color: isBuy ? NexTradeColors.profit : NexTradeColors.loss,
              ),
              const SizedBox(width: 10),
              Text(
                '$_orderType order placed for ${_quantity.toInt()} ${widget.stock.symbol}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: NexTradeColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}