#!/bin/sh
# Cross-platform script to validate conventional commit messages
# Works on Windows (Git Bash), macOS, and Linux

# Exit on any error
set -e

# Define commit types and their descriptions
# Format: "type:description"
COMMIT_TYPES="
feat:new feature for the user
fix:bug fix for the user
docs:changes to documentation
style:formatting, missing semi colons, etc; no code change
refactor:refactoring production code
perf:performance improvements
test:adding missing tests, refactoring tests
build:changes to build system or external dependencies
ci:changes to CI configuration files and scripts
chore:updating grunt tasks etc; no production code change
revert:reverting a previous commit
"

# Build regex pattern from commit types
build_regex() {
    types=""
    for line in $COMMIT_TYPES; do
        if [ -n "$line" ]; then
            type=$(echo "$line" | cut -d: -f1)
            if [ -n "$types" ]; then
                types="$types|$type"
            else
                types="$type"
            fi
        fi
    done
    echo "^($types)(\\(.+\\))?: .{1,50}"
}

# Generate help text from commit types
generate_help() {
    echo "❌ Commit message should follow conventional commits format:"
    echo "   type(scope): description"
    echo ""
    echo "Allowed types:"
    
    for line in $COMMIT_TYPES; do
        if [ -n "$line" ]; then
            type=$(echo "$line" | cut -d: -f1)
            desc=$(echo "$line" | cut -d: -f2-)
            printf "   %-8s - %s\n" "$type" "$desc"
        fi
    done
    
    echo ""
    echo "Examples:"
    echo "   feat(piano): add chord progression practice"
    echo "   fix(midi): resolve timing issues"
    echo "   docs: update README with lefthook setup"
    echo "   perf(audio): optimize MIDI processing"
    echo "   test(practice): add unit tests for chord validation"
    echo ""
}

# Main validation function
validate_commit_message() {
    commit_msg_file="$1"
    
    if [ -z "$commit_msg_file" ]; then
        echo "Error: No commit message file provided"
        exit 1
    fi
    
    if [ ! -f "$commit_msg_file" ]; then
        echo "Error: Commit message file not found: $commit_msg_file"
        exit 1
    fi
    
    commit_message=$(cat "$commit_msg_file")
    regex_pattern=$(build_regex)
    
    # Use grep for cross-platform regex matching
    if echo "$commit_message" | grep -qE "$regex_pattern"; then
        echo "✅ Commit message format is valid"
        exit 0
    else
        generate_help
        echo "Your message: $commit_message"
        exit 1
    fi
}

# Run validation
validate_commit_message "$1"
