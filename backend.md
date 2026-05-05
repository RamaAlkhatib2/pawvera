 # PawVera Backend Design & Implementation Roadmap

 This document is an actionable, developer-focused backend plan for PawVera. It targets a Firebase-based backend (Firestore, Firebase Auth, Storage, Cloud Functions, FCM) but also includes patterns that can be adapted to other cloud providers.

 Goals:
 - Secure, scalable data model for users, pets, bookings, reminders, stores, and services.
 - Clear API contracts for the Flutter frontend to consume.
 - Operational concerns: backups, monitoring, cost controls, and CI/CD.

 ---

 ## 1. Project setup & environments

 - Firebase projects: `pawvera-dev`, `pawvera-staging`, `pawvera-prod`.
 - Use separate GCP/Firebase projects per environment with distinct credentials.
 - Environment variables (store in CI secrets / Cloud Functions config):
   - `FIREBASE_CONFIG` (per-environment)
   - `FCM_SERVER_KEY` (if needed for server FCM calls)
   - `SENTRY_DSN` or similar for error reporting
 - IAM: grant minimal roles for service accounts used by Cloud Functions (Firestore/Storage access scoped only to needed operations).

 ---

 ## 2. High-level data model (Firestore)

 Design notes:
 - Use collections for natural aggregate boundaries: `users`, `pets`, `requests`, `bookings`, `reminders`, `stores`, `services`, `notifications`.
 - Favor flat, queryable documents. Avoid deeply nested arrays for frequently queried items.
 - Use server timestamps (`FieldValue.serverTimestamp()`) for `createdAt` / `updatedAt`.
 - Add soft-delete flags (`deleted: true` + `deletedAt`) when recovery is needed.

 Example collections & schema fields (types):

 - `users/{uid}`
   - `uid: string` (doc id)
   - `email: string`
   - `fullName: string`
   - `role: string` enum: `adopter|shelter|store_owner|admin`
   - `profilePic: string` (storage path / URL)
   - `phone?: string`
   - `createdAt: timestamp`
   - `lastSeen: timestamp`
   - `meta: map` (optional; quick flags)

 - `pets/{petId}`
   - `id: string` (doc id)
   - `ownerId: string` → `users/{uid}`
   - `name: string`
   - `breed?: string`
   - `age?: number` (years or months separate field if needed)
   - `gender?: string`
   - `description?: string`
   - `imageUrls: array[string]` (storage paths)
   - `status: string` enum: `available|pending|adopted|removed`
   - `createdAt: timestamp`
   - `location?: geo_point` (optional)

 - `requests/{requestId}` (adoption requests)
   - `id: string`
   - `petId: string`
   - `fromUserId: string`
   - `toOwnerId: string`
   - `message?: string`
   - `status: string` enum: `pending|approved|rejected|cancelled`
   - `createdAt: timestamp`

 - `bookings/{bookingId}`
   - `id: string`
   - `userId: string`
   - `serviceId?: string` (if shop/service-backed)
   - `petId?: string`
   - `storeId?: string`
   - `serviceType: string` enum: `adoption_visit|grooming|vet|shop_visit`
   - `startAt: timestamp`
   - `endAt: timestamp`
   - `status: string` enum: `pending|confirmed|completed|cancelled`
   - `metadata: map` (payment info, notes)

 - `reminders/{reminderId}`
   - `id: string`
   - `userId: string`
   - `title: string`
   - `description?: string`
   - `time: timestamp`
   - `repeat?: string` (e.g., `daily`, `weekly`, or cron expression)
   - `isCompleted: boolean`
   - `createdAt: timestamp`

 - `stores/{storeId}` and `services/{serviceId}`
   - Store: `ownerId`, `name`, `address`, `geoPoint`, `phone`, `status` (active/inactive)
   - Service: `storeId`, `title`, `durationMinutes`, `priceCents`, `staffIds[]`

 Indexing recommendations:
 - Composite indexes for queries you'll run from the client (e.g., `pets` by `status, breed, age` or `bookings` by `userId, status, startAt`). Create them proactively in `firestore.indexes.json` for CI deploys.

 ---

 ## 3. API surface & contracts

 Approach: use direct Firestore access from the Flutter client for basic CRUD that follows security rules (fast). For privileged operations, complex transactions, cross-collection integrity checks, and push notifications use Cloud Functions (HTTP or callable) as the backend API.

 Recommended endpoints (Cloud Functions - HTTP/Callable) and purpose:

 - Auth: handled by Firebase Auth (client SDK). Additional login hooks via `onCreate` Cloud Function to seed `users/{uid}`.

 - `POST /api/pets` (callable) — create pet
   - Body: { name, breed, age, description, ownerId (server ignored if callable), imagePaths[] }
   - Server: validate caller is authenticated and ownerId matches auth.uid.

 - `GET /api/pets` — search/list pets (client reads directly using Firestore queries for paging; use callable for server-side advanced search)

 - `POST /api/requests` — create adoption request
   - Body: { petId, message }
   - Server: create request doc, write an activity/notification for owner, and optionally send FCM.

 - `POST /api/bookings` — create booking
   - Body: { serviceId, storeId, petId, startAt, endAt }
   - Server: transactionally ensure no schedule conflict (query bookings for store/service where time overlaps), create booking, notify provider.

 - `POST /api/reminders` — create reminder (also stored client-side). Use Cloud Tasks if you need guaranteed delivery for future notifications.

 - Admin endpoints (protected by IAM & admin role check in function): `GET /admin/stats`, `POST /admin/approveRequest`, `POST /admin/deactivateStore`.

 Response patterns: use uniform envelope { success: boolean, data: object, error?: { code, message } } and proper HTTP status codes for HTTP functions.

 ---

 ## 4. Auth, roles & security rules

 Authentication:
 - Use Firebase Auth (email/password + optional Google). Verify email if account trust level matters.
 - Use custom claims for admin roles where appropriate (set via admin SDK).

 Firestore security rules (high level concepts):
 - Users may read their own user doc; public profile fields may be readable by anyone.
 - Pets are readable by all; writes allowed for the pet owner or admin.
 - Requests: a request's creator can create and read; owner of pet can read requests sent to them.
 - Bookings: creator can read/update/cancel; store owners and staff can read bookings for their store.

 Example (starter) rule snippets (must be reviewed & tested):

 - Users:
   - allow read: if request.auth != null && (request.auth.uid == userId || resource.data.public == true);
   - allow write: if request.auth != null && request.auth.uid == userId;

 - Pets:
   - allow read: if true;
   - allow create: if request.auth != null && request.auth.uid == request.resource.data.ownerId;
   - allow update, delete: if request.auth != null && request.auth.uid == resource.data.ownerId || request.auth.token.admin == true;

 - Bookings, Requests, Reminders: apply similar ownership checks and avoid clients writing server-only fields (e.g., `status`, `approvedBy`). Use Firestore Rules to prevent privilege escalation.

 Storage security:
 - Store images under `gs://<bucket>/users/{uid}/...` or `pets/{petId}/...` and restrict writes so that only the owner UID can upload to their folder (or use signed upload URLs from Cloud Functions).

 ---

 ## 5. Cloud Functions & server logic

 Triggers and use-cases:
 - `auth.onCreate` — create `users/{uid}` document with initial metadata.
 - `pets.onCreate` — moderate content (if required), update search index (Algolia or Firestore-based), generate derived data (e.g., QR code image stored in Storage), and emit analytics event.
 - `requests.onCreate` — notify pet owner (FCM), increment counters.
 - `bookings.onCreate` — run schedule conflict check (if created client-side, double-check server-side to prevent race conditions), send confirmation to user + provider.
 - HTTP endpoints for admin actions.

 Scheduling & background jobs:
 - Use Cloud Scheduler → Cloud Tasks / PubSub → Cloud Function to handle: sending scheduled reminders, deleting expired reminders, periodic analytics aggregation, cleaning up orphaned storage objects.

 Reliability patterns:
 - Idempotency keys for any retried operations (bookings, payments).
 - Use transactions where multiple documents must be consistent.

 ---

 ## 6. Notifications & reminders

 - Use FCM for push notifications to mobile clients.
 - For scheduled reminders: store `reminders` docs; Scheduler triggers function that queries due reminders within a time window and enqueues tasks to send notifications.
 - For important events (booking confirmed, adoption request), send immediate FCM and persist a `notifications/{notificationId}` doc for app history.

 Delivery guarantees:
 - FCM is best-effort for push. If delivery confirmation is needed, consider in-app acknowledgement stored in `notifications` doc.

 ---

 ## 7. Storage and media

 - Use Firebase Storage for images; store original + optimized/resized variants (generate via Cloud Function on upload).
 - Store storage paths in Firestore (not raw signed URLs). Use short-lived signed URLs when serving to non-authenticated clients.
 - Clean up orphaned images when corresponding document is deleted (Cloud Function trigger with soft-delete window).

 ---

 ## 8. Data integrity, backups & migrations

 - Backups: export Firestore regularly (use automated exports to a GCS bucket). Keep at least 30 days of backups for critical collections.
 - Migrations: write idempotent migration scripts (Node.js or Python) using the Admin SDK; keep a `migrations` collection to track applied migration versions.

 ---

 ## 9. Testing, QA, and observability

 - Unit tests for Cloud Functions (use emulator suite and unit tests with mocha/jest).
 - Use Firebase Emulator Suite for local integration testing of Firestore, Auth, and Functions.
 - Logging: structured logs in Cloud Functions (use JSON fields). Integrate with Cloud Logging and optionally Sentry.
 - Monitoring: create alerts for function failures, high error rates, queue backlog, and unexpected billing spikes.

 ---

 ## 10. Rate limits, quotas & cost control

 - Design queries to be indexed and paginated to avoid large reads.
 - Avoid fan-out writes where possible (or use batch writes and backoff strategies).
 - Use TTL / expiration policies for ephemeral collections (e.g., analytics events older than X days).

 ---

 ## 11. CI/CD and deployment

 - Store `firestore.rules`, `storage.rules`, `firestore.indexes.json`, and Cloud Functions source in the repo.
 - CI pipeline (GitHub Actions / GitLab CI): run lints, unit tests, deploy to `dev` on merge to `develop`, deploy to `staging` for release candidate, and deploy to `prod` on tagged releases with manual approval.

 ---

 ## 12. Admin & moderation workflows

 - Admin role (custom claim) can approve adoption posts, moderate images/text, and deactivate stores.
 - Keep audit logs for admin actions (collection `audit_logs/{id}` with who/what/when/context).

 ---

 ## 13. Sample Flow: Create Booking (detailed)

 1. Client calls `POST /api/bookings` (callable) with { serviceId, storeId, petId, startAt }.
 2. Function authenticates caller and checks user role.
 3. Function queries `bookings` for the same `serviceId`/`storeId` where time overlaps. If conflict, return 409.
 4. Create booking document in a transaction, set `status = pending`.
 5. Send FCM to store staff and confirmation to user.
 6. If payment required, await payment webhook to set `status = confirmed`.

 ---

 ## 14. Security checklist before launch

 - Harden Firestore rules and test with emulator rules unit tests.
 - Restrict Storage writes to authenticated owners or signed upload flow.
 - Enforce email verification for critical flows (optional but recommended).
 - Rotate and restrict service account keys; use workload identity where possible.

 ---

 ## 15. Next steps for developer (practical)

 - Add these packages to Flutter when ready: `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`.
 - Create starter Cloud Functions:
   - `onAuthCreate` (seed user doc)
   - `onRequestCreate` (send FCM)
   - `onBookingCreate` (conflict check + notify)
 - Add `firestore.rules`, `storage.rules`, and `firestore.indexes.json` to repo and CI pipeline.
 - Run integration tests in Firebase Emulator Suite.

 ---

 If you provide specific use-cases now, I will incorporate them directly into this document under a dedicated section with per-use-case API contracts, DB changes, Cloud Function designs, required indexes, and precise security rule updates.
