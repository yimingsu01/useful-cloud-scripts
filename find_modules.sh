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

echo "Universal Maven Module Finder"
echo "============================="
echo "Analyzing test file: $TEST_FILE"
echo ""

# Function to extract artifact ID from pom.xml
get_artifact_id() {
    local pom_file="$1"
    if [ -f "$pom_file" ]; then
        grep -o '<artifactId>[^<]*</artifactId>' "$pom_file" | head -1 | sed 's/<[^>]*>//g'
    fi
}

# Function to get group ID from pom.xml
get_group_id() {
    local pom_file="$1"
    if [ -f "$pom_file" ]; then
        # Try to find groupId, considering parent groupId inheritance
        local group_id=$(grep -o '<groupId>[^<]*</groupId>' "$pom_file" | head -1 | sed 's/<[^>]*>//g')
        if [ -z "$group_id" ]; then
            # Look for parent groupId if local groupId not found
            group_id=$(grep -A 5 '<parent>' "$pom_file" | grep -o '<groupId>[^<]*</groupId>' | head -1 | sed 's/<[^>]*>//g')
        fi
        echo "$group_id"
    fi
}

# Function to find the module for a given class
find_module_for_class() {
    local class_name="$1"
    local found_any=false
    
    echo "Processing: $class_name"
    echo "----------------------------------------"
    
    # Convert package name to directory path
    local class_path=$(echo "$class_name" | sed 's/\./\//g')
    local simple_class_name=$(basename "$class_name")
    
    # Search strategies:
    # 1. Find exact test file matches
    local test_files=$(find . -name "${simple_class_name}.java" 2>/dev/null)
    
    if [ -n "$test_files" ]; then
        echo "Found test files:"
        echo "$test_files" | while read -r file; do
            echo "  📁 File: $file"
            
            # Find the nearest pom.xml by walking up the directory tree
            local dir=$(dirname "$file")
            while [ "$dir" != "." ] && [ "$dir" != "/" ] && [ "$dir" != "" ]; do
                if [ -f "$dir/pom.xml" ]; then
                    local artifact_id=$(get_artifact_id "$dir/pom.xml")
                    local group_id=$(get_group_id "$dir/pom.xml")
                    
                    echo "  📦 Module: $dir"
                    [ -n "$group_id" ] && echo "  🏷️  Group ID: $group_id"
                    [ -n "$artifact_id" ] && echo "  🎯 Artifact ID: $artifact_id"
                    
                    # Check if this is a test directory
                    if echo "$file" | grep -q "/test/"; then
                        echo "  ✅ Confirmed: Test file location"
                    fi
                    break
                fi
                dir=$(dirname "$dir")
            done
            echo ""
        done
        found_any=true
    fi
    
    # 2. Search by package directory structure
    if [ "$found_any" = false ]; then
        echo "  🔍 Searching by package structure..."
        
        # Try to find directories that match the package path
        local package_path=$(echo "$class_name" | sed 's/\.[^.]*$//' | sed 's/\./\//g')
        local matching_dirs=$(find . -type d -path "*/$package_path" 2>/dev/null | head -10)
        
        if [ -n "$matching_dirs" ]; then
            echo "  Found matching package directories:"
            echo "$matching_dirs" | while read -r pkg_dir; do
                echo "    📂 $pkg_dir"
                
                # Find nearest pom.xml
                local dir="$pkg_dir"
                while [ "$dir" != "." ] && [ "$dir" != "/" ] && [ "$dir" != "" ]; do
                    if [ -f "$dir/pom.xml" ]; then
                        local artifact_id=$(get_artifact_id "$dir/pom.xml")
                        local group_id=$(get_group_id "$dir/pom.xml")
                        
                        echo "      📦 Module: $dir"
                        [ -n "$group_id" ] && echo "      🏷️  Group ID: $group_id"
                        [ -n "$artifact_id" ] && echo "      🎯 Artifact ID: $artifact_id"
                        break
                    fi
                    dir=$(dirname "$dir")
                done
            done
            found_any=true
        fi
    fi
    
    # 3. Fallback: search for any files containing the class name
    if [ "$found_any" = false ]; then
        echo "  🔍 Fallback: Searching for references to class name..."
        local refs=$(find . -name "*.java" -exec grep -l "$simple_class_name" {} \; 2>/dev/null | head -5)
        
        if [ -n "$refs" ]; then
            echo "  Found references in:"
            echo "$refs" | while read -r ref_file; do
                echo "    📄 $ref_file"
                
                local dir=$(dirname "$ref_file")
                while [ "$dir" != "." ] && [ "$dir" != "/" ] && [ "$dir" != "" ]; do
                    if [ -f "$dir/pom.xml" ]; then
                        local artifact_id=$(get_artifact_id "$dir/pom.xml")
                        echo "      📦 Possible module: $dir ($artifact_id)"
                        break
                    fi
                    dir=$(dirname "$dir")
                done
            done
        else
            echo "  ❌ No matches found for: $class_name"
        fi
    fi
}

# Extract test class names from the file using multiple patterns
echo "Extracting test classes from file..."

# Pattern 1: [INFO] package.Class#method format
grep -o '\[INFO\] [a-zA-Z][a-zA-Z0-9._]*[a-zA-Z0-9]#' "$TEST_FILE" | sed 's/\[INFO\] //g' | sed 's/#.*//g' | sort -u > /tmp/test_classes_1.txt 2>/dev/null || touch /tmp/test_classes_1.txt

# Pattern 2: Direct class names (package.Class format)
grep -o '[a-zA-Z][a-zA-Z0-9._]*\.[A-Z][a-zA-Z0-9_]*' "$TEST_FILE" | grep -v '\.jar' | grep -v '\.xml' | sort -u > /tmp/test_classes_2.txt 2>/dev/null || touch /tmp/test_classes_2.txt

# Pattern 3: Class names that look like test classes (contain Test)
grep -o '[a-zA-Z][a-zA-Z0-9._]*Test[a-zA-Z0-9_]*' "$TEST_FILE" | sort -u > /tmp/test_classes_3.txt 2>/dev/null || touch /tmp/test_classes_3.txt

# Combine and deduplicate
cat /tmp/test_classes_1.txt /tmp/test_classes_2.txt /tmp/test_classes_3.txt | sort -u > /tmp/all_test_classes.txt

# Process each unique test class
if [ -s /tmp/all_test_classes.txt ]; then
    echo "Found $(wc -l < /tmp/all_test_classes.txt) unique test classes"
    echo ""
    
    while read -r test_class; do
        # Skip empty lines and lines that don't look like class names
        if [ -n "$test_class" ] && echo "$test_class" | grep -q '\.' && echo "$test_class" | grep -q '[A-Z]'; then
            find_module_for_class "$test_class"
            echo ""
        fi
    done < /tmp/all_test_classes.txt
else
    echo "❌ No test classes found in the file. Please check the file format."
    echo ""
    echo "Expected formats:"
    echo "  - [INFO] com.example.package.TestClass#testMethod"
    echo "  - com.example.package.TestClass"
    echo "  - Lines containing fully qualified class names"
fi

# Cleanup
rm -f /tmp/test_classes_1.txt /tmp/test_classes_2.txt /tmp/test_classes_3.txt /tmp/all_test_classes.txt

echo "================================="
echo "🏁 Module analysis complete!"
echo ""
echo "💡 Additional commands you can run:"
echo ""
echo "📋 List all modules in this project:"
echo "find . -name 'pom.xml' | while read pom; do"
echo "  dir=\$(dirname \"\$pom\")"
echo "  artifact=\$(grep -o '<artifactId>[^<]*</artifactId>' \"\$pom\" | head -1 | sed 's/<[^>]*>//g')"
echo "  echo \"Module: \$dir -> \$artifact\""
echo "done"
echo ""
echo "🔍 Search for a specific test class:"
echo "find . -name 'YourTestClass.java'"
echo ""
echo "📦 Find which module contains a specific package:"
echo "find . -type d -path '*/com/your/package' | while read dir; do"
echo "  while [ \"\$dir\" != \".\" ]; do"
echo "    [ -f \"\$dir/pom.xml\" ] && echo \"Package in module: \$dir\" && break"
echo "    dir=\$(dirname \"\$dir\")"
echo "  done"
echo "done"
