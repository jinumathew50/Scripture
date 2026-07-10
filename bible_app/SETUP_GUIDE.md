# 🔐 Environment Setup Guide

This guide shows you where to enter your API keys and configuration values.

## Step 1: Create Your `.env` File

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Open `.env` and fill in your values (see below)

---

## Step 2: Get Your Supabase Credentials

### Where to find them:
👉 **https://app.supabase.com** → Select your project → Settings → API

### You need:
- **Project URL** → Goes to `SUPABASE_URL`
- **anon/public key** → Goes to `SUPABASE_ANON_KEY`

### Example:
```env
SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Step 3: Get Your Bible Brain API Key

### Where to find it:
👉 **https://biblebrain.com/api** → Sign up → Get API Key

### Important:
- This key is used **server-side only** in Supabase Edge Functions
- Never expose this key in client-side code
- The Flutter app calls your Edge Function, which then calls Bible Brain

### Add to `.env`:
```env
BIBLE_BRAIN_API_KEY=your-bible-brain-api-key-here
```

---

## Step 4: (Optional) Gemini AI API Key

For the AI Study Assistant feature:

### Where to find it:
👉 **https://makersuite.google.com/app/apikey**

### Add to `.env`:
```env
GEMINI_API_KEY=your-gemini-api-key-here
```

---

## Complete `.env` Example

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Bible Brain API Key (used in Edge Functions only)
BIBLE_BRAIN_API_KEY=your-bible-brain-api-key-here

# Gemini AI API Key (optional)
GEMINI_API_KEY=your-gemini-api-key-here

# App Configuration
APP_NAME="Faith Audio Bible"
SUPPORT_EMAIL=support@yourapp.com
```

---

## Step 5: Deploy Supabase Edge Functions

The Bible Brain API key is used in your Edge Functions, not in the Flutter app directly.

### Deploy the proxy function:

```bash
# Navigate to supabase folder
cd supabase

# Login to Supabase
npx supabase login

# Link to your project
npx supabase link --project-ref your-project-id

# Deploy the Bible Brain proxy function
npx supabase functions deploy bible-brain-proxy
```

### The Edge Function uses `BIBLE_BRAIN_API_KEY` from:
- Supabase Secrets (production): `npx supabase secrets set BIBLE_BRAIN_API_KEY=your-key`
- Local development: From your `.env` file

---

## Step 6: Run the App

```bash
# Make sure you're in the bible_app directory
cd bible_app

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# For iOS
flutter run -d ios

# For Android
flutter run -d android
```

---

## 🔒 Security Notes

### ✅ DO:
- Commit `.env.example` to version control
- Use Supabase Edge Functions to proxy Bible Brain API calls
- Store Bible Brain API key in Supabase Secrets for production
- Keep `.env` in `.gitignore`

### ❌ DON'T:
- Commit `.env` to version control
- Put Bible Brain API key directly in Flutter code
- Expose API keys in GitHub or public repos
- Call Bible Brain API directly from mobile app

---

## Troubleshooting

### "SUPABASE_URL not found"
→ Make sure you created `.env` file (not just `.env.example`)

### "BIBLE_BRAIN_API_KEY not set"
→ Check that you copied `.env.example` to `.env` and filled in the value

### Edge Function returns 401
→ Verify you deployed the function with: `npx supabase secrets set BIBLE_BRAIN_API_KEY=your-key`

### App builds but can't connect to Supabase
→ Check that your SUPABASE_URL doesn't have trailing slashes
→ Verify SUPABASE_ANON_KEY is the 'anon' key, not the 'service_role' key

---

## Next Steps

After setting up environment variables:

1. ✅ Run Supabase migrations (see `supabase/migrations/README.md`)
2. ✅ Deploy Edge Functions
3. ✅ Set Supabase secrets for production
4. ✅ Run `flutter pub get`
5. ✅ Launch the app!

For detailed architecture info, see `ARCHITECTURE.md`.
