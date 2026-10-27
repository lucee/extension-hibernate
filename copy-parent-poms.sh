#!/bin/bash

DEPENDENCY_DIR="$1"
M2_REPO="${HOME}/.m2/repository"
COPIED_TRACKER="${DEPENDENCY_DIR}/.parent_poms_copied"

echo "========================================"
echo "Copying parent POMs from local Maven repository"
echo "========================================"

# Create tracker file
mkdir -p "$DEPENDENCY_DIR"
> "$COPIED_TRACKER"

# Function to check if we've already copied this POM
is_already_copied() {
    grep -qx "$1" "$COPIED_TRACKER" 2>/dev/null
}

# Function to mark POM as copied
mark_as_copied() {
    echo "$1" >> "$COPIED_TRACKER"
}

# Function to recursively copy parent chain
copy_parent_chain() {
    pom_file="$1"
    
    # Check if POM exists
    if [ ! -f "$pom_file" ]; then
        return
    fi
    
    # Extract parent info (handles multi-line XML)
    parent_block=$(sed -n '/<parent>/,/<\/parent>/p' "$pom_file" | tr '\n' ' ')
    
    if [ -z "$parent_block" ]; then
        return  # No parent, stop recursion
    fi
    
    parent_group=$(echo "$parent_block" | sed -n 's/.*<groupId>\([^<]*\)<\/groupId>.*/\1/p' | head -1)
    parent_artifact=$(echo "$parent_block" | sed -n 's/.*<artifactId>\([^<]*\)<\/artifactId>.*/\1/p' | head -1)
    parent_version=$(echo "$parent_block" | sed -n 's/.*<version>\([^<]*\)<\/version>.*/\1/p' | head -1)
    
    # Validate we got all three values
    if [ -z "$parent_group" ] || [ -z "$parent_artifact" ] || [ -z "$parent_version" ]; then
        return
    fi
    
    # Create unique key for this POM (safe for file storage)
    pom_key="${parent_group}__${parent_artifact}__${parent_version}"
    
    # Skip if already copied
    if is_already_copied "$pom_key"; then
        return
    fi
    
    # Convert group ID to path
    parent_path=$(echo "$parent_group" | tr '.' '/')
    
    # Source location in local Maven repo
    parent_pom="$M2_REPO/$parent_path/$parent_artifact/$parent_version/$parent_artifact-$parent_version.pom"
    
    # Target location in dependency directory
    target_dir="$DEPENDENCY_DIR/$parent_path/$parent_artifact/$parent_version"
    
    if [ -f "$parent_pom" ]; then
        mkdir -p "$target_dir"
        cp "$parent_pom" "$target_dir/"
        echo "✓ Copied: $parent_artifact:$parent_version"
        
        # Mark as copied
        mark_as_copied "$pom_key"
        
        # Recursively copy this parent's parent
        copy_parent_chain "$parent_pom"
    else
        echo "✗ NOT FOUND in local repo: $parent_artifact:$parent_version"
        echo "  Expected at: $parent_pom"
    fi
}

# Copy the BOMs a POM imports (<scope>import</scope> in dependencyManagement, e.g.
# hibernate-platform for hibernate-core 7.4) plus their parent chain, so the
# bundled repository can resolve the managed versions without a download.
# Imports whose version is a property (e.g. ${version.org.junit}) are skipped.
copy_imported_boms() {
    pom_file="$1"
    tr '\n' ' ' < "$pom_file" | sed 's|</dependency>|</dependency>\n|g' | grep '<scope>import</scope>' | while read dep; do
        bom_group=$(echo "$dep" | sed -n 's/.*<groupId>\([^<]*\)<\/groupId>.*/\1/p' | head -1)
        bom_artifact=$(echo "$dep" | sed -n 's/.*<artifactId>\([^<]*\)<\/artifactId>.*/\1/p' | head -1)
        bom_version=$(echo "$dep" | sed -n 's/.*<version>\([^<]*\)<\/version>.*/\1/p' | head -1)
        if [ -z "$bom_group" ] || [ -z "$bom_artifact" ] || [ -z "$bom_version" ]; then
            continue
        fi
        case "$bom_version" in *'${'*) continue ;; esac
        bom_key="${bom_group}__${bom_artifact}__${bom_version}"
        if is_already_copied "$bom_key"; then
            continue
        fi
        bom_path=$(echo "$bom_group" | tr '.' '/')
        bom_pom="$M2_REPO/$bom_path/$bom_artifact/$bom_version/$bom_artifact-$bom_version.pom"
        target_dir="$DEPENDENCY_DIR/$bom_path/$bom_artifact/$bom_version"
        if [ -f "$bom_pom" ]; then
            mkdir -p "$target_dir"
            cp "$bom_pom" "$target_dir/"
            echo "✓ Copied BOM: $bom_artifact:$bom_version"
            mark_as_copied "$bom_key"
            copy_parent_chain "$bom_pom"
        else
            echo "✗ BOM NOT FOUND in local repo: $bom_artifact:$bom_version"
            echo "  Expected at: $bom_pom"
        fi
    done
}

# Find all POM files and process each
find "$DEPENDENCY_DIR" -name "*.pom" -type f | while read pom; do
    copy_parent_chain "$pom"
    copy_imported_boms "$pom"
done

# Clean up tracker file
rm -f "$COPIED_TRACKER"

echo "========================================"
echo "Parent POM copy complete"
echo "========================================"
