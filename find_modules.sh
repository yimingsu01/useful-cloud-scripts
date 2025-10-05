#!/bin/bash

# Universal script to find Maven modules for failed test classes
# Works with any Maven multi-module or single-module project
# Usage: ./find_test_modules.sh <test_file>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <test_file>"
    echo "Example: $0 tests-20251003-010644.txt"
    echo ""
    echo "The test file should contain test class names in formats like:"
    echo "  - [INFO] com.example.package.TestClass#testMethod"
    echo "  - com.example.package.TestClass"
    echo "  - Full class names with or without method names"
    exit 1
fi

TEST_FILE="$1"

if [ ! -f "$TEST_FILE" ]; then
    echo "Error: Test file '$TEST_FILE' not found!"
    exit 1
fi

# Function to find the module for a given class
find_module_for_class() {
    local full_test_name="$1"
    local class_name
    local test_method=""
    
    # Extract class name and test method
    if echo "$full_test_name" | grep -q '#'; then
        class_name=$(echo "$full_test_name" | sed 's/#.*//')
        test_method=$(echo "$full_test_name" | sed 's/.*#//')
    else
        class_name="$full_test_name"
    fi
    
    # Convert package name to directory path
    local simple_class_name=$(basename "$class_name")
    
    # Search for exact test file matches
    local test_files=$(find . -name "${simple_class_name}.java" 2>/dev/null)
    
    if [ -n "$test_files" ]; then
        echo "$test_files" | while read -r file; do
            # Find the nearest pom.xml by walking up the directory tree
            local dir=$(dirname "$file")
            while [ "$dir" != "." ] && [ "$dir" != "/" ] && [ "$dir" != "" ]; do
                if [ -f "$dir/pom.xml" ]; then
                    # Output in the required format
                    if [ -n "$test_method" ]; then
                        echo "${class_name}.${test_method},${dir}"
                    else
                        echo "${class_name},${dir}"
                    fi
                    return
                fi
                dir=$(dirname "$dir")
            done
        done
        return
    fi
    
    # Fallback: search by package directory structure
    local package_path=$(echo "$class_name" | sed 's/\.[^.]*$//' | sed 's/\./\//g')
    local matching_dirs=$(find . -type d -path "*/$package_path" 2>/dev/null | head -1)
    
    if [ -n "$matching_dirs" ]; then
        local dir="$matching_dirs"
        while [ "$dir" != "." ] && [ "$dir" != "/" ] && [ "$dir" != "" ]; do
            if [ -f "$dir/pom.xml" ]; then
                if [ -n "$test_method" ]; then
                    echo "${class_name}.${test_method},${dir}"
                else
                    echo "${class_name},${dir}"
                fi
                return
            fi
            dir=$(dirname "$dir")
        done
    fi
    
    # If no module found, output with "UNKNOWN"
    if [ -n "$test_method" ]; then
        echo "${class_name}.${test_method},UNKNOWN"
    else
        echo "${class_name},UNKNOWN"
    fi
}

# Extract test class names from the file using multiple patterns

# Pattern 1: [INFO] package.Class#method format
grep -o '\[INFO\] [a-zA-Z][a-zA-Z0-9._]*[a-zA-Z0-9]#[a-zA-Z0-9_]*' "$TEST_FILE" | sed 's/\[INFO\] //g' | sort -u > /tmp/test_classes_1.txt 2>/dev/null || touch /tmp/test_classes_1.txt

# Pattern 2: [INFO] package.Class format (without method)
grep -o '\[INFO\] [a-zA-Z][a-zA-Z0-9._]*\.[A-Z][a-zA-Z0-9_]*' "$TEST_FILE" | sed 's/\[INFO\] //g' | grep -v '#' | sort -u > /tmp/test_classes_2.txt 2>/dev/null || touch /tmp/test_classes_2.txt

# Pattern 3: Direct class names with methods (package.Class#method format)
grep -o '[a-zA-Z][a-zA-Z0-9._]*\.[A-Z][a-zA-Z0-9_]*#[a-zA-Z0-9_]*' "$TEST_FILE" | grep -v '\.jar' | grep -v '\.xml' | sort -u > /tmp/test_classes_3.txt 2>/dev/null || touch /tmp/test_classes_3.txt

# Pattern 4: Direct class names (package.Class format)
grep -o '[a-zA-Z][a-zA-Z0-9._]*\.[A-Z][a-zA-Z0-9_]*' "$TEST_FILE" | grep -v '\.jar' | grep -v '\.xml' | grep -v '#' | sort -u > /tmp/test_classes_4.txt 2>/dev/null || touch /tmp/test_classes_4.txt

# Combine and deduplicate
cat /tmp/test_classes_1.txt /tmp/test_classes_2.txt /tmp/test_classes_3.txt /tmp/test_classes_4.txt | sort -u > /tmp/all_test_classes.txt

# Process each unique test class
if [ -s /tmp/all_test_classes.txt ]; then
    while read -r test_class; do
        # Skip empty lines and lines that don't look like class names
        if [ -n "$test_class" ] && echo "$test_class" | grep -q '\.' && echo "$test_class" | grep -q '[A-Z]'; then
            find_module_for_class "$test_class"
        fi
    done < /tmp/all_test_classes.txt
fi

# Cleanup
rm -f /tmp/test_classes_1.txt /tmp/test_classes_2.txt /tmp/test_classes_3.txt /tmp/test_classes_4.txt /tmp/all_test_classes.txt
