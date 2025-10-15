import 'package:flutter/material.dart';
import 'package:flutter_icp/flutter_icp.dart';
import 'package:flutter_icp/src/services/yuku_service.dart';
import 'package:flutter_icp/src/core/icp_client.dart';
import 'package:flutter_icp/src/core/icp_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize ICP configuration
  ICPConfig.instance.useTestnet();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ICP Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ICPDemoPage(),
    );
  }
}

class ICPDemoPage extends StatefulWidget {
  const ICPDemoPage({super.key});

  @override
  State<ICPDemoPage> createState() => _ICPDemoPageState();
}

class _ICPDemoPageState extends State<ICPDemoPage> {
  final ICPClient _icpClient = ICPClient.instance;
  final PlugWalletService _walletService = PlugWalletService();
  final YukuService _yukuService = YukuService();
  
  bool _isInitialized = false;
  bool _isWalletConnected = false;
  String _walletAddress = '';
  Map<String, double> _balances = {};
  List<Map<String, dynamic>> _nfts = [];
  List<YukuListing> _listings = [];
  String _status = 'Ready';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() => _status = 'Initializing ICP Client...');
      await _icpClient.initialize();
      
      setState(() => _status = 'Initializing Wallet Service...');
      await _walletService.initialize();
      
      setState(() => _status = 'Initializing Yuku Service...');
      await _yukuService.initialize();
      
      setState(() {
        _isInitialized = true;
        _status = 'Initialized successfully!';
      });
    } catch (e) {
      setState(() => _status = 'Initialization error: $e');
    }
  }

  Future<void> _connectWallet() async {
    try {
      setState(() => _status = 'Connecting to Plug Wallet...');
      
      final connected = await _walletService.connect();
      
      if (connected) {
        final address = _walletService.principalId ?? '';
        final balances = await _walletService.getBalance();
        
        setState(() {
          _isWalletConnected = true;
          _walletAddress = address;
          _balances = balances;
          _status = 'Wallet connected!';
        });
      } else {
        setState(() => _status = 'Failed to connect wallet');
      }
    } catch (e) {
      setState(() => _status = 'Wallet connection error: $e');
    }
  }

  Future<void> _disconnectWallet() async {
    try {
      await _walletService.disconnect();
      
      setState(() {
        _isWalletConnected = false;
        _walletAddress = '';
        _balances = {};
        _nfts = [];
        _status = 'Wallet disconnected';
      });
    } catch (e) {
      setState(() => _status = 'Disconnect error: $e');
    }
  }

  Future<void> _loadNFTs() async {
    if (!_isWalletConnected) {
      setState(() => _status = 'Please connect wallet first');
      return;
    }

    try {
      setState(() => _status = 'Loading NFTs...');
      
      // Use wallet service to get NFTs
      final nfts = await _walletService.getNFTBalances();
      
      setState(() {
        _nfts = nfts;
        _status = 'Loaded ${nfts.length} NFTs';
      });
    } catch (e) {
      setState(() => _status = 'Error loading NFTs: $e');
    }
  }

  Future<void> _loadMarketplace() async {
    try {
      setState(() => _status = 'Loading marketplace listings...');
      
      final listings = await _yukuService.getActiveListings();
      
      setState(() {
        _listings = listings;
        _status = 'Loaded ${listings.length} listings';
      });
    } catch (e) {
      setState(() => _status = 'Error loading listings: $e');
    }
  }

  Future<void> _sendTransaction() async {
    if (!_isWalletConnected) {
      setState(() => _status = 'Please connect wallet first');
      return;
    }

    // Show dialog for transaction details
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _SendTransactionDialog(),
    );

    if (result != null) {
      try {
        setState(() => _status = 'Sending transaction...');
        
        final success = await _walletService.sendTransaction(
          to: result['to'],
          amount: result['amount'],
          currency: result['currency'],
          memo: result['memo'],
        );
        
        if (success) {
          setState(() => _status = 'Transaction sent successfully!');
          // Refresh balances
          _connectWallet();
        } else {
          setState(() => _status = 'Transaction failed');
        }
      } catch (e) {
        setState(() => _status = 'Transaction error: $e');
      }
    }
  }

  Future<void> _buyNFT(String listingId) async {
    if (!_isWalletConnected) {
      setState(() => _status = 'Please connect wallet first');
      return;
    }

    try {
      setState(() => _status = 'Purchasing NFT...');
      
      final success = await _yukuService.buyNFT(listingId);
      
      if (success) {
        setState(() => _status = 'NFT purchased successfully!');
        await _loadMarketplace();
        await _loadNFTs();
      } else {
        setState(() => _status = 'Purchase failed');
      }
    } catch (e) {
      setState(() => _status = 'Purchase error: $e');
    }
  }

  Future<void> _makeOffer(String nftId) async {
    if (!_isWalletConnected) {
      setState(() => _status = 'Please connect wallet first');
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _MakeOfferDialog(),
    );

    if (result != null) {
      try {
        setState(() => _status = 'Making offer...');
        
        final success = await _yukuService.makeOffer(
          nftId: nftId,
          amount: result['amount'],
          currency: result['currency'],
          expirationDays: result['expirationDays'],
        );
        
        if (success) {
          setState(() => _status = 'Offer made successfully!');
        } else {
          setState(() => _status = 'Failed to make offer');
        }
      } catch (e) {
        setState(() => _status = 'Offer error: $e');
      }
    }
  }

  Future<void> _loadWalletStats() async {
    if (!_isWalletConnected) {
      setState(() => _status = 'Please connect wallet first');
      return;
    }

    try {
      setState(() => _status = 'Loading wallet stats...');
      
      final stats = await _walletService.getWalletStats();
      
      setState(() {
        _status = 'Wallet stats loaded. Total value: \$${stats['totalValue'].toStringAsFixed(2)}';
      });

      // Show stats in dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Wallet Statistics'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Value: \$${stats['totalValue'].toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text('Transactions: ${stats['totalTransactions']}'),
                const SizedBox(height: 8),
                Text('NFTs: ${stats['totalNFTs']}'),
                const SizedBox(height: 8),
                Text('Network: ${stats['network']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _status = 'Error loading stats: $e');
    }
  }

  Future<void> _showTransactionHistory() async {
    if (!_isWalletConnected) {
      setState(() => _status = 'Please connect wallet first');
      return;
    }

    try {
      setState(() => _status = 'Loading transaction history...');
      
      final transactions = await _walletService.getTransactionHistory();
      
      setState(() => _status = 'Transaction history loaded');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Transaction History'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return ListTile(
                    leading: Icon(
                      tx['type'] == 'send' ? Icons.arrow_upward : Icons.arrow_downward,
                      color: tx['type'] == 'send' ? Colors.red : Colors.green,
                    ),
                    title: Text('${tx['amount']} ${tx['currency']}'),
                    subtitle: Text('${tx['type']} - ${tx['status']}'),
                    trailing: Text(
                      DateTime.parse(tx['timestamp'] as String)
                          .toString()
                          .substring(0, 16),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _status = 'Error loading history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter ICP Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.pending,
                          color: _isInitialized ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(_isInitialized ? 'Initialized' : 'Not Initialized'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Wallet Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    if (!_isWalletConnected) ...[
                      ElevatedButton.icon(
                        onPressed: _isInitialized ? _connectWallet : null,
                        icon: const Icon(Icons.account_balance_wallet),
                        label: const Text('Connect Plug Wallet'),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Connected: ${_walletAddress.substring(0, 20)}...',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      if (_balances.isNotEmpty) ...[
                        const Text('Balances:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ..._balances.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text('${entry.value.toStringAsFixed(4)} ${entry.key}'),
                        )),
                        const SizedBox(height: 8),
                      ],
                      
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _disconnectWallet,
                              icon: const Icon(Icons.logout),
                              label: const Text('Disconnect'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _sendTransaction,
                              icon: const Icon(Icons.send),
                              label: const Text('Send'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showTransactionHistory,
                              icon: const Icon(Icons.history),
                              label: const Text('History'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _loadWalletStats,
                              icon: const Icon(Icons.analytics),
                              label: const Text('Stats'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // NFT Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My NFTs',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton.icon(
                          onPressed: _isWalletConnected ? _loadNFTs : null,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Load'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (_nfts.isEmpty)
                      const Center(child: Text('No NFTs loaded'))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _nfts.length,
                        itemBuilder: (context, index) {
                          final nft = _nfts[index];
                          return ListTile(
                            leading: nft['image'] != null
                                ? Image.network(
                                    nft['image'] as String,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => 
                                      const Icon(Icons.image_not_supported),
                                  )
                                : const Icon(Icons.image),
                            title: Text(nft['name'] as String? ?? 'Unknown NFT'),
                            subtitle: Text(nft['description'] as String? ?? 'No description'),
                            trailing: Text('#${nft['tokenId'] as String? ?? nft['id'] as String? ?? '?'}'),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Marketplace Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Yuku Marketplace',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton.icon(
                          onPressed: _isInitialized ? _loadMarketplace : null,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Load'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (_listings.isEmpty)
                      const Center(child: Text('No listings loaded'))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _listings.length > 10 ? 10 : _listings.length,
                        itemBuilder: (context, index) {
                          final listing = _listings[index];
                          return ListTile(
                            leading: const Icon(Icons.shopping_cart),
                            title: Text('NFT #${listing.nftId}'),
                            subtitle: Text('Seller: ${listing.sellerAddress.length > 15 ? listing.sellerAddress.substring(0, 15) + '...' : listing.sellerAddress}'),
                            trailing: Text(
                              '${listing.price.toStringAsFixed(2)} ${listing.currency}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
