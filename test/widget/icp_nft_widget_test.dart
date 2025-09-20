import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nft/flutter_nft.dart';
import 'package:flutter_icp/src/widgets/icp_nft_widget.dart';
import 'package:flutter_icp/src/models/icp_nft.dart';

void main() {
  group('IcpNftWidget', () {
    ICPNFT createMockNft({
      String name = 'Test NFT',
      String description = 'This is a test NFT description',
      String image = 'https://example.com/image.png',
      String tokenId = '1',
    }) {
      return ICPNFT(
        id: 'nft_1',
        tokenId: tokenId,
        canisterId: 'test-canister',
        owner: 'test-owner',
        metadata: NFTMetadata(
          name: name,
          description: description,
          image: image,
          attributes: {'color': 'blue', 'rarity': 'common'},
          properties: {'type': 'test'},
        ),
        creator: 'test-creator',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'active',
        transactionHistory: ['tx1', 'tx2'],
        icpProperties: ICPNFTProperties(
          isTransferable: true,
          isBurnable: true,
          isPausable: false,
          isMintable: true,
          royaltyPercentage: 5.0,
          currentSupply: 1,
          metadataMutable: false,
        ),
      );
    }

    testWidgets('should display NFT information correctly', (WidgetTester tester) async {
      // Arrange
      final mockNft = createMockNft();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpNftWidget(nft: mockNft),
          ),
        ),
      );

      // Assert
      expect(find.text('Test NFT'), findsOneWidget);
      expect(find.text('This is a test NFT description'), findsOneWidget);
      expect(find.text('Token ID: 1'), findsOneWidget);
    });

    testWidgets('should display image when available', (WidgetTester tester) async {
      // Arrange
      final mockNft = createMockNft();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpNftWidget(nft: mockNft),
          ),
        ),
      );

      // Assert
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('should not display image section when image is empty', (WidgetTester tester) async {
      // Arrange
      final nftWithoutImage = createMockNft(image: '');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpNftWidget(nft: nftWithoutImage),
          ),
        ),
      );

      // Assert
      expect(find.byType(Image), findsNothing);
      expect(find.byType(ClipRRect), findsNothing);
    });

    testWidgets('should not display description when empty', (WidgetTester tester) async {
      // Arrange
      final nftWithoutDescription = createMockNft(description: '');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpNftWidget(nft: nftWithoutDescription),
          ),
        ),
      );

      // Assert
      expect(find.text('Test NFT'), findsOneWidget);
      expect(find.text('Token ID: 1'), findsOneWidget);
    });

    testWidgets('should handle tap gesture when onTap is provided', (WidgetTester tester) async {
      // Arrange
      final mockNft = createMockNft();
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpNftWidget(
              nft: mockNft,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should not crash when onTap is null', (WidgetTester tester) async {
      // Arrange
      final mockNft = createMockNft();

      // Act & Assert
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpNftWidget(
              nft: mockNft,
              onTap: null,
            ),
          ),
        ),
      );

      // Should not crash when tapping
      await tester.tap(find.byType(InkWell));
      await tester.pump();
    });

    testWidgets('should use Card as container', (WidgetTester tester) async {
      // Arrange
      final mockNft = createMockNft();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpNftWidget(nft: mockNft),
          ),
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('should have proper text styles and properties', (WidgetTester tester) async {
      // Arrange
      final mockNft = createMockNft();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpNftWidget(nft: mockNft),
          ),
        ),
      );

      // Assert
      final titleWidget = tester.widget<Text>(find.text('Test NFT'));
      expect(titleWidget.style?.fontSize, equals(16));
      expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(titleWidget.maxLines, equals(2));
      expect(titleWidget.overflow, equals(TextOverflow.ellipsis));

      final descriptionWidget = tester.widget<Text>(find.text('This is a test NFT description'));
      expect(descriptionWidget.style?.fontSize, equals(14));
      expect(descriptionWidget.maxLines, equals(3));
      expect(descriptionWidget.overflow, equals(TextOverflow.ellipsis));

      final tokenIdWidget = tester.widget<Text>(find.text('Token ID: 1'));
      expect(tokenIdWidget.style?.fontSize, equals(12));
      expect(tokenIdWidget.style?.fontFamily, equals('monospace'));
    });

    testWidgets('should truncate long NFT name', (WidgetTester tester) async {
      // Arrange
      final nftWithLongName = createMockNft(
        name: 'This is a very long NFT name that should be truncated when displayed in the widget to prevent layout issues',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpNftWidget(nft: nftWithLongName),
          ),
        ),
      );

      // Assert
      final titleWidget = tester.widget<Text>(find.textContaining('This is a very long NFT name'));
      expect(titleWidget.maxLines, equals(2));
      expect(titleWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should handle special characters in token ID', (WidgetTester tester) async {
      // Arrange
      final nftWithSpecialTokenId = createMockNft(tokenId: 'token-123_special!@#');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpNftWidget(nft: nftWithSpecialTokenId),
          ),
        ),
      );

      // Assert
      expect(find.text('Token ID: token-123_special!@#'), findsOneWidget);
    });
  });
}