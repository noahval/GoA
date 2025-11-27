# Sync TOC plan numbering and add markers for missing plans
# This script:
# 1. Parses TOC.md to extract line items with plan file references
# 2. Renames existing plan files to match TOC numbering
# 3. Adds [!] markers to TOC for missing plan files

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

$tocContent = Get-Content $TocPath -Raw
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

    # Detect line items (1. feature-name or 1. [!] feature-name)
    if ($line -match '^\s*\d+\.\s+(?:\[!\]\s+)?(.+)$') {
        $subsectionCounter++
        $rest = $matches[1].Trim()

        # Extract feature name (everything before " - " or end of line)
        if ($rest -match '^(.+?)\s+-\s+') {
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

# Find existing plan files
$existingPlans = Get-ChildItem -Path $PlansDir -Filter "*.md" | Where-Object { $_.Name -match '^\d+\.\d+-.+\.md$' }

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

# Process each line item
foreach ($item in $lineItems) {
    $expectedFilename = "$($item.Number)-$($item.Slug).md"
    $expectedPath = Join-Path $PlansDir $expectedFilename

    if ($slugToFile.ContainsKey($item.Slug)) {
        $existingFile = $slugToFile[$item.Slug]

        # Check if rename is needed
        if ($existingFile.Name -ne $expectedFilename) {
            $renames += @{
                OldPath = $existingFile.FullName
                NewPath = $expectedPath
                OldName = $existingFile.Name
                NewName = $expectedFilename
            }
        }
    } else {
        # No plan file exists for this item
        $missingPlans += $item
    }
}

# Perform renames
if ($renames.Count -gt 0) {
    Write-Host "${Yellow}Renaming $($renames.Count) plan file(s) to match TOC numbering:${Reset}"
    foreach ($rename in $renames) {
        try {
            Move-Item -Path $rename.OldPath -Destination $rename.NewPath -Force
            Write-Host "  ${Green}[RENAMED]${Reset} $($rename.OldName) -> $($rename.NewName)"
        } catch {
            Write-Host "  ${Red}[ERROR]${Reset} Failed to rename $($rename.OldName): $_"
        }
    }
    Write-Host ""
} else {
    Write-Host "${Green}All plan files already have correct numbering${Reset}"
    Write-Host ""
}

# Update TOC with [!] markers for missing plans
if ($missingPlans.Count -gt 0) {
    Write-Host "${Yellow}Adding [!] markers for $($missingPlans.Count) missing plan file(s):${Reset}"

    $newTocLines = @()
    $lineIndex = 0
    $modified = $false

    foreach ($line in $tocLines) {
        # Check if this line matches a missing plan item
        $matchedMissing = $null
        foreach ($missing in $missingPlans) {
            if ($line -eq $missing.OriginalLine) {
                $matchedMissing = $missing
                break
            }
        }

        if ($matchedMissing) {
            # Add [!] marker if not already present
            if ($line -notmatch '\[!\]') {
                # Insert [!] after the number
                $markedLine = $line -replace '(^\s*\d+\.)\s+', '$1 [!] '
                $newTocLines += $markedLine
                Write-Host "  ${Yellow}[MARKED]${Reset} $($matchedMissing.Number). $($matchedMissing.FeatureName)"
                $modified = $true
            } else {
                $newTocLines += $line
            }
        } else {
            # Check if line has [!] but shouldn't (plan file now exists)
            if ($line -match '^\s*(\d+)\.\s+\[!\]\s+(.+)$') {
                $subsection = [int]$matches[1]
                $rest = $matches[2]

                # Extract feature name
                if ($rest -match '^(.+?)\s+-\s+') {
                    $featureName = $matches[1].Trim()
                } else {
                    $featureName = $rest.Trim()
                }

                $slug = $featureName.ToLower() -replace '\s+', '-' -replace '[^a-z0-9-]', ''

                # Check if plan file exists for this slug
                if ($slugToFile.ContainsKey($slug)) {
                    # Remove [!] marker
                    $unmarkedLine = $line -replace '\[!\]\s+', ''
                    $newTocLines += $unmarkedLine
                    Write-Host "  ${Green}[UNMARKED]${Reset} Plan file now exists for: $featureName"
                    $modified = $true
                } else {
                    $newTocLines += $line
                }
            } else {
                $newTocLines += $line
            }
        }
    }

    # Write updated TOC if modified
    if ($modified) {
        $newTocContent = $newTocLines -join "`n"
        Set-Content -Path $TocPath -Value $newTocContent -NoNewline
        Write-Host ""
        Write-Host "${Green}TOC.md updated with markers${Reset}"
    } else {
        Write-Host "  ${Blue}All markers already up to date${Reset}"
    }
    Write-Host ""
} else {
    Write-Host "${Green}All line items have corresponding plan files${Reset}"
    Write-Host ""
}

Write-Host "${Cyan}=================================${Reset}"
Write-Host "${Green}Sync complete!${Reset}"
Write-Host "${Cyan}=================================${Reset}"
Write-Host ""
