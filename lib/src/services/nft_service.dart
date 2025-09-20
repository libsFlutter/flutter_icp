import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/icp_config.dart';
import '../core/icp_exceptions.dart';
import '../models/icp_nft.dart';

/// Service for ICP NFT operations
class NftService {
  final ICPConfig _config;

  const NftService({
    required ICPConfig config,
  })  : _config = config;

  /// Get NFT by token ID
  Future<ICPNFT?> getNft(String tokenId) async {
    try {
      final response =
          await http.get(Uri.parse('${_config.networkUrl}/nft/$tokenId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ICPNFT.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ICPQueryException('Failed to get NFT: ${response.statusCode}');
      }
    } catch (e) {
      throw ICPQueryException('Error getting NFT: $e');
    }
  }

  /// Get NFTs owned by address
  Future<List<ICPNFT>> getOwnedNfts(String address) async {
    try {
      final response =
          await http.get(Uri.parse('${_config.networkUrl}/nfts/$address'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nfts = List<Map<String, dynamic>>.from(data['nfts']);
        return nfts.map((json) => ICPNFT.fromJson(json)).toList();
      } else {
        throw ICPQueryException(
            'Failed to get owned NFTs: ${response.statusCode}');
      }
    } catch (e) {
      throw ICPQueryException('Error getting owned NFTs: $e');
    }
  }

  /// Transfer NFT
  Future<String> transferNft({
    required String tokenId,
    required String to,
    String? memo,
  }) async {
    try {
      final body = {
        'tokenId': tokenId,
        'to': to,
        if (memo != null) 'memo': memo,
      };

      final response = await http.post(
        Uri.parse('${_config.networkUrl}/nft/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['transactionId'] as String;
      } else {
        throw ICPTransactionException(
            'Failed to transfer NFT: ${response.statusCode}');
      }
    } catch (e) {
      throw ICPTransactionException('Error transferring NFT: $e');
    }
  }

  /// Mint new NFT
  Future<ICPNFT> mintNft({
    required String to,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final body = {
        'to': to,
        'metadata': metadata,
      };

      final response = await http.post(
        Uri.parse('${_config.networkUrl}/nft/mint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ICPNFT.fromJson(data);
      } else {
        throw ICPTransactionException(
            'Failed to mint NFT: ${response.statusCode}');
      }
    } catch (e) {
      throw ICPTransactionException('Error minting NFT: $e');
    }
  }
}
