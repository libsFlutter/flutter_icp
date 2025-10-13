import 'package:flutter/material.dart';
import 'package:flutter_icp/flutter_icp.dart';

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
  final NFTService _nftService = NFTService();
  
  bool _isInitialized = false;
  bool _isWalletConnected = false;
  String _walletAddress = '';
  List<ICPBalance> _balances = [];
  List<ICPNFT> _nfts = [];
  List<ICPListing> _listings = [];
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
      
      setState(() => _status = 'Initializing NFT Service...');
      await _nftService.initialize();
      
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
        final address = await _walletService.getPrincipal();
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
        _balances = [];
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
      
      final nfts = await _nftService.getNFTsByOwner(_walletAddress);
      
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
                        ..._balances.map((balance) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text('${balance.amount} ${balance.currency}'),
                        )),
                        const SizedBox(height: 8),
                      ],
                      
                      ElevatedButton.icon(
                        onPressed: _disconnectWallet,
                        icon: const Icon(Icons.logout),
                        label: const Text('Disconnect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
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
                            leading: nft.imageUrl != null
                                ? Image.network(
                                    nft.imageUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => 
                                      const Icon(Icons.image_not_supported),
                                  )
                                : const Icon(Icons.image),
                            title: Text(nft.name),
                            subtitle: Text(nft.description ?? 'No description'),
                            trailing: Text('#${nft.tokenId}'),
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
                            subtitle: Text('Seller: ${listing.sellerAddress.substring(0, 15)}...'),
                            trailing: Text(
                              '${listing.price} ${listing.currency}',
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
