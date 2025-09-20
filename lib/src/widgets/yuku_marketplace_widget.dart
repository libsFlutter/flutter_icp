import 'package:flutter/material.dart';
import '../models/icp_listing.dart';

/// Widget for displaying Yuku marketplace listings
class YukuMarketplaceWidget extends StatelessWidget {
  /// The listing to display
  final IcpListing listing;

  /// Callback when listing is tapped
  final VoidCallback? onTap;

  /// Callback when buy button is pressed
  final VoidCallback? onBuy;

  const YukuMarketplaceWidget({
    super.key,
    required this.listing,
    this.onTap,
    this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Token: ${listing.tokenId}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(listing.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      listing.status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${listing.price.toStringAsFixed(4)} ${listing.currency}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (onBuy != null && listing.status == 'active')
                    ElevatedButton(
                      onPressed: onBuy,
                      child: const Text('Buy'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Seller: ${listing.seller}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'sold':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
