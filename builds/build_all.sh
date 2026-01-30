#!/bin/bash
set -e

# Pause on exit (success or error)
trap 'read -p "Press enter to continue..."' EXIT

# Navigate to project root (parent of builds/)
cd "$(dirname "$0")/.."

echo "=== Building ==="

GODOT="${GODOT:-Godot_v4.6-stable_win64.exe}"

RELEASE_PRESETS=(
    "Windows Desktop"
    "Windows Desktop Demo"
)

PACK_PRESETS=(
    "Assets Export"
    "Assets Export (Demo)"
)

for preset in "${RELEASE_PRESETS[@]}"; do
    echo "Exporting $preset..."
    $GODOT --headless --export-release "$preset"
done

for preset in "${PACK_PRESETS[@]}"; do
    echo "Exporting $preset..."
    $GODOT --headless --export-pack "$preset"
done

echo "=== Build Complete ==="
