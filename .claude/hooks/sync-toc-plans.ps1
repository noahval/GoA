# Sync TOC plan numbering and create missing plans from template
# This script:
# 1. Parses TOC.md to extract line items with plan file references
# 2. Renames existing plan files to match TOC numbering
# 3. Creates new plan files from template (0.0-TEMPLATE.md) for missing plans
# 4. Detects orphaned plans (files with no TOC line) and prompts to archive them
# 5. Auto-adds [D] markers to TOC lines that have corresponding folders
# Note: [!] markers indicate incomplete plans and are managed manually by the user
# Note: [D] markers indicate the plan is a folder containing multiple sub-plans

param(
    [string]$TocPath = "c:\GoA\.claude\docs\TOC.md",
    [string]$PlansDir = "c:\GoA\.claude\plans"
)

# ANSI color codes for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host ""
Write-Host "${Cyan}=================================${Reset}"
Write-Host "${Cyan}   TOC Plan Sync${Reset}"
Write-Host "${Cyan}=================================${Reset}"
Write-Host ""

# Read TOC content
if (-not (Test-Path $TocPath)) {
    Write-Host "${Red}ERROR: TOC.md not found at $TocPath${Reset}"
    exit 1
}

$tocLines = Get-Content $TocPath

# Parse TOC to extract line items
# Format: "1. feature-name - Description" or "1. [!] feature-name - Description"
$lineItems = @()
$currentSection = 0
$subsectionCounter = 0

foreach ($line in $tocLines) {
    # Detect section headers (## N. section name)
    if ($line -match '^\s*##\s+(\d+)\.\s+(.+)$') {
        $currentSection = [int]$matches[1]
        $subsectionCounter = 0  # Reset counter for new section
        continue
    }

    # Detect line items (1. feature-name or 1. [!] feature-name or 1. [D] feature-name or blank 1. )
    if ($line -match '^\s*\d+\.\s+(?:\[!\]\s+)?(?:\[D\]\s+)?(.*)$') {
        $subsectionCounter++
        $rest = $matches[1]

        # Skip processing if blank line item
        if ($rest.Trim() -eq '') {
            continue
        }

        # Extract feature name (everything before " - " or end of line)
        if ($rest -match '^(.+?)\s+-') {
            $featureName = $matches[1].Trim()
        } else {
            $featureName = $rest.Trim()
        }

        # Convert to filename format (lowercase, spaces to hyphens)
        $slug = $featureName.ToLower() -replace '\s+', '-' -replace '[^a-z0-9-]', ''

        $lineItems += @{
            Section = $currentSection
            Subsection = $subsectionCounter
            Number = "$currentSection.$subsectionCounter"
            FeatureName = $featureName
            Slug = $slug
            OriginalLine = $line
        }
    }
}

Write-Host "${Blue}Found $($lineItems.Count) line items in TOC${Reset}"
Write-Host ""

# Find existing plan files (recursively scan subdirectories)
$existingPlans = Get-ChildItem -Path $PlansDir -Filter "*.md" -Recurse | Where-Object { $_.Name -match '^\d+\.\d+-.+\.md$' }

# Find existing plan folders (format: N.N-name/)
$existingFolders = Get-ChildItem -Path $PlansDir -Directory -Recurse | Where-Object { $_.Name -match '^\d+\.\d+-.+$' }

# Build mapping of slug -> existing file
$slugToFile = @{}
# Build mapping of slug -> existing folder
$slugToFolder = @{}
# Track files in named subfolders (e.g., 2.18-dishwash/) for grouping
$subfolderFiles = @{}

foreach ($folder in $existingFolders) {
    if ($folder.Name -match '^\d+\.\d+-(.+)$') {
        $slug = $matches[1]
        $slugToFolder[$slug] = $folder
    }
}

foreach ($file in $existingPlans) {
    # Match both standard format (N.N-slug.md) and subfolder format (N.N.N-slug.md)
    if ($file.Name -match '^(\d+\.\d+(?:\.\d+)?)-(.+)\.md$') {
        $slug = $matches[2]
        $slugToFile[$slug] = $file

        # Check if file is in a named subfolder (format: N.N-name/)
        $parentFolder = Split-Path -Leaf $file.DirectoryName
        if ($parentFolder -match '^\d+\.\d+-(.+)$') {
            $folderSlug = $matches[1]
            if (-not $subfolderFiles.ContainsKey($folderSlug)) {
                $subfolderFiles[$folderSlug] = @()
            }
            $subfolderFiles[$folderSlug] += $slug
        }
    }
}

# Track renames and missing plans
$renames = @()
$folderRenames = @()
$missingPlans = @()
$createdPlans = @()
$matchedSlugs = @{}  # Track which slugs were matched to TOC lines

# Process each line item
foreach ($item in $lineItems) {
    $expectedFilename = "$($item.Number)-$($item.Slug).md"

    # Determine target folder based on section number (1.x goes to folder 1/, 2.x to 2/, etc.)
    $sectionFolder = Join-Path $PlansDir $item.Section

    if ($slugToFile.ContainsKey($item.Slug)) {
        $existingFile = $slugToFile[$item.Slug]
        $matchedSlugs[$item.Slug] = $true  # Mark this slug as matched

        # Keep file in its current folder (support for subfolders within section folders)
        # Only rename if the filename changed, don't move between folders
        $currentFolder = $existingFile.DirectoryName
        $expectedPath = Join-Path $currentFolder $expectedFilename

        # Check if rename is needed (filename changed)
        if ($existingFile.FullName -ne $expectedPath) {
            $renames += @{
                OldPath = $existingFile.FullName
                NewPath = $expectedPath
                OldName = $existingFile.Name
                NewName = $expectedFilename
                OldFolder = $currentFolder
                NewFolder = $currentFolder
            }
        }
    } elseif ($slugToFolder.ContainsKey($item.Slug)) {
        # A folder exists for this TOC entry (e.g., 2.18-dishwash/ for "dishwash")
        $matchedSlugs[$item.Slug] = $true
        $existingFolder = $slugToFolder[$item.Slug]
        $expectedFolderName = "$($item.Number)-$($item.Slug)"
        $sectionFolder = Join-Path $PlansDir $item.Section
        $expectedFolderPath = Join-Path $sectionFolder $expectedFolderName

        # Check if folder needs renaming
        if ($existingFolder.FullName -ne $expectedFolderPath) {
            $folderRenames += @{
                OldPath = $existingFolder.FullName
                NewPath = $expectedFolderPath
                OldName = $existingFolder.Name
                NewName = $expectedFolderName
            }
        }
    } elseif ($subfolderFiles.ContainsKey($item.Slug)) {
        # Files exist in a subfolder for this TOC entry
        $matchedSlugs[$item.Slug] = $true
    } else {
        # No plan file exists for this item
        $missingPlans += $item
    }
}

# Perform renames/moves
if ($renames.Count -gt 0) {
    Write-Host "${Yellow}Renaming/moving $($renames.Count) plan file(s) to match TOC numbering:${Reset}"
    foreach ($rename in $renames) {
        try {
            Move-Item -Path $rename.OldPath -Destination $rename.NewPath -Force

            # Show appropriate message based on whether folder changed
            if ($rename.OldFolder -ne $rename.NewFolder) {
                $oldRelative = Split-Path -Leaf $rename.OldFolder
                $newRelative = Split-Path -Leaf $rename.NewFolder
                Write-Host "  ${Green}[MOVED]${Reset} $oldRelative/$($rename.OldName) -> $newRelative/$($rename.NewName)"
            } else {
                Write-Host "  ${Green}[RENAMED]${Reset} $($rename.OldName) -> $($rename.NewName)"
            }
        } catch {
            Write-Host "  ${Red}[ERROR]${Reset} Failed to move $($rename.OldName): $_"
        }
    }
    Write-Host ""
} else {
    Write-Host "${Green}All plan files already have correct numbering and locations${Reset}"
    Write-Host ""
}

# Perform folder renames
if ($folderRenames.Count -gt 0) {
    Write-Host "${Yellow}Renaming $($folderRenames.Count) plan folder(s) to match TOC numbering:${Reset}"
    foreach ($rename in $folderRenames) {
        try {
            Move-Item -Path $rename.OldPath -Destination $rename.NewPath -Force
            Write-Host "  ${Green}[RENAMED]${Reset} $($rename.OldName)/ -> $($rename.NewName)/"
        } catch {
            Write-Host "  ${Red}[ERROR]${Reset} Failed to rename folder $($rename.OldName): $_"
        }
    }
    Write-Host ""
} else {
    Write-Host "${Green}All plan folders already have correct numbering${Reset}"
    Write-Host ""
}

# Renumber files inside subfolders using decimal notation (N.N.1, N.N.2, etc.)
$subfolderRenames = @()

# Get all plan folders (after any renames above)
$allPlanFolders = Get-ChildItem -Path $PlansDir -Directory -Recurse | Where-Object { $_.Name -match '^\d+\.\d+-.+$' }

foreach ($folder in $allPlanFolders) {
    if ($folder.Name -match '^(\d+\.\d+)-(.+)$') {
        $folderNumber = $matches[1]
        $folderSlug = $matches[2]

        # Get all .md files in this folder, sorted by original number (N.N or N.N.N)
        $filesInFolder = Get-ChildItem -Path $folder.FullName -Filter "*.md" | Sort-Object {
            if ($_.Name -match '^(\d+)\.(\d+)(?:\.(\d+))?-.+\.md$') {
                # Convert to sortable number: major*10000 + minor*100 + sub (if exists)
                $major = [int]$matches[1]
                $minor = [int]$matches[2]
                $sub = if ($matches[3]) { [int]$matches[3] } else { 0 }
                $major * 10000 + $minor * 100 + $sub
            } else { 999999 }
        }

        $subIndex = 1
        foreach ($file in $filesInFolder) {
            # Extract slug from filename (handles both N.N-slug and N.N.N-slug formats)
            if ($file.Name -match '^\d+\.\d+(?:\.\d+)?-(.+)\.md$') {
                $fileSlug = $matches[1]
                $expectedFilename = "$folderNumber.$subIndex-$fileSlug.md"
                $expectedPath = Join-Path $folder.FullName $expectedFilename

                if ($file.FullName -ne $expectedPath) {
                    $subfolderRenames += @{
                        OldPath = $file.FullName
                        NewPath = $expectedPath
                        OldName = $file.Name
                        NewName = $expectedFilename
                        FolderName = $folder.Name
                    }
                }
                $subIndex++
            }
        }
    }
}

# Perform subfolder file renames
if ($subfolderRenames.Count -gt 0) {
    Write-Host "${Yellow}Renumbering $($subfolderRenames.Count) file(s) inside subfolders with decimal notation:${Reset}"
    foreach ($rename in $subfolderRenames) {
        try {
            Move-Item -Path $rename.OldPath -Destination $rename.NewPath -Force
            Write-Host "  ${Green}[RENUMBERED]${Reset} $($rename.FolderName)/$($rename.OldName) -> $($rename.NewName)"
        } catch {
            Write-Host "  ${Red}[ERROR]${Reset} Failed to renumber $($rename.OldName): $_"
        }
    }
    Write-Host ""
} else {
    Write-Host "${Green}All subfolder files already have correct decimal numbering${Reset}"
    Write-Host ""
}

# Create plan files from template for missing plans
$templatePath = Join-Path $PlansDir "0.0-TEMPLATE.md"

if ($missingPlans.Count -gt 0 -and (Test-Path $templatePath)) {
    Write-Host "${Yellow}Creating $($missingPlans.Count) plan file(s) from template:${Reset}"

    foreach ($missing in $missingPlans) {
        $expectedFilename = "$($missing.Number)-$($missing.Slug).md"
        $sectionFolder = Join-Path $PlansDir $missing.Section
        $expectedPath = Join-Path $sectionFolder $expectedFilename

        try {
            # Ensure target folder exists
            if (-not (Test-Path $sectionFolder)) {
                New-Item -Path $sectionFolder -ItemType Directory -Force | Out-Null
            }

            # Copy template to new location
            Copy-Item -Path $templatePath -Destination $expectedPath -Force

            $relativePath = "$($missing.Section)/$expectedFilename"
            Write-Host "  ${Green}[CREATED]${Reset} $relativePath"

            # Track created plans
            $createdPlans += $missing
        } catch {
            Write-Host "  ${Red}[ERROR]${Reset} Failed to create $expectedFilename`: $_"
        }
    }
    Write-Host ""
} elseif ($missingPlans.Count -gt 0) {
    Write-Host "${Yellow}Note: $($missingPlans.Count) plan file(s) missing but template not found at:${Reset}"
    Write-Host "  $templatePath"
    Write-Host ""
} else {
    Write-Host "${Green}All line items have corresponding plan files${Reset}"
    Write-Host ""
}

# Detect orphaned plans (plans with no corresponding TOC line)
# Plans in named subfolders are not orphaned if the folder matches a TOC entry
$orphanedPlans = @()
foreach ($slug in $slugToFile.Keys) {
    if (-not $matchedSlugs.ContainsKey($slug)) {
        $file = $slugToFile[$slug]
        $parentFolder = Split-Path -Leaf $file.DirectoryName

        # Check if file is in a named subfolder that matches a TOC entry
        $isGrouped = $false
        if ($parentFolder -match '^\d+\.\d+-(.+)$') {
            $folderSlug = $matches[1]
            if ($matchedSlugs.ContainsKey($folderSlug)) {
                $isGrouped = $true  # File is grouped under a TOC entry via its folder
            }
        }

        if (-not $isGrouped) {
            $orphanedPlans += $file
        }
    }
}

# Handle orphaned plans
if ($orphanedPlans.Count -gt 0) {
    Write-Host "${Yellow}Found $($orphanedPlans.Count) orphaned plan file(s) with no TOC line:${Reset}"
    foreach ($orphan in $orphanedPlans) {
        $relativeFolder = Split-Path -Leaf (Split-Path -Parent $orphan.FullName)
        Write-Host "  ${Yellow}[ORPHAN]${Reset} $relativeFolder/$($orphan.Name)"
    }
    Write-Host ""

    # Prompt user for archive confirmation
    $response = Read-Host "Archive these orphaned plans? [y/n]"

    if ($response -eq 'y' -or $response -eq 'Y') {
        $archiveDir = Join-Path $PlansDir "archive"
        $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
        $archiveSubDir = Join-Path $archiveDir $timestamp

        # Create archive directory
        if (-not (Test-Path $archiveSubDir)) {
            New-Item -Path $archiveSubDir -ItemType Directory -Force | Out-Null
        }

        Write-Host "${Yellow}Archiving orphaned plans to archive/$timestamp/:${Reset}"
        foreach ($orphan in $orphanedPlans) {
            try {
                $destinationPath = Join-Path $archiveSubDir $orphan.Name
                Move-Item -Path $orphan.FullName -Destination $destinationPath -Force
                Write-Host "  ${Green}[ARCHIVED]${Reset} $($orphan.Name)"
            } catch {
                Write-Host "  ${Red}[ERROR]${Reset} Failed to archive $($orphan.Name): $_"
            }
        }
        Write-Host ""
    } else {
        Write-Host "${Blue}Skipped archiving orphaned plans${Reset}"
        Write-Host ""
    }
}

# Detect plan folders and update TOC with [D] markers
$planFolders = Get-ChildItem -Path $PlansDir -Directory -Recurse | Where-Object { $_.Name -match '^\d+\.\d+-.+$' }

# Build set of folder slugs
$folderSlugs = @{}
foreach ($folder in $planFolders) {
    if ($folder.Name -match '^\d+\.\d+-(.+)$') {
        $folderSlugs[$matches[1]] = $true
    }
}

# Check if any TOC lines need [D] markers added
$tocUpdated = $false
$newTocLines = @()

foreach ($line in $tocLines) {
    $newLine = $line

    # Check if this is a line item that should have [D] marker
    if ($line -match '^(\s*\d+\.\s+)(?:\[!\]\s+)?(?!\[D\])(.+)$') {
        $prefix = $matches[1]
        $rest = $matches[2]

        # Extract feature name to get slug
        if ($rest -match '^(.+?)\s+-') {
            $featureName = $matches[1].Trim()
        } else {
            $featureName = $rest.Trim()
        }

        $slug = $featureName.ToLower() -replace '\s+', '-' -replace '[^a-z0-9-]', ''

        # If a folder exists for this slug and line doesn't have [D], add it
        if ($folderSlugs.ContainsKey($slug)) {
            $newLine = "${prefix}[D] $rest"
            $tocUpdated = $true
            Write-Host "  ${Green}[D ADDED]${Reset} $featureName"
        }
    }

    $newTocLines += $newLine
}

# Write updated TOC if changes were made
if ($tocUpdated) {
    Write-Host ""
    Write-Host "${Yellow}Updating TOC.md with [D] folder markers...${Reset}"
    $newTocLines | Set-Content $TocPath -Encoding UTF8
    Write-Host "${Green}TOC.md updated${Reset}"
    Write-Host ""
}

Write-Host "${Cyan}=================================${Reset}"
Write-Host "${Green}Sync complete!${Reset}"
Write-Host "${Cyan}=================================${Reset}"
Write-Host ""
