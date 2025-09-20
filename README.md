# Flutter ICP

Flutter library for Internet Computer Protocol (ICP) blockchain operations, designed as a provider for the `flutter_nft` universal NFT library.

## Features

- 🌐 **ICP Blockchain Integration** - Full support for Internet Computer Protocol
- 💼 **Plug Wallet Integration** - Seamless wallet connectivity
- 🛒 **Yuku Marketplace** - Trade NFTs on Yuku marketplace
- 🔌 **Provider Architecture** - Works with flutter_nft universal library
- 📱 **Cross-platform** - Works on iOS, Android, Web, and Desktop
- 🔒 **Type-safe** - Full type safety with Dart's type system

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_icp: ^1.0.0
  flutter_nft: ^1.0.0  # Required
```

## Quick Start

### 1. Initialize ICP Providers

```dart
import 'package:flutter_nft/flutter_nft.dart';
import 'package:flutter_icp/flutter_icp.dart';

void main() async {
  // Create NFT client
  final nftClient = NFTClient();
  
  // Register ICP providers
  nftClient.registerNFTProvider(ICPNFTProvider());
  nftClient.registerWalletProvider(PlugWalletProvider());
  nftClient.registerMarketplaceProvider(YukuMarketplaceProvider());
  
  // Initialize all providers
  await nftClient.initialize();
  
  runApp(MyApp());
}
```

### 2. Connect to Plug Wallet

```dart
// Get wallet provider
final walletProvider = nftClient.getWalletProvider(BlockchainNetwork.icp);

// Connect to wallet
final isConnected = await walletProvider.connect();
if (isConnected) {
  final address = await walletProvider.getAddress();
  print('Connected to: $address');
}
```

### 3. Get User's NFTs

```dart
// Get NFT provider
final nftProvider = nftClient.getNFTProvider(BlockchainNetwork.icp);

// Get user's NFTs
final nfts = await nftProvider.getNFTsByOwner(userAddress);
print('Found ${nfts.length} NFTs');
```

### 4. Mint an NFT

```dart
// Create NFT metadata
final metadata = NFTMetadata(
  name: 'My ICP NFT',
  description: 'This is my ICP NFT',
  image: 'https://example.com/image.png',
  attributes: {
    'Color': 'Blue',
    'Rarity': 'Rare',
  },
);

// Mint the NFT
final transactionHash = await nftProvider.mintNFT(
  toAddress: userAddress,
  metadata: metadata,
  contractAddress: 'your-canister-id',
);
```

### 5. List NFT on Yuku Marketplace

```dart
// Get marketplace provider
final marketplaceProvider = nftClient.getMarketplaceProvider(BlockchainNetwork.icp);

// Create listing
final listingId = await marketplaceProvider.createListing(
  nftId: nft.tokenId,
  contractAddress: nft.contractAddress,
  price: 100.0,
  currency: 'ICP',
  sellerAddress: userAddress,
);
```

## Configuration

### Network Configuration

```dart
import 'package:flutter_icp/flutter_icp.dart';

// Use mainnet (default)
ICPConfig.instance.useMainnet();

// Use testnet
ICPConfig.instance.useTestnet();

// Custom configuration
ICPConfig.instance.setNetworkConfig(ICPNetworkConfig(
  name: 'Custom ICP Network',
  url: 'https://custom-icp.network',
  isTestnet: false,
  canisterIds: {
    'ledger': 'your-ledger-canister-id',
    'nft': 'your-nft-canister-id',
  },
));
```

### Custom Canister IDs

```dart
// Set custom canister IDs
ICPConfig.instance.setCanisterId('nft', 'your-nft-canister-id');
ICPConfig.instance.setCanisterId('marketplace', 'your-marketplace-canister-id');

// Set custom parameters
ICPConfig.instance.setCustomParam('apiKey', 'your-api-key');
ICPConfig.instance.setCustomParam('timeout', 30);
```

## Advanced Usage

### Direct ICP Client Usage

```dart
import 'package:flutter_icp/flutter_icp.dart';

final client = ICPClient.instance;

// Initialize
await client.initialize();

// Make query calls
final result = await client.query(
  canisterId: 'your-canister-id',
  method: 'get_data',
  args: {'param': 'value'},
);

// Make update calls
final updateResult = await client.update(
  canisterId: 'your-canister-id',
  method: 'update_data',
  args: {'param': 'value'},
);
```

### Plug Wallet Service

```dart
import 'package:flutter_icp/flutter_icp.dart';

final walletService = PlugWalletService();

// Initialize
await walletService.initialize();

// Connect
final connected = await walletService.connect();

// Get balance
final balances = await walletService.getBalance();

// Send transaction
final success = await walletService.sendTransaction(
  to: 'recipient-address',
  amount: 1.0,
  currency: 'ICP',
);

// Approve NFT transaction
final approved = await walletService.approveNFTTransaction(
  nftCanisterId: 'nft-canister-id',
  nftId: 'nft-token-id',
  price: 100.0,
  currency: 'ICP',
);
```

### Yuku Marketplace Service

```dart
import 'package:flutter_icp/flutter_icp.dart';

final yukuService = YukuService();

// Initialize
await yukuService.initialize();

// Get active listings
final listings = await yukuService.getActiveListings();

// Create listing
final success = await yukuService.createListing(
  nftId: 'nft-id',
  price: 100.0,
  currency: 'ICP',
);

// Make offer
final offerSuccess = await yukuService.makeOffer(
  nftId: 'nft-id',
  amount: 90.0,
  currency: 'ICP',
);
```

## Architecture

The library follows a provider-based architecture that integrates with `flutter_nft`:

```
NFTClient (from flutter_nft)
├── ICPNFTProvider (ICP-specific NFT operations)
├── PlugWalletProvider (Plug Wallet integration)
└── YukuMarketplaceProvider (Yuku marketplace integration)
```

### Provider Interfaces

All providers implement the standard interfaces from `flutter_nft`:

- `NFTProvider` - NFT operations
- `WalletProvider` - Wallet connectivity
- `MarketplaceProvider` - Marketplace operations

## Supported Operations

### NFT Operations
- ✅ Mint NFTs
- ✅ Transfer NFTs
- ✅ Burn NFTs
- ✅ Approve NFT transfers
- ✅ Get NFT metadata
- ✅ Update NFT metadata
- ✅ Search NFTs

### Wallet Operations
- ✅ Connect to Plug Wallet
- ✅ Get balances
- ✅ Send transactions
- ✅ Sign messages
- ✅ Approve transactions
- ✅ Get transaction history

### Marketplace Operations
- ✅ Create listings
- ✅ Buy NFTs
- ✅ Make offers
- ✅ Accept/reject offers
- ✅ Cancel listings
- ✅ Search listings

## Error Handling

The library provides specific exception types:

```dart
try {
  final nfts = await nftProvider.getNFTsByOwner(address);
} on ICPPrincipalInvalidException catch (e) {
  // Handle invalid ICP principal
} on ICPTransactionException catch (e) {
  // Handle transaction failure
} on ICPNetworkException catch (e) {
  // Handle network issues
} on WalletNotConnectedException catch (e) {
  // Handle wallet not connected
}
```

## Examples

Check out the `example/` directory for complete examples:

- Basic NFT operations
- Wallet integration
- Marketplace trading
- Custom configuration

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This project is licensed under the NativeMindNONC - see the [LICENSE](LICENSE) file for details.

## Support

- 📖 [Documentation](https://docs.flutter-icp.dev)
- 💬 [Discord Community](https://discord.gg/flutter-icp)
- 🐛 [Issue Tracker](https://github.com/your-org/flutter_icp/issues)
- 📧 [Email Support](mailto:support@flutter-icp.dev)

## Related Projects

- [flutter_nft](https://github.com/your-org/flutter_nft) - Universal NFT library
- [Plug Wallet](https://plugwallet.ooo) - ICP wallet extension
- [Yuku](https://yuku.app) - ICP NFT marketplace