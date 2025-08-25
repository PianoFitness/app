#!/bin/bash

# Script to check for text-based selectors in test files
# Usage: ./scripts/check-test-selectors.sh [files...]

echo "🧪 Checking for text-based selectors in test files..."

if [ $# -eq 0 ]; then
    # No files specified, check all test files
    TEST_FILES=$(find test -name "*_test.dart" -type f)
else
    # Use provided files
    TEST_FILES="$@"
fi

FOUND_ISSUES=false

for file in $TEST_FILES; do
    if [ -f "$file" ]; then
        # Check for problematic patterns
        MATCHES=$(grep -n "tester\.tap.*find\.text\|await.*tap.*find\.text\|\.tap(find\.text" "$file" 2>/dev/null)
        if [ ! -z "$MATCHES" ]; then
            echo "❌ Found text-based selectors in $file:"
            echo "$MATCHES"
            echo ""
            FOUND_ISSUES=true
        fi
    fi
done

if [ "$FOUND_ISSUES" = true ]; then
    echo "❌ Text-based selectors detected in test files."
    echo ""
    echo "Please use find.byKey() with stable keys instead of find.text() for interactive elements."
    echo "This improves test robustness and supports internationalization."
    echo ""
    echo "Examples:"
    echo "❌ await tester.tap(find.text(\"Practice\"));"
    echo "✅ await tester.tap(find.byKey(const Key(\"nav_tab_practice\")));"
    echo ""
    echo "See test/GUIDELINES.md for more information on key-based testing."
    exit 1
else
    echo "✅ No text-based selectors found in test files."
    exit 0
fi