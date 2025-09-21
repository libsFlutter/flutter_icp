/// Flutter library for Internet Computer Protocol (ICP) blockchain operations
///
/// This library provides ICP-specific implementations for the flutter_nft
/// universal NFT library, including wallet integration, NFT operations,
/// and marketplace functionality.
library flutter_icp;

// Core exports
export 'src/core/icp_client.dart';
export 'src/core/icp_config.dart';
export 'src/core/icp_exceptions.dart';
export 'src/core/icp_types.dart';

// Providers
export 'src/providers/icp_nft_provider.dart';
export 'src/providers/plug_wallet_provider.dart';
export 'src/providers/yuku_marketplace_provider.dart';

// Models
export 'src/models/icp_nft.dart';
export 'src/models/icp_transaction.dart';
export 'src/models/icp_listing.dart';
export 'src/models/icp_offer.dart';
export 'src/models/icp_account.dart';

// Services
export 'src/services/icp_service.dart';
export 'src/services/plug_wallet_service.dart';
export 'src/services/yuku_service.dart';
export 'src/services/nft_service.dart';
export 'src/services/enhanced_icp_service.dart';
export 'src/services/icp_socket_manager.dart';
export 'src/services/icp_auth_service.dart';

// Utils
export 'src/utils/icp_utils.dart';
export 'src/utils/crypto_utils.dart';

// Widgets
export 'src/widgets/icp_wallet_widget.dart';
export 'src/widgets/icp_nft_widget.dart';
export 'src/widgets/yuku_marketplace_widget.dart';
