/// Utility functions for ICP operations
class IcpUtils {
  /// Validate ICP address format
  static bool isValidAddress(String address) {
    // Basic ICP address validation
    // ICP addresses are typically 64 characters long and contain only alphanumeric characters
    if (address.length != 64) return false;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(address);
  }

  /// Convert ICP tokens to e8s (smallest unit)
  static BigInt icpToE8s(double icp) {
    return BigInt.from((icp * 100000000).round());
  }

  /// Convert e8s to ICP tokens
  static double e8sToIcp(BigInt e8s) {
    return e8s.toDouble() / 100000000;
  }

  /// Format ICP amount for display
  static String formatIcp(double amount, {int decimals = 4}) {
    return amount.toStringAsFixed(decimals);
  }

  /// Generate a random transaction ID
  static String generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return random.padLeft(20, '0');
  }

  /// Parse transaction ID from response
  static String? parseTransactionId(Map<String, dynamic> response) {
    return response['transactionId'] as String?;
  }

  /// Check if response indicates success
  static bool isSuccessResponse(Map<String, dynamic> response) {
    return response['status'] == 'success' || response['success'] == true;
  }

  /// Extract error message from response
  static String? getErrorMessage(Map<String, dynamic> response) {
    return response['error'] as String? ?? response['message'] as String?;
  }
}
