# Google OAuth Setup Checklist

## Files Ready ✓

Your project now has:

- ✅ `custom_shell.html` - Updated with Google OAuth support (original backed up to `custom_shell.html.backup`)
- ✅ `google_auth.js` - Google Sign-In handler
- ✅ `godot_web_auth.gd` - JavaScript ↔ Godot bridge (autoload)
- ✅ `login_popup.gd` - Login UI with Google button working
- ✅ `login_popup.tscn` - Login popup scene
- ✅ `export_presets.cfg` - Configured to include `*.js` files

## What You Need to Do

### 1. Get Google Client ID (5 minutes)

1. Go to https://console.cloud.google.com
2. Select your project (or create new one)
3. **APIs & Services** → **Credentials**
4. **Create Credentials** → **OAuth 2.0 Client ID** → **Web application**
5. Add these **Authorized JavaScript origins**:
   - `https://noahval.github.io`
   - `http://localhost:8000`
6. Copy the **Client ID** (format: `xxxxx-xxxxx.apps.googleusercontent.com`)

### 2. Update google_auth.js (1 minute)

Edit `c:\Goa\google_auth.js`, line 6:

**Current:**
```javascript
const GOOGLE_CLIENT_ID = 'YOUR_CLIENT_ID_HERE.apps.googleusercontent.com';
```

**Change to** (replace with your actual Client ID):
```javascript
const GOOGLE_CLIENT_ID = '123456789-abc123xyz.apps.googleusercontent.com';
```

### 3. Export Your Game (2 minutes)

In Godot:
1. **Project** → **Export**
2. Select **Web** preset
3. Click **Export Project**
4. Export to `c:\Goa\build\` (or wherever you want)

**Important**: Make sure these files are in the export folder:
- `index.html` (your custom shell)
- `google_auth.js`
- `GoA.js`
- `GoA.wasm`
- `GoA.pck`

### 4. Test Locally (5 minutes)

```bash
cd c:\Goa\build
python -m http.server 8000
```

Then:
1. Open browser: `http://localhost:8000`
2. Game loads → Login popup appears
3. Click **"Sign in with Google"**
4. Google popup should appear
5. Sign in with your Google account
6. You should see authentication success!

**Check browser console (F12)** for logs:
```
[GoogleAuth] Initializing...
[GoogleAuth] Sign-in successful
[Bridge] Sending ID token to Godot
[NakamaClient] Google authentication successful!
```

### 5. Deploy to GitHub Pages

```bash
# Copy exported files to your GitHub Pages repo
cp -r c:\Goa\build/* /path/to/github/pages/repo/

# Or if you already have it set up:
cd c:\Goa\build
git add .
git commit -m "Add Google OAuth login"
git push
```

Wait 1-2 minutes, then test at: `https://noahval.github.io/GoA`

---

## Testing Your Setup

### ✅ Checklist

Before deploying, verify:

- [ ] Client ID updated in `google_auth.js`
- [ ] Exported game includes `google_auth.js`
- [ ] Local test at `localhost:8000` works
- [ ] Google Sign-In popup appears
- [ ] Authentication succeeds
- [ ] Console shows no errors
- [ ] Username/password login still works
- [ ] "Skip" button works

---

## Troubleshooting

### Google button does nothing

**Check:**
- Browser console (F12) for errors
- Is `google_auth.js` loaded? Look in Network tab
- Did you update the Client ID?

### "redirect_uri_mismatch"

**Fix:** Add `http://localhost:8000` to **Authorized JavaScript origins** in Google Cloud Console

### Token authentication fails

**Check:**
1. Client ID in `google_auth.js` matches Google Cloud Console
2. Nakama server has same Client ID in config
3. Token hasn't expired (sign out and retry)

---

## Current State

**Username/Password Login**: ✅ Working (both Create Account and Login)
**Google OAuth**: ⚠️ Ready, needs Client ID configuration
**Skip/Offline Mode**: ✅ Working

Once you add your Google Client ID to `google_auth.js`, everything will work!

---

**Full Documentation**: See [GOOGLE_OAUTH_SETUP.md](GOOGLE_OAUTH_SETUP.md)
**Quick Reference**: See [QUICK_START_GOOGLE_OAUTH.md](QUICK_START_GOOGLE_OAUTH.md)
