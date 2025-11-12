#!/usr/bin/env python3
"""
generate_currency_icons.py
Utility script to generate 64x64 currency icons from source images
Requires: Pillow (pip install Pillow)
Usage: python generate_currency_icons.py
"""

import os
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("ERROR: Pillow library not found!")
    print("Please install it with: pip install Pillow")
    exit(1)

ICON_SIZE = (64, 64)
SOURCE_DIR = Path("level1")
ICON_DIR = Path("level1/icons")

CURRENCIES = [
    {"name": "copper", "source": "copper.png", "icon": "copper_icon.png"},
    {"name": "silver", "source": "silver.png", "icon": "silver_icon.png"},
    {"name": "gold", "source": "gold.png", "icon": "gold_icon.png"},
    {"name": "platinum", "source": "platinum.png", "icon": "platinum_icon.png"}
]

def main():
    print("\n" + "=" * 60)
    print("GENERATING CURRENCY ICONS (64x64)")
    print("=" * 60 + "\n")

    # Create icon directory if it doesn't exist
    ICON_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Icon directory: {ICON_DIR.absolute()}\n")

    success_count = 0
    fail_count = 0

    for currency in CURRENCIES:
        print(f"Processing {currency['name']}...")

        source_path = SOURCE_DIR / currency["source"]
        icon_path = ICON_DIR / currency["icon"]

        # Check if source exists
        if not source_path.exists():
            print(f"  ✗ FAILED: Source file not found: {source_path}")
            fail_count += 1
            continue

        try:
            # Load source image
            img = Image.open(source_path)
            source_size_kb = source_path.stat().st_size / 1024
            print(f"  - Loaded: {img.width}x{img.height} ({source_size_kb:.1f} KB)")

            # Resize using high-quality Lanczos resampling
            img_resized = img.resize(ICON_SIZE, Image.Resampling.LANCZOS)
            print(f"  - Resized to: {ICON_SIZE[0]}x{ICON_SIZE[1]}")

            # Save as PNG
            img_resized.save(icon_path, "PNG", optimize=True)

            # Check file size
            icon_size_kb = icon_path.stat().st_size / 1024
            print(f"  ✓ SUCCESS: Saved as {icon_path.name} ({icon_size_kb:.1f} KB)")
            success_count += 1

        except Exception as e:
            print(f"  ✗ FAILED: {str(e)}")
            fail_count += 1
            continue

        print()

    print("=" * 60)
    print(f"COMPLETE: {success_count} succeeded, {fail_count} failed")
    print("=" * 60 + "\n")

    return 0 if fail_count == 0 else 1

if __name__ == "__main__":
    exit(main())
