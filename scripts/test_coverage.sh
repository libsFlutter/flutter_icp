#!/bin/bash

# Flutter ICP Test Coverage Script
# This script runs all tests with coverage and generates reports

set -e

echo "🧪 Running Flutter ICP Tests with Coverage..."

# Clean previous coverage data
rm -rf coverage/
mkdir -p coverage/

# Run tests with coverage
flutter test --coverage

# Check if lcov is available for HTML report generation
if command -v lcov &> /dev/null; then
    echo "📊 Generating HTML coverage report..."
    
    # Generate HTML report
    genhtml coverage/lcov.info -o coverage/html
    
    echo "✅ Coverage report generated in coverage/html/"
    echo "📖 Open coverage/html/index.html in your browser to view the report"
else
    echo "⚠️  lcov not found. Install it to generate HTML reports:"
    echo "   macOS: brew install lcov"
    echo "   Ubuntu: sudo apt-get install lcov"
fi

# Display coverage summary
if command -v lcov &> /dev/null; then
    echo "📈 Coverage Summary:"
    lcov --summary coverage/lcov.info
fi

# Check coverage thresholds
echo "🎯 Checking coverage thresholds..."

# Extract coverage percentage (this is a simplified check)
if [ -f coverage/lcov.info ]; then
    COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | grep -o '[0-9.]*%' | head -1 | sed 's/%//')
    
    if [ -n "$COVERAGE" ]; then
        echo "📊 Line Coverage: ${COVERAGE}%"
        
        # Check if coverage meets minimum threshold (80%)
        if (( $(echo "$COVERAGE >= 80" | bc -l) )); then
            echo "✅ Coverage threshold met (${COVERAGE}% >= 80%)"
        else
            echo "❌ Coverage threshold not met (${COVERAGE}% < 80%)"
            exit 1
        fi
    else
        echo "⚠️  Could not determine coverage percentage"
    fi
else
    echo "⚠️  Coverage file not found"
fi

echo "🎉 Test coverage analysis complete!"
