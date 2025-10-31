# Deployment Documentation

**Complete reference for deploying GoA to GitHub Pages via GitHub Actions**

---

## Table of Contents

1. [Overview](#overview)
2. [GitHub Actions Workflow](#github-actions-workflow)
3. [Export Configuration](#export-configuration)
4. [Build Artifacts](#build-artifacts)
5. [Login System Integration](#login-system-integration)
6. [Deployment Process](#deployment-process)
7. [Troubleshooting](#troubleshooting)

---

## Overview

GoA uses **GitHub Actions** for automated builds and deployment to **GitHub Pages**.

### Architecture

```
Developer → Commits to GitHub
    ↓
GitHub Actions (Workflow Triggered)
    ↓
Godot Export (Web Build)
    ↓
Deploy to GitHub Pages
    ↓
Live at https://noahval.github.io/GoA
```

### Key Principles

1. **Source-only commits** - Never commit `build/` folder
2. **Automated builds** - GitHub Actions handles export
3. **Clean deployments** - Fresh build every push
4. **No manual intervention** - Fully automated pipeline

---

## GitHub Actions Workflow

**Location**: `.github/workflows/deploy.yml` (or similar)

### Typical Workflow Structure

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  export-web:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: 4.5

      - name: Export Web Build
        run: |
          mkdir -p build
          godot --headless --export-release "Web" build/index.html

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build
```

### What GitHub Actions Does

1. **Checks out code** - Gets latest commit
2. **Installs Godot** - Sets up Godot 4.5
3. **Exports project** - Runs headless export to Web
4. **Deploys to Pages** - Pushes `build/` to `gh-pages` branch
5. **GitHub Pages serves** - Live at your domain

---

## Export Configuration

**Location**: [export_presets.cfg](../../export_presets.cfg)

### Web Export Preset

```ini
[preset.0]
name="Web"
platform="Web"
export_path="build/index.html"
include_filter="*.js"  # CRITICAL: Includes google_auth.js
html/custom_html_shell="res://custom_shell.html"
```

### Critical Settings

| Setting | Value | Purpose |
|---------|-------|---------|
| `include_filter` | `"*.js"` | Ensures `google_auth.js` is exported |
| `custom_html_shell` | `"res://custom_shell.html"` | Uses custom HTML with Google OAuth |
| `export_path` | `"build/index.html"` | Output location |

### Files That Must Export

✅ **Source files** (`.gd`, `.tscn`, compiled into `.pck`)
✅ **google_auth.js** - Google Sign-In handler
✅ **custom_shell.html** - Custom HTML template
✅ **Assets** - Images, audio, etc. (compiled into `.pck`)

---

## Build Artifacts

### What GitHub Actions Produces

After export, the `build/` folder contains:

```
build/
├── index.html          # Custom shell (from custom_shell.html)
├── google_auth.js      # Google OAuth handler
├── GoA.js              # Godot engine loader
├── GoA.wasm            # WebAssembly binary
├── GoA.pck             # Game assets package
├── GoA.audio.worklet.js  # Audio processor
└── level1/             # Assets referenced by custom shell
    ├── begin.jpg
    ├── title.webm
    └── Title.jpg
```

### What Gets Deployed

GitHub Actions deploys **everything** in `build/` to the `gh-pages` branch, which GitHub Pages serves.

---

## Login System Integration

### Files Required for Login

The login system needs these files in the deployed build:

1. **index.html** (custom_shell.html) - Contains Google API script tags
2. **google_auth.js** - Handles Google Sign-In
3. **GoA.pck** - Contains login_popup.tscn and scripts

### How It Works in Production

```
1. User visits https://noahval.github.io/GoA
   ↓
2. index.html loads Google API (apis.google.com/js/platform.js)
   ↓
3. index.html loads google_auth.js (with Client ID)
   ↓
4. Godot game loads (GoA.js + GoA.wasm + GoA.pck)
   ↓
5. Loading screen shows, then login popup appears
   ↓
6. User clicks "Sign in with Google"
   ↓
7. google_auth.js shows Google popup
   ↓
8. Token sent to Godot via JavaScript bridge
   ↓
9. Godot authenticates with Nakama server
   ↓
10. User logged in, cloud save loaded
```

### Google OAuth Requirements

For production deployment, ensure:

- **Google Client ID** in `google_auth.js` (line 5)
- **Authorized origins** in Google Cloud Console:
  - `https://noahval.github.io`
- **Nakama server** configured with same Client ID

---

## Deployment Process

### Developer Workflow

#### 1. Make Changes Locally

```bash
# Edit source files
# Test locally if needed (optional)
godot --export-release "Web" build/index.html
python -m http.server 8000 --directory build
```

#### 2. Commit Source Files Only

```bash
git add .
git commit -m "Add login system with Google OAuth"
git push
```

**Note**: `build/` is in `.gitignore`, so it won't be committed.

#### 3. GitHub Actions Builds Automatically

- Workflow triggers on push to `main`
- GitHub Actions exports fresh build
- Deploys to `gh-pages` branch
- GitHub Pages updates automatically

#### 4. Verify Deployment

Visit `https://noahval.github.io/GoA` and test:

- ✅ Game loads
- ✅ Login popup appears
- ✅ Google Sign-In works
- ✅ Username/password login works
- ✅ Skip button works

### What NOT to Commit

❌ `build/` folder
❌ `.godot/` folder
❌ `*.import` files (auto-generated)
❌ Editor config files

### What TO Commit

✅ Source files (`.gd`, `.tscn`, `.tres`)
✅ `google_auth.js` (with Client ID)
✅ `custom_shell.html`
✅ `export_presets.cfg`
✅ `project.godot`
✅ Assets (images, audio, etc.)

---

## Troubleshooting

### Build Fails in GitHub Actions

**Problem**: Workflow fails to export

**Check**:
1. Is `export_presets.cfg` committed?
2. Is Godot version correct in workflow?
3. Check GitHub Actions logs for error messages

**Solution**: Review workflow YAML and export presets

### google_auth.js Not in Deployed Build

**Problem**: Login doesn't work, console shows "google_auth.js not found"

**Cause**: `include_filter` not set in export preset

**Solution**: Ensure `export_presets.cfg` has:
```ini
include_filter="*.js"
```

### Google Sign-In Fails with "redirect_uri_mismatch"

**Problem**: Google popup shows error

**Cause**: Domain not authorized in Google Cloud Console

**Solution**: Add `https://noahval.github.io` to **Authorized JavaScript origins**

### Custom Shell Not Applied

**Problem**: Deployed game uses default Godot template, not custom shell

**Cause**: Custom HTML shell not set in export preset

**Solution**: Verify `export_presets.cfg`:
```ini
html/custom_html_shell="res://custom_shell.html"
```

### Login Popup Doesn't Appear

**Problem**: Game loads but no login popup

**Cause**: `login_popup.tscn` not referenced in loading_screen.tscn or script error

**Solution**: Check:
1. `loading_screen.tscn` has `LoginPopup` instance
2. No script errors in Godot console
3. `GodotWebAuth` autoload registered

### Nakama Authentication Fails

**Problem**: Login popup works but authentication fails

**Check**:
1. Nakama server is running (`https://nakama.goasso.xyz/healthcheck`)
2. Server has correct Google Client ID in config
3. Network tab shows request to Nakama server
4. Console shows detailed error message

**Solution**: See [nakama-integration.md](nakama-integration.md) troubleshooting

---

## Best Practices

### 1. Test Locally Before Pushing

```bash
# Export and test
godot --export-release "Web" build/index.html
python -m http.server 8000 --directory build
# Open http://localhost:8000
```

### 2. Use Descriptive Commit Messages

```bash
git commit -m "Add Google OAuth login popup to loading screen"
# Not: git commit -m "update"
```

### 3. Monitor GitHub Actions

- Check workflow runs in **Actions** tab
- Review logs if build fails
- Ensure deployment succeeds

### 4. Version Your Exports

Tag releases for major updates:

```bash
git tag v1.0.0
git push origin v1.0.0
```

### 5. Keep Secrets Secret

❌ **Never commit**:
- Nakama server keys
- Database passwords
- API secrets

✅ **Safe to commit**:
- Google Client ID (public, client-side)
- Export presets
- Custom HTML template

---

## GitHub Pages Configuration

### Repository Settings

1. Go to **Settings** → **Pages**
2. **Source**: Deploy from a branch
3. **Branch**: `gh-pages` / `root`
4. **Custom domain** (optional): Configure if using custom domain

### HTTPS/SSL

GitHub Pages automatically provides HTTPS for `github.io` domains. No configuration needed.

---

## Advanced: Custom Domain

If using a custom domain:

1. Add `CNAME` file to `build/` in workflow:
   ```yaml
   - name: Add CNAME
     run: echo "yourdomain.com" > build/CNAME
   ```

2. Configure DNS:
   - Type: `CNAME`
   - Name: `@` or `www`
   - Value: `noahval.github.io`

3. Update Google OAuth origins to include custom domain

---

## Related Documentation

- **[nakama-integration.md](nakama-integration.md)** - Authentication setup
- **[GOOGLE_OAUTH_SETUP.md](../../GOOGLE_OAUTH_SETUP.md)** - Google OAuth configuration
- **[SETUP_CHECKLIST.md](../../SETUP_CHECKLIST.md)** - Deployment checklist

---

**Version**: 1.0
**Last Updated**: 2025-10-31
**Maintainer**: Claude + Noah
