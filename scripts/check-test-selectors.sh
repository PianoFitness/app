#!/bin/bash
set -euo pipefail

# Script to check for text-based selectors in test files
# Usage: ./scripts/check-test-selectors.sh [files...]

echo "🧪 Checking for text-based selectors in test files..."

if [ $# -eq 0 ]; then
    # No files specified, check all test files
    # Use while-read loop to populate array (more portable than mapfile)
    TEST_FILES=()
    while IFS= read -r -d '' file; do
        TEST_FILES+=("$file")
    done < <(find test -name "*_test.dart" -type f -print0)
else
    # Use provided files as array
    TEST_FILES=("$@")
fi

FOUND_ISSUES=false

# Check if array is empty
if [ ${#TEST_FILES[@]} -eq 0 ]; then
    echo "No test files found."
    exit 0
fi

for file in "${TEST_FILES[@]}"; do
    if [ -f "$file" ]; then
        # Check for problematic patterns
        MATCHES=$(grep -n "tester\.tap.*find\.text\|await.*tap.*find\.text\|\.tap(find\.text" "$file" 2>/dev/null || true)
        if [ -n "$MATCHES" ]; then
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