#!/bin/bash

# Check Clean Architecture layer boundaries
# Ensures domain layer doesn't import from application/presentation/features
# and application layer doesn't import from presentation/features

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

violations_found=0

echo "🏗️  Checking Clean Architecture layer boundaries..."

# Function to check for forbidden imports in a layer
check_layer_imports() {
    local layer_path="$1"
    local layer_name="$2"
    shift 2
    local forbidden_patterns=("$@")
    
    if [ ! -d "$layer_path" ]; then
        return 0
    fi
    
    for pattern in "${forbidden_patterns[@]}"; do
        # Find all .dart files in the layer and check for forbidden imports
        # Use extended regex to match both single and double quotes, import and export
        violations=$(find "$layer_path" -name "*.dart" -type f -exec grep -lE "(import|export) ['\"]package:piano_fitness/$pattern" {} \; 2>/dev/null || true)
        
        if [ -n "$violations" ]; then
            echo -e "${RED}❌ $layer_name layer violation detected!${NC}"
            echo -e "${YELLOW}Files importing from forbidden layer '$pattern':${NC}"
            echo "$violations" | while IFS= read -r file; do
                echo "  - $file"
                # Show the actual import lines
                grep -E --color=always "(import|export) ['\"]package:piano_fitness/$pattern" "$file" | sed 's/^/    /'
            done
            echo ""
            violations_found=$((violations_found + 1))
        fi
    done
}

# Check domain layer (should have no imports from application, presentation, or features)
check_layer_imports \
    "lib/domain" \
    "Domain" \
    "application/" "presentation/" "features/"

# Check domain layer for forbidden external package imports
if [ -d "lib/domain" ]; then
    # Allowed packages: dart:*, package:meta, package:collection, package:piano_fitness
    # Find imports to external packages (excluding allowed ones)
    forbidden_external=$(find "lib/domain" -name "*.dart" -type f -exec grep -lE "(import|export) ['\"]package:(flutter|provider|drift|riverpod)" {} \; 2>/dev/null || true)
    
    if [ -n "$forbidden_external" ]; then
        echo -e "${RED}❌ Domain layer external package violation detected!${NC}"
        echo -e "${YELLOW}Files importing forbidden external packages:${NC}"
        echo "$forbidden_external" | while IFS= read -r file; do
            echo "  - $file"
            # Show the actual import lines
            grep -E --color=always "(import|export) ['\"]package:(flutter|provider|drift|riverpod)" "$file" | sed 's/^/    /'
        done
        echo ""
        echo -e "${YELLOW}Domain layer can only import:${NC}"
        echo "  ✅ dart:* (core Dart libraries)"
        echo "  ✅ package:meta (for @immutable, etc.)"
        echo "  ✅ package:collection (for pure Dart collections)"
        echo "  ✅ package:piano_fitness/domain/* (internal domain imports)"
        echo "  ❌ NO Flutter or infrastructure packages"
        echo ""
        violations_found=$((violations_found + 1))
    fi
fi

# Check application layer (should have no imports from presentation or features)
check_layer_imports \
    "lib/application" \
    "Application" \
    "presentation/" "features/"

# Report results
if [ $violations_found -eq 0 ]; then
    echo -e "${GREEN}✅ All layer boundaries respected!${NC}"
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}Clean Architecture Violation Summary${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Layer dependency rules (dependencies must point inward only):"
    echo ""
    echo "  ┌─────────────────────────────────────┐"
    echo "  │  Features (Presentation Layer)      │ ← Can import from all layers"
    echo "  │  lib/features/                      │"
    echo "  └─────────────┬───────────────────────┘"
    echo "                │"
    echo "  ┌─────────────▼───────────────────────┐"
    echo "  │  Presentation Layer                 │ ← Can import from application & domain"
    echo "  │  lib/presentation/                  │"
    echo "  └─────────────┬───────────────────────┘"
    echo "                │"
    echo "  ┌─────────────▼───────────────────────┐"
    echo "  │  Application Layer                  │ ← Can import from domain only"
    echo "  │  lib/application/                   │"
    echo "  └─────────────┬───────────────────────┘"
    echo "                │"
    echo "  ┌─────────────▼───────────────────────┐"
    echo "  │  Domain Layer (Pure Dart)           │ ← Cannot import from any other layer"
    echo "  │  lib/domain/                        │"
    echo "  └─────────────────────────────────────┘"
    echo ""
    echo "To fix:"
    echo "  1. Move the importing code to a higher layer"
    echo "  2. Extract shared code to domain/application layer"
    echo "  3. Use dependency inversion (define interface in domain)"
    echo ""
    echo "See AGENTS.md for Clean Architecture guidelines."
    echo ""
    exit 1
fi
