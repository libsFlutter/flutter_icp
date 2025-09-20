import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_icp/flutter_icp.dart';

// Import all test suites
import 'unit/core/icp_client_test.dart' as icp_client_tests;
import 'unit/core/icp_config_test.dart' as icp_config_tests;
import 'unit/providers/icp_nft_provider_test.dart' as icp_nft_provider_tests;
import 'unit/providers/plug_wallet_provider_test.dart' as plug_wallet_provider_tests;
import 'unit/providers/yuku_marketplace_provider_test.dart' as yuku_marketplace_provider_tests;
import 'widget/icp_wallet_widget_test.dart' as icp_wallet_widget_tests;
import 'widget/icp_nft_widget_test.dart' as icp_nft_widget_tests;
import 'integration/wallet_connection_flow_test.dart' as wallet_connection_flow_tests;
import 'integration/nft_marketplace_flow_test.dart' as nft_marketplace_flow_tests;

void main() {
  group('Flutter ICP Library Tests', () {
    test('package can be imported', () {
      // Basic test to ensure the package can be imported
      expect(ICPNFTProvider, isNotNull);
      expect(PlugWalletProvider, isNotNull);
      expect(YukuMarketplaceProvider, isNotNull);
    });

    // Run all test suites
    group('Core Tests', () {
      icp_client_tests.main();
      icp_config_tests.main();
    });

    group('Provider Tests', () {
      icp_nft_provider_tests.main();
      plug_wallet_provider_tests.main();
      yuku_marketplace_provider_tests.main();
    });

    group('Widget Tests', () {
      icp_wallet_widget_tests.main();
      icp_nft_widget_tests.main();
    });

    group('Integration Tests', () {
      wallet_connection_flow_tests.main();
      nft_marketplace_flow_tests.main();
    });
  });
}
