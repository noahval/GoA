extends SceneTree
## generate_currency_icons.gd
## Utility script to generate 64x64 currency icons from source images
## Usage: godot --headless --script res://generate_currency_icons.gd

const ICON_SIZE = 64
const SOURCE_DIR = "res://level1/"
const ICON_DIR = "res://level1/icons/"

const CURRENCIES = [
	{"name": "copper", "source": "copper.png", "icon": "copper_icon.png"},
	{"name": "silver", "source": "silver.png", "icon": "silver_icon.png"},
	{"name": "gold", "source": "gold.png", "icon": "gold_icon.png"},
	{"name": "platinum", "source": "platinum.png", "icon": "platinum_icon.png"}
]

func _initialize():
	print("\n" + "=".repeat(60))
	print("GENERATING CURRENCY ICONS (64x64)")
	print("=".repeat(60) + "\n")

	var success_count = 0
	var fail_count = 0

	for currency in CURRENCIES:
		print("Processing %s..." % currency.name)

		var source_path = SOURCE_DIR + currency.source
		var icon_path = ICON_DIR + currency.icon

		# Convert to absolute filesystem paths
		var source_abs = ProjectSettings.globalize_path(source_path)
		var icon_abs = ProjectSettings.globalize_path(icon_path)

		# Load source image
		var image = Image.new()
		var error = image.load(source_abs)

		if error != OK:
			print("  ✗ FAILED: Could not load %s (error code: %d)" % [source_path, error])
			fail_count += 1
			continue

		print("  - Loaded: %dx%d (%s KB)" % [image.get_width(), image.get_height(), "%.1f" % (FileAccess.get_file_as_bytes(source_abs).size() / 1024.0)])

		# Resize to 64x64 using Lanczos interpolation (best quality)
		image.resize(ICON_SIZE, ICON_SIZE, Image.INTERPOLATE_LANCZOS)
		print("  - Resized to: %dx%d" % [ICON_SIZE, ICON_SIZE])

		# Save as PNG
		error = image.save_png(icon_abs)

		if error != OK:
			print("  ✗ FAILED: Could not save %s (error code: %d)" % [icon_path, error])
			fail_count += 1
			continue

		# Check file size
		var icon_size_kb = FileAccess.get_file_as_bytes(icon_abs).size() / 1024.0
		print("  ✓ SUCCESS: Saved as %s (%.1f KB)" % [currency.icon, icon_size_kb])
		success_count += 1

	print("\n" + "=".repeat(60))
	print("COMPLETE: %d succeeded, %d failed" % [success_count, fail_count])
	print("=".repeat(60) + "\n")

	# Exit with appropriate code
	quit(0 if fail_count == 0 else 1)
