import 'package:flutter/material.dart';
import 'package:flutter_nft/flutter_nft.dart';
import 'package:flutter_icp/flutter_icp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize NFT client with ICP providers
  final nftClient = NFTClient();

  // Register ICP providers
  nftClient.registerNFTProvider(ICPNFTProvider());
  nftClient.registerWalletProvider(PlugWalletProvider());
  nftClient.registerMarketplaceProvider(YukuMarketplaceProvider());

  // Initialize all providers
  await nftClient.initialize();

  runApp(MyApp(nftClient: nftClient));
}

class MyApp extends StatelessWidget {
  final NFTClient nftClient;

  const MyApp({Key? key, required this.nftClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ICP Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ICPExampleScreen(nftClient: nftClient),
    );
  }
}

class ICPExampleScreen extends StatefulWidget {
  final NFTClient nftClient;

  const ICPExampleScreen({Key? key, required this.nftClient}) : super(key: key);

  @override
  State<ICPExampleScreen> createState() => _ICPExampleScreenState();
}

class _ICPExampleScreenState extends State<ICPExampleScreen> {
  late WalletProvider walletProvider;
  late NFTProvider nftProvider;
  late MarketplaceProvider marketplaceProvider;

  bool isWalletConnected = false;
  String? walletAddress;
  List<NFT> userNFTs = [];
  List<NFTListing> activeListings = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();

    // Get providers
    walletProvider = widget.nftClient.getWalletProvider(BlockchainNetwork.icp)!;
    nftProvider = widget.nftClient.getNFTProvider(BlockchainNetwork.icp)!;
    marketplaceProvider =
        widget.nftClient.getMarketplaceProvider(BlockchainNetwork.icp)!;

    // Check initial connection status
    _checkWalletConnection();
  }

  Future<void> _checkWalletConnection() async {
    setState(() {
      isWalletConnected = walletProvider.isConnected;
      walletAddress = walletProvider.connectedAddress;
    });
  }

  Future<void> _connectWallet() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final connected = await walletProvider.connect();
      if (connected) {
        await _checkWalletConnection();
        await _loadUserNFTs();
        await _loadActiveListings();
      }
    } catch (e) {
      setState(() {
        error = 'Failed to connect wallet: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _disconnectWallet() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await walletProvider.disconnect();
      await _checkWalletConnection();
      setState(() {
        userNFTs.clear();
        activeListings.clear();
      });
    } catch (e) {
      setState(() {
        error = 'Failed to disconnect wallet: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserNFTs() async {
    if (!isWalletConnected || walletAddress == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final nfts = await nftProvider.getNFTsByOwner(walletAddress!);
      setState(() {
        userNFTs = nfts;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load NFTs: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadActiveListings() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final listings = await marketplaceProvider.getActiveListings();
      setState(() {
        activeListings = listings;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load listings: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _mintNFT() async {
    if (!isWalletConnected || walletAddress == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final metadata = NFTMetadata(
        name: 'My ICP NFT #${DateTime.now().millisecondsSinceEpoch}',
        description: 'This is a test NFT minted on ICP',
        image: 'https://via.placeholder.com/300x300.png?text=ICP+NFT',
        attributes: {
          'Color': 'Blue',
          'Rarity': 'Common',
          'Network': 'ICP',
        },
        properties: {
          'minted_by': 'Flutter ICP Example',
          'mint_date': DateTime.now().toIso8601String(),
        },
      );

      final transactionHash = await nftProvider.mintNFT(
        toAddress: walletAddress!,
        metadata: metadata,
        contractAddress: 'example-nft-canister-id',
      );

      setState(() {
        error = 'NFT minted successfully! Transaction: $transactionHash';
      });

      // Reload user NFTs
      await _loadUserNFTs();
    } catch (e) {
      setState(() {
        error = 'Failed to mint NFT: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _createListing(NFT nft) async {
    if (!isWalletConnected || walletAddress == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final listingId = await marketplaceProvider.createListing(
        nftId: nft.tokenId,
        contractAddress: nft.contractAddress,
        price: 10.0,
        currency: 'ICP',
        sellerAddress: walletAddress!,
      );

      setState(() {
        error = 'Listing created successfully! ID: $listingId';
      });

      // Reload data
      await _loadUserNFTs();
      await _loadActiveListings();
    } catch (e) {
      setState(() {
        error = 'Failed to create listing: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter ICP Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wallet Connection Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isWalletConnected ? Icons.check_circle : Icons.cancel,
                          color: isWalletConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isWalletConnected ? 'Connected' : 'Disconnected',
                          style: TextStyle(
                            color:
                                isWalletConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (walletAddress != null) ...[
                      const SizedBox(height: 8),
                      Text('Address: ${walletAddress!.substring(0, 10)}...'),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _connectWallet,
                            child: const Text('Connect Wallet'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _disconnectWallet,
                            child: const Text('Disconnect'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          isLoading || !isWalletConnected ? null : _mintNFT,
                      child: const Text('Mint Test NFT'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _loadUserNFTs,
                            child: const Text('Load My NFTs'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _loadActiveListings,
                            child: const Text('Load Listings'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Error Display
            if (error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Loading Indicator
            if (isLoading) const Center(child: CircularProgressIndicator()),

            // Content
            if (!isLoading) ...[
              // User NFTs Section
              if (userNFTs.isNotEmpty) ...[
                Text(
                  'My NFTs (${userNFTs.length})',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: userNFTs.length,
                    itemBuilder: (context, index) {
                      final nft = userNFTs[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(nft.metadata.image),
                          ),
                          title: Text(nft.metadata.name),
                          subtitle: Text(nft.metadata.description),
                          trailing: ElevatedButton(
                            onPressed: () => _createListing(nft),
                            child: const Text('List'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Active Listings Section
              if (activeListings.isNotEmpty) ...[
                Text(
                  'Active Listings (${activeListings.length})',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: activeListings.length,
                    itemBuilder: (context, index) {
                      final listing = activeListings[index];
                      return Card(
                        child: ListTile(
                          title: Text('NFT #${listing.nftId}'),
                          subtitle: Text('Price: ${listing.formattedPrice}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Buy NFT functionality would go here
                            },
                            child: const Text('Buy'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Empty State
              if (userNFTs.isEmpty && activeListings.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No NFTs or listings found',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect your wallet and mint an NFT to get started',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
