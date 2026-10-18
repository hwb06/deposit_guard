# Case study: DepositGuard

**A mobile app that helps renters keep dated photo proof of their home, so they can get their security deposit back.**

## The brief
A founder needed a simple, fresh utility app for everyday users, built from nothing by one developer: cross-platform, polished, with onboarding, login, local storage, a backend, search, dark mode, notifications and error tracking, plus documents a non-technical person can follow. Generic weather, to-do, notes and calculator apps were ruled out.

## The problem I chose
Renters regularly lose part of their deposit for damage that was already there. They have no dated proof, so the landlord's account wins. It is a real, expensive problem for a clear user, and it fits a phone perfectly: a camera, reminders, and a need to work inside buildings with weak signal.

## The solution
Renters photograph and log every issue at move-in, room by room, with severity and notes. The app reminds them before the lease ends. At move-out one tap creates a PDF report with dates and photos to send to the landlord. Everything works offline and without an account. An optional login adds cloud backup, so the evidence survives a lost phone.

## Key decisions
- **Phone first, cloud second.** The phone's database is the source of truth, the cloud is a backup. Evidence can never be lost because of bad signal, and guests get the whole app.
- **Cloud safety by design.** Each user can only reach their own rows and photos, enforced inside the database itself, with a private photo bucket. This was tested with a second account.
- **A backup that cannot hurt.** Backup only removes cloud items the phone had already backed up, and restore never deletes anything on the phone. A brand-new phone cannot wipe a backup by accident.
- **On-device reminders instead of server push.** Lease dates are known in advance, so reminders work offline with no extra service. Firebase push can be added later.
- **Clean layers.** Screens, state managers, repositories and data sources are kept separate, which made the app easy to test and to change.

## What was built
- Onboarding, guest mode and optional email sign-in
- Rentals list, rental detail, and an add/edit issue form with camera or gallery photos (compressed on capture)
- Search and filters by room and severity
- Loading, empty and error states on every screen
- Light, dark and system themes
- Lease-end reminders at 30, 7 and 1 day, rescheduled automatically when data changes
- PDF report export with photos
- Supabase backup and restore with private storage and Row Level Security
- Offline banner and instant offline messages for cloud actions
- Sentry error tracking, environment variables for all secrets, input validation, and a release build signed with its own key
- Automated tests for validation, helpers and the main state managers

## Quality and hardening
Beyond the feature list, the hardening pass fixed problems that only show up in real use: search that treated `%` as "match everything", a login listener that stopped working after an offline start, and a days-left count that could be off by one around daylight-saving changes. It also added a friendly screen for unexpected errors in release builds and turned off Android's automatic cloud backup so private photos are not copied silently.

## Result
A working Android app, tested on a physical phone, with every requirement in the brief covered:

| Requirement | Delivered |
|---|---|
| Onboarding and auth | Three-slide intro, guest mode, optional email login |
| Three or more screens | List, detail, add/edit, plus settings and sign-in |
| Local persistence | SQLite |
| API / backend | Supabase (auth, database, private storage) |
| Search and filter | Yes |
| Settings and dark mode | Yes |
| Notifications | On-device reminders |
| Loading, empty, error states | Yes |
| Hardening | Env vars, validation, Sentry, no secrets in the repo, offline fallback |
| Documents | README, spec, architecture, launch checklist, handover guide, this case study |

## Honest limits
The app was tested on Android only; the iOS target exists but has not been run on an iPhone. Backup is manual. Before a public launch it still needs a forgot-password screen and in-app account deletion, both listed in the launch checklist.

## What I would do next
Add the two launch blockers, turn email confirmation on with a real email sender, test on iOS, and consider automatic backup on Wi-Fi and a shared report link for landlords.
