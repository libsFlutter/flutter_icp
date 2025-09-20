# Flutter ICP Library - Test Guide

This guide provides comprehensive information about testing the Flutter ICP library, including setup, running tests, and understanding coverage.

## Table of Contents

- [Overview](#overview)
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Test Coverage](#test-coverage)
- [Test Categories](#test-categories)
- [Writing Tests](#writing-tests)
- [Continuous Integration](#continuous-integration)

## Overview

The Flutter ICP library includes comprehensive tests covering all major functionality demonstrated in the example application:

- **Unit Tests**: Test individual components and functions
- **Widget Tests**: Test UI components and their interactions
- **Integration Tests**: Test complete workflows and user scenarios
- **Mock Services**: Provide realistic test data and behavior simulation

## Test Structure

```
test/
├── flutter_icp_test.dart          # Main test entry point
├── mocks/                         # Mock implementations
│   ├── mock_icp_client.dart      # Mock ICP client
│   └── mock_services.dart         # Mock wallet and marketplace services
├── unit/                          # Unit tests
│   ├── core/                      # Core functionality tests
│   │   ├── icp_client_test.dart   # ICP client tests
│   │   └── icp_config_test.dart   # Configuration tests
│   └── providers/                 # Provider tests
│       ├── icp_nft_provider_test.dart
│       ├── plug_wallet_provider_test.dart
│       └── yuku_marketplace_provider_test.dart
├── widget/                        # Widget tests
│   ├── icp_wallet_widget_test.dart
│   └── icp_nft_widget_test.dart
└── integration/                   # Integration tests
    ├── wallet_connection_flow_test.dart
    └── nft_marketplace_flow_test.dart
```

## Running Tests

### Quick Start

Run all tests:
```bash
flutter test
```

### Using Test Scripts

The library includes convenient test scripts:

```bash
# Run all tests
./scripts/run_tests.sh

# Run specific test categories
./scripts/run_tests.sh --unit           # Unit tests only
./scripts/run_tests.sh --widget         # Widget tests only
./scripts/run_tests.sh --integration    # Integration tests only

# Run with coverage
./scripts/run_tests.sh --coverage

# Verbose output
./scripts/run_tests.sh --verbose
```

### Manual Test Execution

Run specific test files:
```bash
# Unit tests
flutter test test/unit/core/icp_client_test.dart
flutter test test/unit/providers/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test test/integration/
```

## Test Coverage

### Generating Coverage Reports

Run tests with coverage:
```bash
flutter test --coverage
```

Or use the coverage script:
```bash
./scripts/test_coverage.sh
```

### Coverage Requirements

The library maintains the following coverage thresholds:
- **Line Coverage**: ≥ 80%
- **Branch Coverage**: ≥ 70%
- **Function Coverage**: ≥ 80%

### Viewing Coverage Reports

After running coverage tests:
1. HTML Report: Open `coverage/html/index.html` in your browser
2. LCOV Report: Available in `coverage/lcov.info`
3. Console Summary: Displayed after test execution

## Test Categories

### Unit Tests

Test individual components in isolation:

#### Core Tests
- **ICP Client**: Network operations, caching, error handling
- **ICP Config**: Configuration management, network switching
- **ICP Types**: Data models and validation

#### Provider Tests
- **NFT Provider**: NFT operations, minting, transfers
- **Wallet Provider**: Connection, balance, transactions
- **Marketplace Provider**: Listings, offers, purchases

### Widget Tests

Test UI components and user interactions:

#### Wallet Widget Tests
- Display wallet information
- Handle connection states
- Button interactions
- Error states

#### NFT Widget Tests
- Display NFT metadata
- Image handling
- Tap gestures
- Layout responsiveness

### Integration Tests

Test complete user workflows as demonstrated in the example app:

#### Wallet Connection Flow
- Provider initialization
- Wallet connection/disconnection
- Balance checking
- Transaction history
- Error handling

#### NFT Marketplace Flow
- Complete marketplace workflows
- NFT minting and listing
- Offer management
- Purchase transactions
- Analytics and statistics

## Writing Tests

### Test Structure Guidelines

Follow this structure for new tests:

```dart
import 'package:flutter_test/flutter_test.dart';
// Import necessary packages and mocks

void main() {
  group('ComponentName', () {
    late ComponentType component;
    late MockDependency mockDependency;

    setUp(() {
      // Initialize test objects
      component = ComponentType();
      mockDependency = MockDependency();
    });

    group('Feature Group', () {
      test('should perform expected behavior', () async {
        // Arrange
        // Set up test data and expectations

        // Act
        // Execute the code under test

        // Assert
        // Verify the results
        expect(result, expectedValue);
      });
    });
  });
}
```

### Mock Usage

Use the provided mock services for consistent testing:

```dart
import '../mocks/mock_services.dart';
import '../mocks/mock_icp_client.dart';

// In your test:
final mockWalletService = MockPlugWalletService();
final mockClient = MockICPClient();

// Configure mock behavior
mockClient.setMockData('canister-id', 'method', {'result': 'data'});
```

### Test Data

Use realistic test data that matches the example app:

```dart
const testAddress = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
const testBalance = 10.5432;

final testNFTMetadata = NFTMetadata(
  name: 'Test NFT',
  description: 'Test NFT Description',
  image: 'https://example.com/image.png',
  attributes: {'color': 'blue', 'rarity': 'common'},
);
```

### Error Testing

Include error scenarios in your tests:

```dart
test('should throw exception for invalid input', () async {
  // Arrange
  const invalidInput = 'invalid';

  // Act & Assert
  expect(
    () => component.processInput(invalidInput),
    throwsA(isA<ValidationException>()),
  );
});
```

## Test Functionality Coverage

The test suite covers all functionality demonstrated in the example app:

### ✅ Wallet Operations
- [x] Connect/disconnect wallet
- [x] Check connection status
- [x] Get wallet address
- [x] Check balances
- [x] Transaction history
- [x] Send transactions
- [x] Sign messages

### ✅ NFT Operations
- [x] Mint NFTs
- [x] Load user NFTs
- [x] Transfer NFTs
- [x] Approve NFTs
- [x] Get NFT metadata
- [x] Search NFTs

### ✅ Marketplace Operations
- [x] Create listings
- [x] Load active listings
- [x] Cancel listings
- [x] Buy NFTs
- [x] Make offers
- [x] Accept/reject offers
- [x] Search listings
- [x] Get marketplace statistics

### ✅ Provider Management
- [x] Initialize providers
- [x] Register providers
- [x] Provider availability
- [x] Error handling
- [x] Network switching

### ✅ UI Components
- [x] Wallet widget display
- [x] NFT widget display
- [x] User interactions
- [x] Error states
- [x] Loading states

## Continuous Integration

### GitHub Actions

Example workflow for CI/CD:

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test --coverage
      - run: ./scripts/test_coverage.sh
```

### Coverage Reporting

Integrate with coverage services:
- **Codecov**: Upload `coverage/lcov.info`
- **Coveralls**: Use lcov data for reporting
- **SonarQube**: Analyze code quality and coverage

## Best Practices

### Test Organization
- Group related tests together
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Keep tests focused and isolated

### Mock Management
- Use consistent mock data
- Reset mocks between tests
- Verify mock interactions when necessary
- Keep mocks simple and focused

### Coverage Goals
- Aim for high line coverage (≥80%)
- Focus on critical paths and error handling
- Don't chase 100% coverage at the expense of quality
- Review coverage reports regularly

### Performance
- Keep tests fast and focused
- Use mocks to avoid external dependencies
- Parallel test execution where possible
- Regular test cleanup and optimization

## Troubleshooting

### Common Issues

1. **Mock Generation Errors**
   ```bash
   flutter packages pub run build_runner build
   ```

2. **Coverage Not Generated**
   - Ensure `--coverage` flag is used
   - Check that test files are properly structured
   - Verify lcov is installed for HTML reports

3. **Integration Test Failures**
   - Check mock service initialization
   - Verify provider registration order
   - Ensure proper async/await usage

4. **Widget Test Issues**
   - Use `pumpWidget` for widget setup
   - Call `pump()` after interactions
   - Check widget finder specificity

### Getting Help

- Check the example app for reference implementations
- Review existing tests for patterns
- Consult Flutter testing documentation
- Open issues for library-specific problems

## Conclusion

The Flutter ICP library test suite provides comprehensive coverage of all functionality demonstrated in the example application. By following this guide and using the provided tools, you can maintain high code quality and ensure reliable functionality across all library components.

For more information, see:
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Example App](example/)
- [Library Documentation](README.md)
