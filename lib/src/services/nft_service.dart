import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/icp_client.dart';
import '../core/icp_config.dart';
import '../core/icp_exceptions.dart';
import '../models/icp_nft.dart';

/// Service for ICP NFT operations
class NftService {
  final IcpClient _client;
  final IcpConfig _config;

  const NftService({
    required IcpClient client,
    required IcpConfig config,
  })  : _client = client,
        _config = config;

  /// Get NFT by token ID
  Future<IcpNft?> getNft(String tokenId) async {
    try {
      final response = await _client.get('/nft/$tokenId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return IcpNft.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw IcpException('Failed to get NFT: ${response.statusCode}');
      }
    } catch (e) {
      throw IcpException('Error getting NFT: $e');
    }
  }

  /// Get NFTs owned by address
  Future<List<IcpNft>> getOwnedNfts(String address) async {
    try {
      final response = await _client.get('/nfts/$address');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nfts = List<Map<String, dynamic>>.from(data['nfts']);
        return nfts.map((json) => IcpNft.fromJson(json)).toList();
      } else {
        throw IcpException('Failed to get owned NFTs: ${response.statusCode}');
      }
    } catch (e) {
      throw IcpException('Error getting owned NFTs: $e');
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

      final response =
          await _client.post('/nft/transfer', body: jsonEncode(body));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['transactionId'] as String;
      } else {
        throw IcpException('Failed to transfer NFT: ${response.statusCode}');
      }
    } catch (e) {
      throw IcpException('Error transferring NFT: $e');
    }
  }

  /// Mint new NFT
  Future<IcpNft> mintNft({
    required String to,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final body = {
        'to': to,
        'metadata': metadata,
      };

      final response = await _client.post('/nft/mint', body: jsonEncode(body));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return IcpNft.fromJson(data);
      } else {
        throw IcpException('Failed to mint NFT: ${response.statusCode}');
      }
    } catch (e) {
      throw IcpException('Error minting NFT: $e');
    }
  }
}
