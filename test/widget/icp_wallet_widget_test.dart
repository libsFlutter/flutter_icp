import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_icp/src/widgets/icp_wallet_widget.dart';

void main() {
  group('IcpWalletWidget', () {
    testWidgets('should display wallet information correctly', (WidgetTester tester) async {
      // Arrange
      const address = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
      const balance = 10.5432;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpWalletWidget(
              address: address,
              balance: balance,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('ICP Wallet'), findsOneWidget);
      expect(find.text('Address: $address'), findsOneWidget);
      expect(find.text('Balance: ${balance.toStringAsFixed(4)} ICP'), findsOneWidget);
    });

    testWidgets('should display truncated address when too long', (WidgetTester tester) async {
      // Arrange
      const longAddress = 'rdmx6-jaaaa-aaaaa-aaadq-cai-very-long-address-that-should-be-truncated';
      const balance = 5.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpWalletWidget(
              address: longAddress,
              balance: balance,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('ICP Wallet'), findsOneWidget);
      expect(find.textContaining('Address: '), findsOneWidget);
      expect(find.text('Balance: ${balance.toStringAsFixed(4)} ICP'), findsOneWidget);
    });

    testWidgets('should show connect button when onAction is provided', (WidgetTester tester) async {
      // Arrange
      const address = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
      const balance = 10.5;
      bool actionCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpWalletWidget(
              address: address,
              balance: balance,
              onAction: () {
                actionCalled = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Connect Wallet'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // Tap the button
      await tester.tap(find.text('Connect Wallet'));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    testWidgets('should not show connect button when onAction is null', (WidgetTester tester) async {
      // Arrange
      const address = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
      const balance = 10.5;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpWalletWidget(
              address: address,
              balance: balance,
              onAction: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Connect Wallet'), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should format balance correctly with 4 decimal places', (WidgetTester tester) async {
      // Arrange
      const address = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
      const balance = 1.23456789;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpWalletWidget(
              address: address,
              balance: balance,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Balance: 1.2346 ICP'), findsOneWidget);
    });

    testWidgets('should handle zero balance', (WidgetTester tester) async {
      // Arrange
      const address = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
      const balance = 0.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpWalletWidget(
              address: address,
              balance: balance,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Balance: 0.0000 ICP'), findsOneWidget);
    });

    testWidgets('should use Card as container', (WidgetTester tester) async {
      // Arrange
      const address = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
      const balance = 10.5;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpWalletWidget(
              address: address,
              balance: balance,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should have proper text styles', (WidgetTester tester) async {
      // Arrange
      const address = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
      const balance = 10.5;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpWalletWidget(
              address: address,
              balance: balance,
            ),
          ),
        ),
      );

      // Assert
      final titleWidget = tester.widget<Text>(find.text('ICP Wallet'));
      expect(titleWidget.style?.fontSize, equals(18));
      expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));

      final balanceWidget = tester.widget<Text>(find.text('Balance: ${balance.toStringAsFixed(4)} ICP'));
      expect(balanceWidget.style?.fontSize, equals(16));
      expect(balanceWidget.style?.fontWeight, equals(FontWeight.w500));

      final addressWidget = tester.widget<Text>(find.text('Address: $address'));
      expect(addressWidget.style?.fontSize, equals(12));
      expect(addressWidget.maxLines, equals(2));
      expect(addressWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should have proper padding', (WidgetTester tester) async {
      // Arrange
      const address = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
      const balance = 10.5;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpWalletWidget(
              address: address,
              balance: balance,
            ),
          ),
        ),
      );

      // Assert
      final paddingWidget = tester.widget<Padding>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Padding),
        ).first,
      );
      expect(paddingWidget.padding, equals(const EdgeInsets.all(16.0)));
    });

    testWidgets('should handle empty address', (WidgetTester tester) async {
      // Arrange
      const address = '';
      const balance = 10.5;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpWalletWidget(
              address: address,
              balance: balance,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Address: '), findsOneWidget);
      expect(find.text('Balance: ${balance.toStringAsFixed(4)} ICP'), findsOneWidget);
    });

    testWidgets('should handle negative balance', (WidgetTester tester) async {
      // Arrange
      const address = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
      const balance = -5.25;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IcpWalletWidget(
              address: address,
              balance: balance,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Balance: -5.2500 ICP'), findsOneWidget);
    });
  });
}
