# Quick Start: Google OAuth Setup

**Time needed**: ~15 minutes

## TL;DR Steps

### 1. Get Google Client ID (5 min)

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. **Credentials** → **Create OAuth Client ID** → **Web application**
3. Add origins: `https://noahval.github.io` and `http://localhost:8000`
4. Copy the Client ID (looks like: `12345-abc.apps.googleusercontent.com`)

### 2. Update Your Code (2 min)

Edit `export_templates/google_auth.js`, line 6:

```javascript
const GOOGLE_CLIENT_ID = 'YOUR_CLIENT_ID_HERE.apps.googleusercontent.com';
```

Replace with your actual Client ID from step 1.

### 3. Export Settings in Godot (3 min)

1. **Project** → **Export** → **Web**
2. **HTML** section → **Custom HTML Shell** → Browse to `export_templates/custom_shell.html`
3. **Export Project**

### 4. Test Locally (5 min)

```bash
cd path/to/exported/files
python -m http.server 8000
```

Open `http://localhost:8000`, click "Sign in with Google"

### 5. Deploy

Push to GitHub Pages, test at `https://noahval.github.io/GoA`

---

## What Each File Does

| File | Purpose |
|------|---------|
| `google_auth.js` | Handles Google Sign-In, gets ID token |
| `custom_shell.html` | Godot HTML wrapper with Google APIs |
| `godot_web_auth.gd` | Receives callbacks from JavaScript |
| `login_popup.gd` | Shows login UI, triggers auth flow |

---

## Common Issues

**Google button does nothing**: Check browser console, make sure `google_auth.js` loads

**"redirect_uri_mismatch"**: Add `http://localhost:8000` to Google Cloud Console origins

**Token not working**: Verify Client ID matches in both `google_auth.js` and Nakama config

---

**Full guide**: See [GOOGLE_OAUTH_SETUP.md](GOOGLE_OAUTH_SETUP.md)
