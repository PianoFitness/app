#!/bin/sh
# Cross-platform script to validate conventional commit messages
# Works on Windows (Git Bash), macOS, and Linux

# Exit on any error
set -e

# Function to get commit type at index
get_commit_type() {
    case $1 in
        0) echo "feat" ;;
        1) echo "fix" ;;
        2) echo "docs" ;;
        3) echo "style" ;;
        4) echo "refactor" ;;
        5) echo "perf" ;;
        6) echo "test" ;;
        7) echo "build" ;;
        8) echo "ci" ;;
        9) echo "chore" ;;
        10) echo "revert" ;;
        *) echo "" ;;
    esac
}

# Function to get commit description at index
get_commit_description() {
    case $1 in
        0) echo "new feature for the user" ;;
        1) echo "bug fix for the user" ;;
        2) echo "changes to documentation" ;;
        3) echo "formatting, missing semi colons, etc; no code change" ;;
        4) echo "refactoring production code" ;;
        5) echo "performance improvements" ;;
        6) echo "adding missing tests, refactoring tests" ;;
        7) echo "changes to build system or external dependencies" ;;
        8) echo "changes to CI configuration files and scripts" ;;
        9) echo "updating grunt tasks etc; no production code change" ;;
        10) echo "reverting a previous commit" ;;
        *) echo "" ;;
    esac
}

# Build regex pattern from commit types
build_regex() {
    types=""
    i=0
    while true; do
        type=$(get_commit_type $i)
        if [ -z "$type" ]; then
            break
        fi
        if [ -n "$types" ]; then
            types="$types|$type"
        else
            types="$type"
        fi
        i=$((i + 1))
    done
    echo "^($types)(\\(.+\\))?: .{1,50}"
}

# Generate help text from commit types
generate_help() {
    echo "❌ Commit message should follow conventional commits format:"
    echo "   type(scope): description"
    echo ""
    echo "Allowed types:"
    
    i=0
    while true; do
        type=$(get_commit_type $i)
        desc=$(get_commit_description $i)
        if [ -z "$type" ]; then
            break
        fi
        printf "   %-8s - %s\n" "$type" "$desc"
        i=$((i + 1))
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
