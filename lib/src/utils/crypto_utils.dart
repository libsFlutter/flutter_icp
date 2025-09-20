import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;

/// Cryptographic utility functions for ICP operations
class CryptoUtils {
  /// Generate SHA-256 hash of input
  static String sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate SHA-256 hash of bytes
  static Uint8List sha256Bytes(Uint8List input) {
    final digest = crypto.sha256.convert(input);
    return Uint8List.fromList(digest.bytes);
  }

  /// Generate random bytes
  static Uint8List randomBytes(int length) {
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = (DateTime.now().millisecondsSinceEpoch + i) % 256;
    }
    return bytes;
  }

  /// Convert hex string to bytes
  static Uint8List hexToBytes(String hex) {
    final cleanHex = hex.replaceAll('0x', '');
    final result = Uint8List(cleanHex.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      final byte = int.parse(cleanHex.substring(i * 2, i * 2 + 2), radix: 16);
      result[i] = byte;
    }
    return result;
  }

  /// Convert bytes to hex string
  static String bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Generate deterministic seed from input
  static String generateSeed(String input) {
    final hash = sha256(input);
    return hash.substring(0, 32);
  }

  /// Validate signature format
  static bool isValidSignature(String signature) {
    // Basic signature validation for ICP
    return signature.length >= 64 &&
        RegExp(r'^[a-fA-F0-9]+$').hasMatch(signature);
  }

  /// Generate message hash for signing
  static String generateMessageHash(String message) {
    final encoded = utf8.encode(message);
    final digest = crypto.sha256.convert(encoded);
    return digest.toString();
  }
}
