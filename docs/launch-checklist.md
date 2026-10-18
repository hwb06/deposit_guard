# App store launch checklist

Rules below were checked in October 2026. Store rules change often, so confirm anything marked **(confirm)** in the official Play Console help before you rely on it.

How to read this: `[ ]` means not done yet. Items marked **Blocker** must be finished before a public release.

---

## 0. Where the app stands today

| Area | Status |
|---|---|
| Android app | Built and tested on a physical Android phone. Release APK signed with a release key. |
| Play Store release | Not published. Needs the steps below. |
| iOS | The project has an iOS target, but it has **not** been built or run on an iPhone (no Mac was available). Sir accepted an Android build plus a screen recording for this MVP. |
| Known gaps before a public launch | **Blocker:** forgot-password screen, in-app account deletion. See section 6. |

---

## 1. Decide these first (they are hard to change later)

- [ ] **Final package id** (for example `com.<company>.depositguard`). It is permanent once the app is on Google Play. The current id in `android/app/build.gradle.kts` is a placeholder until the founder confirms.
- [ ] **Developer account type.** A personal account created after 13 November 2023 must first run a closed test with at least 12 testers for 14 continuous days before it can apply for production access. Organization accounts are exempt. Plan about three weeks for a first launch on a personal account. **(confirm)**
- [ ] **Who publishes:** the founder, using the founder's own Play Console account (recommended, so the app is owned by the business).
- [ ] **Notifications:** keep on-device reminders (current choice) or add Firebase Cloud Messaging later for server-sent messages.

---

## 2. Accounts and costs

- [ ] Google Play Console account (one-time registration fee, US$25 at the time of writing). **(confirm)**
- [ ] Identity verification for the account (government ID for a personal account, business documents for an organization).
- [ ] Supabase: plan decided. Free projects have usage limits and can be paused after a period of inactivity, so use a paid plan for real users. Check current limits on the Supabase pricing page.
- [ ] Sentry: plan decided (free plans have monthly limits).
- [ ] A web page for the **privacy policy** (any simple hosted page works, it must be a public link).
- [ ] A support email address shown in the store listing.
- [ ] Optional: Apple Developer Program (US$99 per year) if iOS is wanted.

---

## 3. Build the release file

1. [ ] Set the final `applicationId` in `android/app/build.gradle.kts`.
2. [ ] **Target API level.** Since 31 August 2026, new apps and updates on Google Play must target Android 16 (API level 36) or higher. Open `android/app/build.gradle.kts`, check that `targetSdk` resolves to 36 or higher (upgrade Flutter if it does not), then test on an Android 15/16 phone or emulator. **(confirm)**
3. [ ] Raise the version in `pubspec.yaml` for every upload, for example `1.0.0+1`, then `1.0.1+2`. The number after `+` must grow each time.
4. [ ] Create the **upload keystore** once (PowerShell):

   ```powershell
   $keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
   & $keytool -genkey -v -keystore "$env:USERPROFILE\depositguard-upload.jks" -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   - [ ] Keep the file outside the repository and make **two backups** in different places (for example a password manager and an encrypted drive).
   - [ ] Never email the keystore or its passwords in plain text.
5. [ ] Create `android/key.properties` (git-ignored) with the keystore path, alias and passwords.
6. [ ] Build the Play Store file (Play needs an app bundle, not an APK):

   ```bash
   flutter build appbundle --release
   ```

   Output: `build/app/outputs/bundle/release/app-release.aab`
7. [ ] Turn on **Play App Signing** when creating the app in Play Console. Google keeps the final signing key and you keep only the upload key, which can be reset if it is ever lost.
8. [ ] Install the release APK on a real phone and re-check: sign in, backup and restore, PDF export, reminders, offline banner.

---

## 4. Store listing

Draft text you can paste and adjust.

**App name (max 30 characters):** `DepositGuard: Rental Log`

**Short description (max 80 characters):**
`Photo-log your rental's condition and protect your security deposit.`

**Full description:**

> Moving into a new place? Photograph it before you unpack.
>
> DepositGuard helps renters keep dated proof of their home's condition, so pre-existing damage is not taken out of the security deposit.
>
> - Log scratches, stains and damage room by room, with photos, severity and notes
> - Everything is dated and searchable
> - Reminders before your lease ends
> - One tap creates a PDF report with photos to send to your landlord
> - Works offline. No account needed
> - Optional cloud backup so your evidence survives a lost phone
> - Light and dark themes
>
> Your photos stay on your phone unless you choose to back them up. Backups are private to your account.

**Graphics:**
- [ ] App icon 512 x 512 PNG (export from `assets/icon/app_icon.png`)
- [ ] Feature graphic 1024 x 500 PNG
- [ ] At least 2 phone screenshots (use 4 to 8: list, detail, issue form, search, dark mode, PDF)
- [ ] Category: Tools or House and Home (choose one)
- [ ] Contact email and privacy policy link

---

## 5. Forms Google will ask for

- [ ] **Privacy policy link.** It must state what is collected and why. For this app: email address (only if the user creates an account), photos and notes (stored on the phone, and in the user's private cloud space only if they back up), and crash reports. State that nothing is sold or shared for advertising.
- [ ] **Data safety form.** Answer from what the app really does:
  - Email address: collected only for optional accounts, used for account management.
  - Photos and user content: stored on the device, uploaded only when the user taps **Back up now**.
  - Crash logs and diagnostics: collected through Sentry to fix bugs.
  - Data is sent over an encrypted connection (HTTPS).
  - Describe how users can ask for deletion (see the account deletion item below).
- [ ] **Content rating questionnaire.** Expect a rating suitable for everyone (no violence, no user-to-user content).
- [ ] **Ads declaration:** the app contains no ads.
- [ ] **Target audience:** adults. Not designed for children.
- [ ] **App access.** Give reviewers a demo account so they can test sign-in. Use a separate test user, not a personal one.
- [ ] **Permissions the app uses:** camera (taking photos), notifications (reminders), internet (optional sign-in and backup). Explain each in plain words if asked.
- [ ] **Testing track.** Upload the bundle to **Internal testing** first (up to 100 testers, no review), then run the **Closed testing** track if your account type requires it. Keep more than 12 testers opted in so one person leaving does not restart the 14 days. **(confirm)**

---

## 6. Gaps to close before a public launch

These are not needed for the MVP demo but they matter for real users and for store review.

| Priority | Gap | Why it matters | Suggested fix |
|---|---|---|---|
| **Blocker** | **Account deletion** is not in the app. | Google Play requires apps that let users create an account to also let them delete it and its data, inside the app and through a web link. **(confirm)** | Add a **Delete account** button in Settings that removes the user's cloud rows, photos and login (needs a small server-side function), and publish a web page that explains how to request deletion. |
| **Blocker** | **Forgot password** is missing. | A user who forgets the password is locked out of backups. | Add a "Forgot password" link that sends Supabase's reset email, and a screen to set the new password. |
| High | Supabase **email confirmation is off** (it was turned off to make testing easy). | Anyone can sign up with an email they do not own. | Turn **Confirm email** on in Supabase, Authentication, Providers, Email. |
| High | Supabase's built-in email sender is meant for testing and has strict limits. | Confirmation and reset emails may not arrive. | Connect your own email service (custom SMTP) in Supabase. |
| Medium | Backup is manual. | Users may forget. | Add a gentle reminder or automatic backup on Wi-Fi. |
| Medium | iOS is untested. | Many renters use iPhones. | Borrow a Mac, build for iOS, add notification setup for iOS, test on a real iPhone, then use TestFlight. |
| Low | No server push. | Not needed today. | Add Firebase Cloud Messaging only if you want messages sent from a server. |

---

## 7. iOS (only if you decide to ship on iPhone)

- [ ] A Mac with Xcode and an Apple Developer Program membership.
- [ ] Set the bundle identifier and signing team in Xcode.
- [ ] `ios/Runner/Info.plist` needs these usage texts:
  - `NSCameraUsageDescription`: DepositGuard uses the camera to photograph the condition of your rental.
  - `NSPhotoLibraryUsageDescription`: DepositGuard lets you attach existing photos to your rental records.
- [ ] Set up iOS notification permission and settings for the reminders package, then test a reminder on a real iPhone.
- [ ] Build with `flutter build ipa`, upload through Xcode or Transporter, and test through **TestFlight** before submitting to App Store review.
- [ ] Apple asks for a privacy policy link, App Privacy answers (same facts as the Play data safety form), screenshots for required device sizes, and a demo account for the reviewer.

---

## 8. Final pre-release check

- [ ] `flutter analyze` is clean and `flutter test` passes.
- [ ] Secrets check passes: `.env`, `android/key.properties` and keystores are not tracked by git.
- [ ] Release build installed on a real phone and tested end to end.
- [ ] Supabase email confirmation is **on** and a real confirmation email arrives.
- [ ] Demo account exists, with sample data, for store reviewers.
- [ ] Privacy policy page is live and the link works.
- [ ] Keystore backups verified (open the backup and confirm the file is there).
- [ ] Sentry is receiving events from the release build.
- [ ] Release notes written for the first version.
