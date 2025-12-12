extends Node
## Automatically updates TOC.md with all .tscn and .gd files in the project

const TOC_PATH = "res://TOC.md"
const PROJECT_PATH = "c:/GoA/"  # Absolute path for clickable links

func _ready():
	update_toc()

func update_toc():
	var file_structure = {}

	# Scan for all .gd and .tscn files
	scan_directory("res://", file_structure)

	# Generate TOC content
	var content = generate_toc_content(file_structure)

	# Write to TOC.md
	var file = FileAccess.open(TOC_PATH, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("TOC.md updated successfully")
	else:
		push_error("Failed to write TOC.md")

func scan_directory(path: String, structure: Dictionary):
	var dir = DirAccess.open(path)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		var full_path = path + file_name

		# Skip hidden folders and .godot folder
		if file_name.begins_with(".") or file_name == ".godot":
			file_name = dir.get_next()
			continue

		if dir.current_is_dir():
			# Recursively scan subdirectories
			scan_directory(full_path + "/", structure)
		else:
			# Check if it's a .gd or .tscn file
			if file_name.ends_with(".gd") or file_name.ends_with(".tscn"):
				# Get the folder path
				var folder = path.replace("res://", "")
				if folder == "":
					folder = "root"

				if not structure.has(folder):
					structure[folder] = {"gd": [], "tscn": []}

				if file_name.ends_with(".gd"):
					structure[folder]["gd"].append(file_name)
				else:
					structure[folder]["tscn"].append(file_name)

		file_name = dir.get_next()

	dir.list_dir_end()

func generate_toc_content(structure: Dictionary) -> String:
	var content = "# GoA - Table of Contents\n\n"

	# Sort folders
	var folders = structure.keys()
	folders.sort()

	# Process root first
	if "root" in folders:
		content += generate_folder_section("Root", "root", structure["root"])
		folders.erase("root")

	# Process other folders
	for folder in folders:
		var folder_name = folder.replace("/", " > ").capitalize()
		content += generate_folder_section(folder_name, folder, structure[folder])

	return content

func generate_folder_section(title: String, folder_path: String, files: Dictionary) -> String:
	var section = "## " + title + "\n\n"

	# Scripts section
	if files["gd"].size() > 0:
		section += "### Scripts (.gd)\n"
		files["gd"].sort()
		for file in files["gd"]:
			var link_path = folder_path.replace("root", "") + file
			section += "- [%s](%s)  \n" % [link_path, link_path]
		section += "\n"

	# Scenes section
	if files["tscn"].size() > 0:
		section += "### Scenes (.tscn)\n"
		files["tscn"].sort()
		for file in files["tscn"]:
			var link_path = folder_path.replace("root", "") + file
			section += "- [%s](%s)  \n" % [link_path, link_path]
		section += "\n"

	section += "---\n\n"
	return section
