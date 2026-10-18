# DepositGuard: one-page product spec

## The problem
Renters often lose part of their security deposit for damage that was already there when they moved in. They rarely have dated proof, so the landlord's word wins.

## The user
A renter (typically in the USA) who rents an apartment or house and wants proof of its condition. Not technical. Uses the phone camera daily. Often has poor signal inside buildings.

## The idea in one sentence
Renters document the condition of their home with photos at move-in, so they can prove pre-existing damage and get their security deposit back at move-out.

## Core screens

| # | Screen | What the user does |
|---|---|---|
| 1 | **Rentals list** (list) | Sees every rental with its lease end and days left. Searches by name or address. Taps **Add rental**. |
| 2 | **Rental detail** (detail) | Sees the lease summary and all logged issues. Searches, filters by room or severity, opens the PDF report, edits or deletes the rental. |
| 3 | **Issue form** (add/edit) | Takes or picks a photo, enters a title, room, severity, stage and note. Edits or deletes an existing issue. |

Supporting screens: onboarding (3 slides), rental form (add/edit), sign in / create account (optional), settings (theme, account, cloud backup, replay intro).

## Data model

**Rental**: `id`, `name`, `address`, `lease_start`, `lease_end`, `created_at`, `updated_at`

**Issue**: `id`, `rental_id`, `title`, `room`, `severity` (minor, moderate, severe), `stage` (move-in, during stay, move-out), `note` (optional), `photo` (file name, optional), `created_at`, `updated_at`

One rental has many issues. Deleting a rental deletes its issues. Photos are stored as files in the app's private folder; the database stores only the file name.

The cloud copy (Supabase) has the same two tables plus a `user_id`, and a private photo bucket.

## Offline behavior
- Everything the renter needs works without internet: add, edit, search, filter, photos, reminders, PDF report.
- The phone's database is the source of truth. The cloud is a backup copy.
- A banner tells the user when the phone is offline.
- Backup and restore need internet. When offline they stop immediately with a clear message and lose nothing.

## Notifications
Local reminders 30, 7 and 1 day before the lease ends, at 9 AM. They are rescheduled when a rental is edited or deleted.

## Cloud backup (optional)
Sign in with email. **Back up now** uploads new and changed items and photos. **Restore from backup** brings missing items onto a new phone. When the same item exists in both places, the newest change wins. Each user can only reach their own data.

## Out of scope for this MVP
Automatic sync, sharing a rental between two people, landlord accounts, payments, web app, push from a server, iOS release.

## Success looks like
- A renter can document a room in under a minute and find it again by search.
- The report opens in any PDF viewer and shows dates, rooms, severity and photos.
- The app never loses data when the phone is offline or the app is closed.
- A non-technical founder can install it, try it and understand how to publish it.
