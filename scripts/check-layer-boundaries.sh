#!/bin/bash

# Check Clean Architecture layer boundaries.
#
# Two rules are enforced:
#
# 1. DIRECTIONAL RULE (hard): dependencies must point inward only.
#    Domain ← Application ← Presentation/Features
#    Domain files must never import from application/, presentation/, or features/.
#    Application files must never import from presentation/ or features/.
#
# 2. INFRASTRUCTURE-FREE DOMAIN (principle-based): the domain layer must not
#    couple itself to Flutter, UI frameworks, databases, hardware drivers, or
#    network clients. This is checked by scanning for direct imports of
#    package:flutter — the most common way infrastructure leaks into the domain.
#
#    This is NOT a strict allowlist. Pure Dart utility packages that carry no
#    transitive Flutter dependency are acceptable in the domain (e.g.
#    package:meta, package:collection, package:equatable). To verify that a
#    candidate package has no Flutter coupling before adding it to the domain,
#    run: dart pub deps | grep flutter
#    Empty output means no Flutter coupling; the package is safe to use.
#
#    If you need to convert between domain types and Flutter widget library
#    types, add an adapter in lib/application/utils/ instead (see
#    piano_note_bridge.dart as a canonical example).

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
        # Find all .dart files in the layer and check for forbidden imports.
        # Matches both single and double quotes, import and export statements,
        # and relative paths (../application/, ./features/, etc.).
        violations=$(find "$layer_path" -name "*.dart" -type f -exec grep -lE "(import|export) ['\"]((package:piano_fitness/|\.\./)$pattern|\./$pattern)" {} \; 2>/dev/null || true)

        if [ -n "$violations" ]; then
            echo -e "${RED}❌ $layer_name layer violation detected!${NC}"
            echo -e "${YELLOW}Files importing from forbidden layer '$pattern':${NC}"
            echo "$violations" | while IFS= read -r file; do
                echo "  - $file"
                grep -E --color=always "(import|export) ['\"]((package:piano_fitness/|\.\./)$pattern|\./$pattern)" "$file" | sed 's/^/    /'
            done
            echo ""
            violations_found=$((violations_found + 1))
        fi
    done
}

# Rule 1: directional dependency check.
# Domain must not import from application, presentation, or features.
check_layer_imports \
    "lib/domain" \
    "Domain" \
    "application/" "presentation/" "features/"

# Rule 2: infrastructure-free domain check.
# Scan domain files for direct Flutter package imports (package:flutter/* and
# package:flutter_*). These are the canonical signal that Flutter framework or
# plugin coupling has leaked into the domain.
#
# Pure Dart packages that do not have transitive Flutter dependencies are NOT
# flagged here — they are intentionally permitted in the domain layer.
if [ -d "lib/domain" ]; then
    flutter_violations=$(find "lib/domain" -name "*.dart" -type f \
        -exec grep -lE "(import|export) ['\"]package:flutter" {} \; 2>/dev/null || true)

    if [ -n "$flutter_violations" ]; then
        echo -e "${RED}❌ Domain layer Flutter coupling detected!${NC}"
        echo -e "${YELLOW}Domain files importing Flutter packages:${NC}"
        echo "$flutter_violations" | while IFS= read -r file; do
            echo "  - $file"
            grep -E --color=always "(import|export) ['\"]package:flutter" "$file" | sed 's/^/    /'
        done
        echo ""
        echo -e "${YELLOW}The domain layer must be free of Flutter and infrastructure coupling.${NC}"
        echo ""
        echo "  ✅ Allowed: dart:* core libraries"
        echo "  ✅ Allowed: pure Dart packages (verify: dart pub deps | grep flutter)"
        echo "  ✅ Allowed: package:piano_fitness/domain/* (internal imports)"
        echo "  ❌ Not allowed: package:flutter/* (Flutter framework)"
        echo "  ❌ Not allowed: package:flutter_* (Flutter plugins / widget libraries)"
        echo ""
        echo "To convert between domain types and Flutter widget types, create an"
        echo "adapter in lib/application/utils/ (see piano_note_bridge.dart)."
        echo ""
        violations_found=$((violations_found + 1))
    fi
fi

# Rule 1 continued: application must not import from presentation or features.
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
    echo "  │  Domain Layer (infrastructure-free) │ ← Cannot import from any outer layer"
    echo "  │  lib/domain/                        │   or Flutter/infrastructure packages"
    echo "  └─────────────────────────────────────┘"
    echo ""
    echo "To fix:"
    echo "  1. Move the importing code to a higher layer"
    echo "  2. Extract shared code to domain/application layer"
    echo "  3. Use dependency inversion (define interface in domain)"
    echo "  4. For Flutter widget type conversions, add an adapter in application/utils/"
    echo ""
    echo "See AGENTS.md for Clean Architecture guidelines."
    echo ""
    exit 1
fi
