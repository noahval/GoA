# Google OAuth Setup Guide for GoA

This guide will help you set up Google Sign-In for your web build of GoA.

## Prerequisites

- Google Cloud Console account
- Access to your project's web hosting (GitHub Pages)
- Nakama server with Google OAuth configured

---

## Step 1: Google Cloud Console Configuration

### 1.1 Create OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project or create a new one
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth 2.0 Client ID**

### 1.2 Configure OAuth Consent Screen

If not already configured:

1. Click **Configure Consent Screen**
2. Choose **External** (unless you have Google Workspace)
3. Fill in the required fields:
   - **App name**: GoA
   - **User support email**: Your email
   - **Developer contact**: Your email
4. Add scopes:
   - `userinfo.email`
   - `userinfo.profile`
5. Save and continue

### 1.3 Create Web Application Credentials

1. **Application type**: Web application
2. **Name**: GoA Web Client
3. **Authorized JavaScript origins**:
   ```
   https://noahval.github.io
   http://localhost:8000
   ```
4. **Authorized redirect URIs**:
   ```
   https://noahval.github.io/GoA
   http://localhost:8000
   ```
5. Click **Create**
6. **IMPORTANT**: Copy your **Client ID** (format: `xxxxx-xxxxx.apps.googleusercontent.com`)

---

## Step 2: Update Your Project Files

### 2.1 Update google_auth.js

1. Open `export_templates/google_auth.js`
2. Find this line:
   ```javascript
   const GOOGLE_CLIENT_ID = 'YOUR_CLIENT_ID_HERE.apps.googleusercontent.com';
   ```
3. Replace `YOUR_CLIENT_ID_HERE.apps.googleusercontent.com` with your actual Client ID from Step 1.3

### 2.2 Verify Nakama Server Configuration

Your Nakama server should already be configured (from previous setup), but verify:

1. Check `z:\appdata\nakama\data\config.yml`
2. Ensure Google OAuth is configured:
   ```yaml
   google:
     client_id: "YOUR_GOOGLE_CLIENT_ID"
   ```
3. Restart Nakama if you made changes:
   ```bash
   cd /mnt/user/appdata/nakama
   docker-compose restart nakama
   ```

---

## Step 3: Export Settings in Godot

### 3.1 Configure HTML5 Export

1. In Godot, go to **Project** → **Export**
2. Select **Web** preset (or create one)
3. In **HTML** section:
   - **Custom HTML Shell**: Browse to `export_templates/custom_shell.html`
4. In **Resources** section:
   - Ensure `export_templates/google_auth.js` is included
   - Add it to **Filters to export non-resource files/folders**: `*.js`

### 3.2 Export Your Project

1. Click **Export Project**
2. Choose your export location (e.g., a folder for GitHub Pages)
3. Export as HTML5
4. Verify these files are in the export folder:
   - `index.html` (or your custom shell name)
   - `google_auth.js`
   - `GoA.js`
   - `GoA.wasm`
   - `GoA.pck`

---

## Step 4: Test Locally

### 4.1 Run Local Web Server

You cannot test by simply opening the HTML file. You need a local server:

```bash
# Option 1: Python
cd path/to/export/folder
python -m http.server 8000

# Option 2: Node.js
npx http-server -p 8000

# Option 3: PHP
php -S localhost:8000
```

### 4.2 Test Authentication

1. Open browser to `http://localhost:8000`
2. Wait for game to load
3. Click "Sign in with Google" button
4. Google Sign-In popup should appear
5. Select your Google account
6. Check browser console (F12) for logs:
   - `[GoogleAuth] Initializing...`
   - `[GoogleAuth] Sign-in successful`
   - `[Bridge] Sending ID token to Godot`
   - `[NakamaClient] Google authentication successful!`

### 4.3 Troubleshooting Local Testing

**Problem**: "redirect_uri_mismatch" error
- **Solution**: Make sure `http://localhost:8000` is in your Google Cloud Console authorized origins

**Problem**: Google button does nothing
- **Solution**: Check browser console for JavaScript errors. Make sure `google_auth.js` is loaded.

**Problem**: Token not reaching Nakama
- **Solution**: Check that GodotWebAuth autoload is registered and login_popup has the callback methods

---

## Step 5: Deploy to GitHub Pages

### 5.1 Upload Files

1. Copy all exported files to your GitHub Pages repository
2. Include:
   - `index.html` (your custom shell)
   - `google_auth.js`
   - All `.js`, `.wasm`, `.pck` files
3. Commit and push:
   ```bash
   git add .
   git commit -m "Add Google OAuth support"
   git push
   ```

### 5.2 Test Production Build

1. Wait for GitHub Pages to deploy (usually 1-2 minutes)
2. Visit `https://noahval.github.io/GoA`
3. Test Google Sign-In
4. Verify authentication succeeds

---

## How It Works

### Authentication Flow

```
1. User clicks "Sign in with Google" button
   ↓
2. login_popup.gd calls JavaScriptBridge.eval("triggerGoogleSignIn()")
   ↓
3. google_auth.js shows Google Sign-In popup
   ↓
4. User selects Google account
   ↓
5. Google returns ID token to google_auth.js
   ↓
6. google_auth.js calls window.godotGoogleAuthCallback(token)
   ↓
7. custom_shell.html bridge forwards to GodotWebAuth.on_google_token_received()
   ↓
8. GodotWebAuth finds login_popup and calls login_popup.on_google_token_received(token)
   ↓
9. login_popup calls NakamaClient.authenticate_google(token)
   ↓
10. Nakama validates token with Google, creates/loads user session
   ↓
11. User is authenticated, cloud save loads
```

### Key Components

- **google_auth.js**: Handles Google Sign-In API, gets ID token
- **custom_shell.html**: Godot HTML wrapper with JavaScript bridge
- **godot_web_auth.gd**: Autoload that receives JavaScript callbacks
- **login_popup.gd**: UI that initiates auth and handles completion
- **nakama_client.gd**: Sends token to Nakama server for validation

---

## Security Notes

### DO NOT:
- ❌ Commit your Google Client ID to public repos (it's client-side, so it's okay to expose, but don't include secrets)
- ❌ Use the same OAuth client for development and production
- ❌ Skip HTTPS in production (GitHub Pages provides this automatically)

### DO:
- ✅ Keep your Nakama server key secret
- ✅ Use different Google OAuth clients for dev/staging/prod
- ✅ Monitor Google Cloud Console for unusual activity
- ✅ Restrict your OAuth client to only your domains

---

## Troubleshooting

### "Google Sign-In not initialized"

**Cause**: google_auth.js not loaded or Google API failed to initialize

**Solutions**:
1. Check browser console for errors
2. Verify `google_auth.js` is in the export folder
3. Check internet connection (Google APIs need to load)
4. Try hard refresh (Ctrl+F5)

### "Authentication failed: Invalid token"

**Cause**: Token expired or Client ID mismatch

**Solutions**:
1. Verify Client ID in `google_auth.js` matches Google Cloud Console
2. Verify Nakama server has correct Google Client ID in config
3. Try signing out and back in

### "redirect_uri_mismatch"

**Cause**: Domain not authorized in Google Cloud Console

**Solutions**:
1. Add your domain to **Authorized JavaScript origins**
2. Add your domain to **Authorized redirect URIs**
3. Wait a few minutes for changes to propagate

---

## Testing Checklist

- [ ] Google Client ID copied to `google_auth.js`
- [ ] Custom HTML shell set in Godot export settings
- [ ] `google_auth.js` included in export
- [ ] GodotWebAuth autoload registered
- [ ] Local testing successful (localhost:8000)
- [ ] Deployed to GitHub Pages
- [ ] Production testing successful
- [ ] Nakama creates/loads user sessions
- [ ] Cloud saves work after Google authentication

---

## Additional Resources

- [Google Sign-In JavaScript API](https://developers.google.com/identity/sign-in/web)
- [Nakama Google Authentication](https://heroiclabs.com/docs/authentication/#google)
- [Godot JavaScriptBridge Documentation](https://docs.godotengine.org/en/stable/classes/class_javascriptbridge.html)

---

**Version**: 1.0
**Last Updated**: 2025-10-31
**Author**: Claude + Noah
