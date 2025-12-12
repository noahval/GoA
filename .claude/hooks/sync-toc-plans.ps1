# Sync TOC plan numbering and create missing plans from template
# This script:
# 1. Parses TOC.md to extract line items with plan file references
# 2. Renames existing plan files to match TOC numbering
# 3. Creates new plan files from template (0.0-TEMPLATE.md) for missing plans
# 4. Detects orphaned plans (files with no TOC line) and prompts to archive them
# Note: [!] markers indicate incomplete plans and are managed manually by the user

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

    # Detect line items (1. feature-name or 1. [!] feature-name or blank 1. )
    if ($line -match '^\s*\d+\.\s+(?:\[!\]\s+)?(.*)$') {
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

# Build mapping of slug -> existing file
$slugToFile = @{}
foreach ($file in $existingPlans) {
    if ($file.Name -match '^\d+\.\d+-(.+)\.md$') {
        $slug = $matches[1]
        $slugToFile[$slug] = $file
    }
}

# Track renames and missing plans
$renames = @()
$missingPlans = @()
$createdPlans = @()
$matchedSlugs = @{}  # Track which slugs were matched to TOC lines

# Process each line item
foreach ($item in $lineItems) {
    $expectedFilename = "$($item.Number)-$($item.Slug).md"

    # Determine target folder based on section number (1.x goes to folder 1/, 2.x to 2/, etc.)
    $sectionFolder = Join-Path $PlansDir $item.Section
    $expectedPath = Join-Path $sectionFolder $expectedFilename

    if ($slugToFile.ContainsKey($item.Slug)) {
        $existingFile = $slugToFile[$item.Slug]
        $matchedSlugs[$item.Slug] = $true  # Mark this slug as matched

        # Check if rename/move is needed (name or location changed)
        if ($existingFile.FullName -ne $expectedPath) {
            # Ensure target folder exists
            if (-not (Test-Path $sectionFolder)) {
                New-Item -Path $sectionFolder -ItemType Directory -Force | Out-Null
            }

            $renames += @{
                OldPath = $existingFile.FullName
                NewPath = $expectedPath
                OldName = $existingFile.Name
                NewName = $expectedFilename
                OldFolder = $existingFile.DirectoryName
                NewFolder = $sectionFolder
            }
        }
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
$orphanedPlans = @()
foreach ($slug in $slugToFile.Keys) {
    if (-not $matchedSlugs.ContainsKey($slug)) {
        $orphanedPlans += $slugToFile[$slug]
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

Write-Host "${Cyan}=================================${Reset}"
Write-Host "${Green}Sync complete!${Reset}"
Write-Host "${Cyan}=================================${Reset}"
Write-Host ""
