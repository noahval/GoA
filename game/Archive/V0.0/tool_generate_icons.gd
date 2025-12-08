@tool
extends EditorScript
## tool_generate_icons.gd
## Tool script to generate 64x64 currency icons
## Run from Godot Editor: File → Run (or Ctrl+Shift+X) while this script is open

const ICON_SIZE = 64
const SOURCE_DIR = "res://level1/"
const ICON_DIR = "res://level1/icons/"

const CURRENCIES = [
	{"name": "copper", "source": "copper.png", "icon": "copper_icon.png"},
	{"name": "silver", "source": "silver.png", "icon": "silver_icon.png"},
	{"name": "gold", "source": "gold.png", "icon": "gold_icon.png"},
	{"name": "platinum", "source": "platinum.png", "icon": "platinum_icon.png"}
]

func _run():
	print("\n" + "=".repeat(60))
	print("GENERATING CURRENCY ICONS (64x64)")
	print("=".repeat(60) + "\n")

	# Ensure icon directory exists
	var dir = DirAccess.open("res://level1/")
	if not dir.dir_exists("icons"):
		dir.make_dir("icons")
		print("Created icons directory\n")

	var success_count = 0
	var fail_count = 0

	for currency in CURRENCIES:
		print("Processing %s..." % currency.name)

		var source_path = SOURCE_DIR + currency.source
		var icon_path = ICON_DIR + currency.icon

		# Load source image
		var source_texture = load(source_path)
		if not source_texture:
			print("  ✗ FAILED: Could not load %s" % source_path)
			fail_count += 1
			continue

		var source_image = source_texture.get_image()
		if not source_image:
			print("  ✗ FAILED: Could not get image data from %s" % source_path)
			fail_count += 1
			continue

		print("  - Loaded: %dx%d" % [source_image.get_width(), source_image.get_height()])

		# Resize to 64x64 using Lanczos interpolation (best quality)
		source_image.resize(ICON_SIZE, ICON_SIZE, Image.INTERPOLATE_LANCZOS)
		print("  - Resized to: %dx%d" % [ICON_SIZE, ICON_SIZE])

		# Save as PNG
		var abs_path = ProjectSettings.globalize_path(icon_path)
		var error = source_image.save_png(abs_path)

		if error != OK:
			print("  ✗ FAILED: Could not save %s (error: %d)" % [icon_path, error])
			fail_count += 1
			continue

		print("  ✓ SUCCESS: Saved as %s" % currency.icon)
		success_count += 1

	print("\n" + "=".repeat(60))
	if fail_count == 0:
		print("✓ COMPLETE: All %d icons generated successfully!" % success_count)
	else:
		print("COMPLETE: %d succeeded, %d failed" % [success_count, fail_count])
	print("=".repeat(60) + "\n")
	print("NOTE: You may need to refresh the FileSystem dock (right-click → Reimport)")
