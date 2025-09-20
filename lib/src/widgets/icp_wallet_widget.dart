import 'package:flutter/material.dart';

/// Widget for displaying ICP wallet information
class IcpWalletWidget extends StatefulWidget {
  /// Wallet address
  final String address;

  /// Wallet balance
  final double balance;

  /// Callback when wallet action is triggered
  final VoidCallback? onAction;

  const IcpWalletWidget({
    super.key,
    required this.address,
    required this.balance,
    this.onAction,
  });

  @override
  State<IcpWalletWidget> createState() => _IcpWalletWidgetState();
}

class _IcpWalletWidgetState extends State<IcpWalletWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ICP Wallet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${widget.address}',
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Balance: ${widget.balance.toStringAsFixed(4)} ICP',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.onAction != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: widget.onAction,
                child: const Text('Connect Wallet'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
