// Google OAuth Integration for Godot Web Export
// This script handles Google Sign-In and passes the ID token to Godot

// Replace with your actual Google Client ID from Google Cloud Console
const GOOGLE_CLIENT_ID = '576123704732-193gub53ckjq33a3fqik3d3pcvagkde2.apps.googleusercontent.com';

// Initialize Google Sign-In
function initGoogleSignIn() {
    console.log('[GoogleAuth] Initializing Google Sign-In...');

    // Load the Google Sign-In library
    gapi.load('auth2', function() {
        gapi.auth2.init({
            client_id: GOOGLE_CLIENT_ID,
            scope: 'profile email'
        }).then(function(auth2) {
            console.log('[GoogleAuth] Google Sign-In initialized successfully');
            window.googleAuth = auth2;
        }).catch(function(error) {
            console.error('[GoogleAuth] Failed to initialize:', error);
        });
    });
}

// Trigger Google Sign-In flow
function signInWithGoogle() {
    console.log('[GoogleAuth] Starting Google Sign-In flow...');

    if (!window.googleAuth) {
        console.error('[GoogleAuth] Google Auth not initialized');
        return Promise.reject('Google Auth not initialized');
    }

    return window.googleAuth.signIn({
        prompt: 'select_account'
    }).then(function(googleUser) {
        console.log('[GoogleAuth] Sign-in successful');

        // Get the ID token
        const idToken = googleUser.getAuthResponse().id_token;
        const profile = googleUser.getBasicProfile();

        console.log('[GoogleAuth] User:', profile.getName());
        console.log('[GoogleAuth] Email:', profile.getEmail());

        // Send token to Godot
        if (window.godotGoogleAuthCallback) {
            window.godotGoogleAuthCallback(idToken);
        }

        return idToken;
    }).catch(function(error) {
        console.error('[GoogleAuth] Sign-in failed:', error);

        // Send error to Godot
        if (window.godotGoogleAuthErrorCallback) {
            window.godotGoogleAuthErrorCallback(error.error || 'Sign-in cancelled');
        }

        throw error;
    });
}

// Sign out
function signOutGoogle() {
    if (window.googleAuth) {
        window.googleAuth.signOut();
        console.log('[GoogleAuth] Signed out');
    }
}

// Initialize when page loads
window.addEventListener('load', function() {
    // Wait a bit for the page to fully load
    setTimeout(initGoogleSignIn, 500);
});
