# TOC Change Detection Hook
# Runs after Write/Edit tools to detect TOC.md changes and sync plans

# Read the tool use arguments from stdin (JSON)
$input_json = $input | Out-String

# Parse JSON to extract file_path if present
try {
    $params = $input_json | ConvertFrom-Json
    $file_path = $params.file_path
} catch {
    # If parsing fails or no file_path, exit silently
    exit 0
}

# Check if the modified file is TOC.md
if ($file_path -like "*TOC.md" -or $file_path -like "*toc.md") {
    # Run the sync script
    & "c:\GoA\.claude\hooks\sync-toc-plans.ps1"
} else {
    # Not TOC.md, exit silently
    exit 0
}
