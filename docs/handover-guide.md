# Handover guide (for the founder)

This guide explains what you receive, which accounts must move to you, and how to do it safely. Menu names in the dashboards change from time to time, so if a label differs slightly, look for the closest one.

## What you are receiving

| Item | Where it lives now | Where it should end up |
|---|---|---|
| Source code | Developer's GitHub repository | Your GitHub account or organization |
| Cloud backend (login, database, photo storage) | Supabase project created under the developer's account | Your Supabase organization |
| Error tracking | Sentry project created under the developer's account | Your Sentry organization |
| App signing key (keystore) | Developer's computer, with backups | Stored safely by you (password manager) |
| Google Play publishing | Not created yet | **Your** Play Console account |

Why this matters: whoever owns these accounts controls the app. The app should belong to your business, not to a freelancer.

## Accounts you need to create

- [ ] GitHub (free)
- [ ] Supabase (free to start, paid plan for real users)
- [ ] Sentry (free to start)
- [ ] Google Play Console (one-time fee)
- [ ] A password manager for keys and passwords (for example Bitwarden or 1Password)

## Step by step

### 1. Code on GitHub
1. In the repository, open **Settings**, **General**, scroll to **Danger Zone** and choose **Transfer**, or add your GitHub user as an **Owner**.
2. Confirm you can see the full history and that the repository does not contain `.env`, `android/key.properties` or any `.jks` file.

### 2. Supabase project
1. Create your own Supabase organization.
2. The developer opens the project, then **Project Settings**, **General**, and uses **Transfer project** to move it to your organization. Accept the transfer in your dashboard.
3. After the transfer, check that the tables `rentals` and `issues` and the private storage bucket `issue-photos` are still there.
4. Check that **Row Level Security** shows as enabled on both tables (Table Editor shows a badge).
5. Turn **Confirm email** on (Authentication, Providers, Email) and connect your own email sender (custom SMTP), so real users receive confirmation and reset emails.
6. Delete the demo user before launch (Authentication, Users).

### 3. Sentry
1. Add yourself as **Owner** of the Sentry organization (Settings, Members), or transfer the project to your organization (Project Settings, General Settings, Transfer Project).
2. Create a **new DSN** under your ownership: Project Settings, Client Keys (DSN), create a key, then disable the old one.
3. Set up an alert so you get an email when a new error appears.

### 4. The new keys go into the app
After any transfer or key change, update the `.env` file with the current values, then rebuild:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

Test sign-in, backup and a forced error before you share the new build.

### 5. Signing key (keystore)
- The developer hands over the `.jks` file and the passwords **separately**, through a secure method (a password manager share, never plain email).
- You store two copies in two places and confirm each copy opens.
- If this key is lost and Play App Signing is not enabled, the app can never be updated. Enable **Play App Signing** when you create the app in Play Console.

### 6. Google Play
Follow [launch-checklist.md](launch-checklist.md) from section 1. Publish from **your** account.

## If keys were ever exposed
If a secret was committed to the repository or shared in a chat:
1. Treat it as public.
2. Supabase: rotate the project's JWT secret (Project Settings, API), which creates new keys and signs everyone out. Put the new `SUPABASE_URL` and `SUPABASE_ANON_KEY` into `.env` and rebuild.
3. Sentry: create a new DSN and disable the old one.
4. Keystore: if the upload key leaks, ask Play Console to reset the upload key (possible with Play App Signing).

The Supabase **anon** key and the Sentry DSN are designed to be public-facing, and cloud data is protected by Row Level Security. The **service_role** key is different: it bypasses all protection and must never be in the app, in `.env`, in the repository or in a chat.

## Running costs to expect
- Supabase: free plans have limits and can pause a project that has been idle. A paid plan avoids pauses and adds backups. Check the current pricing page.
- Sentry: free plan with monthly limits. Upgrade only if you exceed them.
- Google Play: one-time registration fee.
- Apple (only if you ship on iPhone): yearly developer fee.

## Words you may hear

| Word | Meaning |
|---|---|
| Keystore | A file that proves a build comes from you. Lose it and you cannot update the app. |
| APK / AAB | The installable file (APK) and the file the Play Store wants (AAB). |
| Supabase | The service that provides sign-in, the cloud database and photo storage. |
| Row Level Security (RLS) | Database rules that stop one user from seeing another user's data. |
| Sentry | A service that collects error reports so bugs can be fixed. |
| `.env` | A small settings file with the project's addresses and public keys. |
| Closed testing | A required Play Store test period with a group of real testers. |
