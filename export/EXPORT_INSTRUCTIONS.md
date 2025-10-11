# GoA - HTML5 Export Instructions

## Automated Export with GitHub Actions

Your project is now configured to automatically export to HTML5 whenever you push to the `main` branch.

### Setup Steps:

1. **Enable GitHub Pages:**
   - Go to your repository on GitHub: https://github.com/noahval/GoA
   - Click on **Settings** → **Pages**
   - Under **Source**, select **Deploy from a branch**
   - Select the **gh-pages** branch and **/ (root)** folder
   - Click **Save**

2. **Trigger the Export:**
   - Push your changes to the main branch:
     ```bash
     git add .
     git commit -m "Add HTML5 export configuration"
     git push origin main
     ```
   - The GitHub Actions workflow will automatically build and deploy your game

3. **Access Your Game:**
   - After the workflow completes, your game will be available at:
     `https://noahval.github.io/GoA/`

## Manual Export (Alternative Method)

If you prefer to export manually using the Godot editor:

### Prerequisites:
- Godot 4.5 installed on your system
- HTML5 export templates installed in Godot

### Steps:

1. **Install Export Templates:**
   - Open Godot Editor
   - Go to **Editor** → **Manage Export Templates**
   - Download and install templates for version 4.5

2. **Export the Game:**
   - Open your project in Godot Editor
   - Go to **Project** → **Export**
   - Select the **HTML5** preset (already configured)
   - Click **Export Project**
   - The preset will export to `export/web/index.html`

3. **Commit and Push:**
   ```bash
   git add export/web/
   git commit -m "Export game to HTML5"
   git push origin main
   ```

4. **Enable GitHub Pages:**
   - Go to repository **Settings** → **Pages**
   - Select **Deploy from a branch**
   - Choose **main** branch and **/export/web** folder
   - Click **Save**
   - Your game will be available at: `https://noahval.github.io/GoA/`

## Files Created:

- **export_presets.cfg** - Godot export configuration (in project root)
- **export/EXPORT_INSTRUCTIONS.md** - This file
- **.github/workflows/godot-export.yml** - Automated CI/CD pipeline
- **export/web/** - Directory for HTML5 build output

## Troubleshooting:

- If the automated export fails, check the Actions tab on GitHub for error logs
- Ensure your project runs correctly in Godot before exporting
- For manual export, make sure export templates match your Godot version exactly
- If the game doesn't load, check browser console for errors (usually CORS or missing files)

## Notes:

- The automated workflow uses the `gh-pages` branch
- Manual export uses the `export/web` folder on the `main` branch
- Choose one method and stick with it to avoid conflicts
- The game requires a web server to run (can't open index.html directly in browser)
- The `export_presets.cfg` file is in the project root for easy access by Godot Editor
