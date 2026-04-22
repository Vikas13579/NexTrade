import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'model.dart';

class TradeBottomSheet extends StatefulWidget {
  final StockModel stock;
  final String initialType; // 'BUY' or 'SELL'

  const TradeBottomSheet({
    super.key,
    required this.stock,
    required this.initialType,
  });

  @override
  State<TradeBottomSheet> createState() => _TradeBottomSheetState();
}

class _TradeBottomSheetState extends State<TradeBottomSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    // Making the sheet wrap its content and handle keyboard padding
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      decoration: const BoxDecoration(
        color: NexTradeColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Essential for BottomSheets
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.initialType} ${widget.stock.symbol}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: NexTradeColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: NexTradeColors.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: NexTradeColors.border),
          const SizedBox(height: 20),

          // Simple Quantity Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Quantity", style: TextStyle(color: NexTradeColors.textSecondary)),
              Row(
                children: [
                  _qtyButton(Icons.remove, () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  _qtyButton(Icons.add, () => setState(() => _quantity++)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle the logic (e.g., call an API)
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order placed for $_quantity shares')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.initialType == 'BUY'
                    ? NexTradeColors.profit
                    : NexTradeColors.loss,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('CONFIRM ${widget.initialType}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: NexTradeColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: NexTradeColors.primary),
      ),
    );
  }
}