# Google Sign-Up Setup Guide

Follow these steps to enable "Sign up with Google" in TrueTrek.

---

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Sign in with your Google account
3. Click the project dropdown at the top left (next to "Google Cloud")
4. Click "New Project"
5. Enter a project name (e.g., "TrueTrek")
6. Click "Create"
7. Wait for the project to be created, then select it

---

## Step 2: Enable the Google+ API (optional but recommended)

1. In the left sidebar, click "APIs & Services" → "Library"
2. Search for "Google+ API"
3. Click on it and click "Enable"

---

## Step 3: Configure the OAuth Consent Screen

Before creating credentials, you need to configure the consent screen (what users see when they sign in).

1. In the left sidebar, click "APIs & Services" → "OAuth consent screen"
2. Select "External" (unless you have a Google Workspace organization)
3. Click "Create"
4. Fill in the required fields:
   - **App name**: TrueTrek
   - **User support email**: Your email
   - **Developer contact email**: Your email
5. Click "Save and Continue"
6. On the "Scopes" page, click "Add or Remove Scopes"
   - Select: `email` and `profile`
   - Click "Update"
7. Click "Save and Continue"
8. On "Test users" page, you can add test emails (only needed while in testing mode)
9. Click "Save and Continue"
10. Review and click "Back to Dashboard"

---

## Step 4: Create OAuth 2.0 Credentials

1. In the left sidebar, click "APIs & Services" → "Credentials"
2. Click "+ Create Credentials" at the top
3. Select "OAuth client ID"
4. For "Application type", select "Web application"
5. Enter a name (e.g., "TrueTrek Web Client")
6. Under "Authorized JavaScript origins", add:
   - `http://localhost:3000` (for development)
   - `https://yourdomain.com` (for production - replace with your actual domain)
7. Under "Authorized redirect URIs", add:
   - `http://localhost:3000/users/auth/google_oauth2/callback` (for development)
   - `https://yourdomain.com/users/auth/google_oauth2/callback` (for production)
8. Click "Create"
9. A popup will show your **Client ID** and **Client Secret** - copy these!

---

## Step 5: Add Credentials to Your App

1. Open the `.env` file in your TrueTrek project root
2. Add these two lines (replace with your actual values):

```
GOOGLE_CLIENT_ID=your_client_id_here.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your_client_secret_here
```

Example:
```
GOOGLE_CLIENT_ID=123456789-abcdefg.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-abcdefghijklmnop
```

---

## Step 6: Restart Your Rails Server

Stop your Rails server (Ctrl+C) and start it again:

```bash
bin/rails server
```

---

## Step 7: Test It!

1. Go to `http://localhost:3000/users/sign_in`
2. Click "Continue with Google"
3. Sign in with your Google account
4. You should be redirected to the "Complete Profile" page to enter your city
5. After entering your city, you'll be redirected to the homepage

---

## Troubleshooting

### "redirect_uri_mismatch" error
- Make sure the redirect URI in Google Cloud Console matches exactly:
  `http://localhost:3000/users/auth/google_oauth2/callback`
- Check for typos, trailing slashes, or http vs https mismatches

### "Access blocked: This app's request is invalid"
- Your OAuth consent screen may not be configured properly
- Go back to Step 3 and make sure all required fields are filled

### "invalid_client" error
- Double-check your Client ID and Client Secret in the `.env` file
- Make sure there are no extra spaces or quotes

### App is in "Testing" mode
- While in testing mode, only test users you added can sign in
- To allow anyone to sign in, go to OAuth consent screen → "Publish App"
- Note: Publishing may require verification for sensitive scopes

---

## Production Deployment

When deploying to production:

1. Add your production domain to "Authorized JavaScript origins"
2. Add your production callback URL to "Authorized redirect URIs":
   `https://yourdomain.com/users/auth/google_oauth2/callback`
3. Set the environment variables on your production server:
   - `GOOGLE_CLIENT_ID`
   - `GOOGLE_CLIENT_SECRET`
4. Consider publishing your OAuth consent screen for public access

---

## Security Notes

- Never commit your `.env` file to git (it should be in `.gitignore`)
- Keep your Client Secret private
- Use different credentials for development and production if needed
