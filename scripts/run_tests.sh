#!/bin/bash

# Flutter ICP Test Runner Script
# This script runs different types of tests

set -e

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -u, --unit          Run unit tests only"
    echo "  -w, --widget        Run widget tests only"
    echo "  -i, --integration   Run integration tests only"
    echo "  -c, --coverage      Run all tests with coverage"
    echo "  -v, --verbose       Verbose output"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Run all tests"
    echo "  $0 --unit           # Run only unit tests"
    echo "  $0 --coverage       # Run all tests with coverage"
}

# Default values
RUN_UNIT=false
RUN_WIDGET=false
RUN_INTEGRATION=false
RUN_COVERAGE=false
VERBOSE=false
RUN_ALL=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--unit)
            RUN_UNIT=true
            RUN_ALL=false
            shift
            ;;
        -w|--widget)
            RUN_WIDGET=true
            RUN_ALL=false
            shift
            ;;
        -i|--integration)
            RUN_INTEGRATION=true
            RUN_ALL=false
            shift
            ;;
        -c|--coverage)
            RUN_COVERAGE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Set verbose flag
VERBOSE_FLAG=""
if [ "$VERBOSE" = true ]; then
    VERBOSE_FLAG="--verbose"
fi

# Function to run specific test category
run_test_category() {
    local category=$1
    local pattern=$2
    
    echo "🧪 Running $category tests..."
    flutter test $VERBOSE_FLAG test/$pattern
    echo "✅ $category tests completed"
    echo ""
}

echo "🚀 Flutter ICP Test Runner"
echo "=========================="

# Run coverage if requested
if [ "$RUN_COVERAGE" = true ]; then
    echo "📊 Running tests with coverage..."
    ./scripts/test_coverage.sh
    exit 0
fi

# Run specific test categories or all tests
if [ "$RUN_ALL" = true ]; then
    echo "🧪 Running all tests..."
    flutter test $VERBOSE_FLAG
    echo "✅ All tests completed successfully!"
else
    if [ "$RUN_UNIT" = true ]; then
        run_test_category "Unit" "unit/**/*_test.dart"
    fi
    
    if [ "$RUN_WIDGET" = true ]; then
        run_test_category "Widget" "widget/**/*_test.dart"
    fi
    
    if [ "$RUN_INTEGRATION" = true ]; then
        run_test_category "Integration" "integration/**/*_test.dart"
    fi
fi

echo "🎉 Test execution completed!"
