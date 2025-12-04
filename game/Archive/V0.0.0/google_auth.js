// Google OAuth Integration for Godot Web Export
// This script handles Google Sign-In and passes the ID token to Godot
// Uses Google Identity Services (GIS) - the new Google Sign-In API

// Replace with your actual Google Client ID from Google Cloud Console
const GOOGLE_CLIENT_ID = '576123704732-193gub53ckjq33a3fqik3d3pcvagkde2.apps.googleusercontent.com';

let googleInitialized = false;

// Initialize Google Identity Services
function initGoogleSignIn() {
    console.log('[GoogleAuth] Initializing Google Identity Services...');

    // Check if google.accounts is available
    if (typeof google === 'undefined' || !google.accounts) {
        console.error('[GoogleAuth] Google Identity Services library not loaded');
        // Retry after a delay
        setTimeout(initGoogleSignIn, 500);
        return;
    }

    try {
        // Initialize the Google Identity Services
        google.accounts.id.initialize({
            client_id: GOOGLE_CLIENT_ID,
            callback: handleCredentialResponse,
            auto_select: false,
            cancel_on_tap_outside: true
        });

        googleInitialized = true;
        console.log('[GoogleAuth] Google Identity Services initialized successfully');
    } catch (error) {
        console.error('[GoogleAuth] Failed to initialize:', error);
    }
}

// Handle the credential response from Google
function handleCredentialResponse(response) {
    console.log('[GoogleAuth] Sign-in successful');
    console.log('[GoogleAuth] Received credential response');

    // The response.credential contains the JWT ID token
    const idToken = response.credential;

    // Send token to Godot
    if (window.godotGoogleAuthCallback) {
        window.godotGoogleAuthCallback(idToken);
    } else {
        console.error('[GoogleAuth] Godot callback not found');
    }
}

// Trigger Google Sign-In flow using popup
function signInWithGoogle() {
    console.log('[GoogleAuth] Starting Google Sign-In flow...');

    if (!googleInitialized) {
        console.error('[GoogleAuth] Google Auth not initialized yet');
        if (window.godotGoogleAuthErrorCallback) {
            window.godotGoogleAuthErrorCallback('Google Auth not initialized. Please wait and try again.');
        }
        return;
    }

    try {
        // Use the new popup method
        google.accounts.id.prompt((notification) => {
            console.log('[GoogleAuth] Prompt notification:', notification);

            if (notification.isNotDisplayed()) {
                console.log('[GoogleAuth] Prompt not displayed, reason:', notification.getNotDisplayedReason());
                // Fallback: Try the direct popup method
                triggerDirectSignIn();
            } else if (notification.isSkippedMoment()) {
                console.log('[GoogleAuth] User skipped the prompt');
                if (window.godotGoogleAuthErrorCallback) {
                    window.godotGoogleAuthErrorCallback('Sign-in cancelled');
                }
            } else if (notification.isDismissedMoment()) {
                console.log('[GoogleAuth] User dismissed the prompt');
                if (window.godotGoogleAuthErrorCallback) {
                    window.godotGoogleAuthErrorCallback('Sign-in cancelled');
                }
            }
        });
    } catch (error) {
        console.error('[GoogleAuth] Sign-in failed:', error);
        if (window.godotGoogleAuthErrorCallback) {
            window.godotGoogleAuthErrorCallback(error.message || 'Sign-in failed');
        }
    }
}

// Fallback method using OAuth 2.0 popup
function triggerDirectSignIn() {
    console.log('[GoogleAuth] Using fallback OAuth popup method');

    const client = google.accounts.oauth2.initTokenClient({
        client_id: GOOGLE_CLIENT_ID,
        scope: 'profile email',
        callback: (response) => {
            if (response.error) {
                console.error('[GoogleAuth] OAuth error:', response.error);
                if (window.godotGoogleAuthErrorCallback) {
                    window.godotGoogleAuthErrorCallback(response.error);
                }
                return;
            }

            // For OAuth2, we get an access token, not an ID token
            // We need to exchange it or use the ID token flow instead
            console.log('[GoogleAuth] OAuth response received');

            // This is a fallback - ideally the prompt() method should work
            if (window.godotGoogleAuthCallback) {
                // Note: This returns an access token, not an ID token
                // For Nakama, we need an ID token, so this is not ideal
                console.warn('[GoogleAuth] Using access token as fallback - may not work with Nakama');
                window.godotGoogleAuthCallback(response.access_token);
            }
        }
    });

    client.requestAccessToken();
}

// Sign out
function signOutGoogle() {
    if (googleInitialized) {
        google.accounts.id.disableAutoSelect();
        console.log('[GoogleAuth] Signed out');
    }
}

// Initialize when the Google library loads
function onGoogleLibraryLoad() {
    console.log('[GoogleAuth] Google library loaded, initializing...');
    initGoogleSignIn();
}

// Try to initialize immediately if library is already loaded
if (typeof google !== 'undefined' && google.accounts) {
    initGoogleSignIn();
} else {
    // Wait for library to load
    window.addEventListener('load', function() {
        setTimeout(initGoogleSignIn, 500);
    });
}
