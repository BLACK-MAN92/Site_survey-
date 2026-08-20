# AGENTS.md — `site-survey-mobile`

> Place this file at the root of the `site-survey-mobile` repository. It is standing context for every coding session in this repo. Read it in full before writing any code.

---

## 1. Your role

You are building the Flutter application a field engineer uses **standing at the base of a telecom tower, in direct sunlight, with no mobile signal, on a mid-range Android phone, having already visited four sites that day.**

Hold that picture. It is the entire specification.

Everything follows from it: the app must work with the radio off, must never lose an entry, must be legible in glare, must be operable one-handed while holding a phone and a clipboard, and must let the engineer move to the next site without waiting for anything to upload. An elegant implementation that requires connectivity is worthless here.

Three properties define good work in this repo:

1. **Offline-first, not offline-tolerant.** The network is the exception, not the rule. Every feature is designed for the disconnected case first and the connected case as an optimisation.
2. **Never lose data.** An engineer who loses twenty minutes of form entry to a battery death or an app kill will stop using the app, and no amount of correctness elsewhere recovers from that.
3. **You are a client, not an authority.** The API enforces every business rule. Your validation exists so the engineer learns about a problem *at the site*, while they can still fix it — not to be the gate.

---

## 2. Domain context — read this before designing anything

Field engineers survey telecom tower sites for a clean-up programme run for the client, **IHS**. Sites are **pre-assigned** to a named engineer; each engineer sees only their own sites and there is no browse or search across the wider portfolio.

Each site is visited twice by **the same engineer**:

1. **Pre-survey** — before works. The engineer records which of 13 work items are **required** at this site, a planned clean-up date, and takes "before" photographs.
2. **Post-survey** — after works. The engineer records the **progress** (WIP / Closed) of the items that were required, the actual clean-up date, and takes "after" photographs.

A back-office team then reviews both on a web dashboard, generates a before/after PowerPoint deck, and sends it to IHS, who accept or reject it. Rejections — internal or from the client — come back to **this app** as rework.

### 2.1 Why the data matters

These surveys are **commercial evidence**. They prove work was performed and they trigger client payment. That is why the app captures GPS, timestamps, device metadata, and photographs taken through the in-app camera rather than imported from a gallery. It is not surveillance of the engineer; it is proof for the client. Where a design choice trades convenience for verifiability, verifiability wins — but explain it to the engineer in the UI rather than letting it feel arbitrary.

---

## 3. Stack — decided, not open for revisiting

| Concern | Choice | Why |
|---|---|---|
| Flutter | Stable channel, Dart 3 | — |
| State | Riverpod | Testable, models async and offline states well |
| Routing | `go_router` | — |
| Local database | **Drift (SQLite)** | Relational queries over the queue; real migrations. Not Hive — the queue needs joins and ordering. |
| Secure storage | `flutter_secure_storage` | Tokens. **Never `SharedPreferences`** — readable on a rooted device. |
| Settings | `shared_preferences` | Non-sensitive only |
| Location | `geolocator` | Accuracy stream, `isMocked`, permission handling |
| Camera | `camera` + `image_picker` (**camera source only**) | In-app capture |
| Image processing | `flutter_image_compress` / `image` | Compression and watermarking |
| Connectivity | `connectivity_plus` **+ a reachability probe** | Connectivity ≠ internet; a captive portal reports connected |
| Background | `workmanager` | Periodic sync — with the caveat in §7, Sprint M4 |
| HTTP | `dio` + retry interceptor | Auth refresh and backoff in interceptors |
| Push | `firebase_messaging` | — |
| Crash/analytics | Firebase Crashlytics + Sentry | Field debugging without device access |

**Targets:** Android 8.0 (API 26)+ primary. iOS 14+ secondary.

### 3.1 Structure

```
lib/
  core/         { config, router, theme, errors, extensions }
  data/
    api/        { generated/, dio_client.dart, interceptors/ }
    local/      { database.dart (Drift), daos/, outbox/ }
    repositories/
  domain/       { entities/, value_objects/, usecases/ }
  presentation/ { screens/, widgets/, providers/ }
```

Repositories read from **local storage**, not the network. The network layer feeds local storage. The UI never awaits an HTTP call to show data.

---

## 4. The API contract — you consume it, you do not define it

This repo is **separate** from `site-survey-api`. There is no shared workspace.

1. The API publishes an OpenAPI 3.1 spec as a versioned artifact.
2. Generate Dart models from it (`openapi-generator` or `swagger_dart_code_generator`) into `lib/data/api/generated/`.
3. **`lib/data/api/generated/` is never hand-edited.**
4. Pin the contract version; CI fails if the pin is older than the API's current minor.

**Forbidden:** hand-writing a model that already exists in the spec.

If an endpoint you need does not exist, report it — do not work around it by putting business logic here.

---

## 5. Definitions — from the API, never redefined

```dart
// 13 work items. THE ORDER IS SIGNIFICANT and matches the legacy
// spreadsheet engineers have used for years. Presenting them in this
// order is the single cheapest adoption win available. Do not sort
// alphabetically for tidiness.
'janitorial', 'granite', 'concrete_resurfacing', 'palisade_gate',
'razor_coil', 'awl', 'security_light', 'tank_painting',
'sg_house_repair', 'fire_extinguisher', 'shelter_repair',
'cable_management', 'waste_disposal'

// Labels shown to the engineer
janitorial          → 'Janitorial'
granite             → 'Granite'
concrete_resurfacing→ 'Concrete Resurfacing'
palisade_gate       → 'Palisade & Gate'
razor_coil          → 'Razor Coil'
awl                 → 'AWL (Aviation Warning Light)'
security_light      → 'Security Light'      // only item with qtyReplaced
tank_painting       → 'Tank Painting'
sg_house_repair     → 'SG House Repair'
fire_extinguisher   → 'Fire Extinguisher'
shelter_repair      → 'Shelter Repair'
cable_management    → 'Cable Management'
waste_disposal      → 'Waste Disposal'

PROGRESS_STATUS: 'WIP' | 'Closed'
OVERALL_STATUS:  'Pending' | 'WIP' | 'Closed'
PHOTO_CATEGORY:  'before' | 'after'

CYCLE_STATES (drives the home screen grouping):
  'pre_due' | 'post_due' | 'in_review' | 'ready_for_ihs'
  | 'at_ihs' | 'closed' | 'rework'

OUT_OF_FENCE_REASONS (confirm before building — see §10):
  'site_coordinate_incorrect' | 'access_blocked_surveyed_from_gate'
  | 'gps_unavailable_indoors' | 'other'

REVIEW_STATES (a survey's position in the approval workflow):
  'draft' | 'submitted' | 'rejected_backoffice' | 'approved_internal'
  | 'submitted_to_ihs' | 'rejected_ihs' | 'accepted_ihs'
```

### 5.1 Rejection reasons you must display

Rework arrives with a reason code, and the engineer needs to know **which kind of rejection** it was and **what specifically to fix**. Never show the raw code.

**Back-office rejection** — an internal quality failure raised by your own supervisor. The client never sees it.

| Code | Show as |
|---|---|
| `photos_unusable` | Photos unusable or insufficient |
| `scope_mismatch` | Scope doesn't match the pre-survey |
| `geolocation_flagged` | Location flagged for review |
| `incomplete_form` | Form incomplete |
| `wrong_site` | Wrong site |
| `other` | See comment |

**IHS rejection** — the **client** rejected the completed work. This is a more serious event and usually means a re-visit.

| Code | Show as |
|---|---|
| `workmanship` | Client: workmanship not accepted |
| `incomplete_scope` | Client: scope incomplete |
| `photo_evidence_insufficient` | Client: photo evidence insufficient |
| `wrong_site_or_location` | Client: wrong site or location |
| `other` | Client: see comment |

Distinguish the two visually. An engineer should be able to tell at a glance whether their own office or the client sent the work back — the urgency is different.

### 5.2 Rules you enforce client-side *for the engineer's benefit*

The API is authoritative on **R-1 through R-7, R-9 and R-10** — you implement them so the engineer discovers the problem while still standing at the site, not the next day. **R-8 is client-only** by nature: the server cannot verify that a phone granted location permission, only that a plausible fix arrived.

| Rule | Statement |
|---|---|
| R-1 | `progress` may only be set when the item was `required` at pre-survey. |
| R-2 | Overall `Closed` only if every required item is `Closed`; otherwise it is `WIP`. The server **coerces** rather than rejecting, and reports the coercion in its response — surface that to the engineer so a site they believed closed does not silently come back as WIP. |
| R-3 | `security_light` closed requires `qtyReplaced > 0`. |
| R-4 | Planned clean-up date not more than 30 days in the past. |
| R-5 | Actual clean-up date ≥ planned − 30 days, and ≤ today. |
| R-6 | Comment ≤ 1000 characters. |
| R-7 | All 13 work items answered before a pre-survey can be submitted. |
| R-8 | Location permission is **mandatory** — survey creation is blocked without it. |
| R-9 | Out-of-geofence submission requires a reason from the enum. |
| R-10 | Minimum 6 and maximum 20 photos per survey (configurable per project phase; the API enforces the same bounds). |

### 5.3 The API's error envelope

Every non-2xx response has this shape. Switch on `code`, never on `message` — the message is human text and may change.

```json
{
  "error": {
    "code": "SITE_REASSIGNED",
    "message": "Human-readable, safe to display",
    "details": [{ "field": "workItems[3].progress", "issue": "set_without_required" }],
    "requestId": "01HW..."
  }
}
```

Codes this app must handle specifically: `TOKEN_EXPIRED`, `TOKEN_REUSE_DETECTED`, `SITE_REASSIGNED`, `DUPLICATE_SURVEY` (409), `POST_SURVEY_AUTHOR_MISMATCH`, `PROGRESS_WITHOUT_REQUIREMENT`, `INSUFFICIENT_ROLE`. Everything else falls back to a generic message plus `requestId`, which the engineer can read out to support.

**Never show a raw code or a `requestId` alone to a field engineer.** Say what happened and what to do; put the `requestId` behind a "details" affordance.

### 5.4 Wire conventions

- **Auth:** `Authorization: Bearer <accessToken>`. Access token **15 minutes**, refresh token **30 days with rotation**. The long refresh window is deliberate — an engineer must not be logged out mid-field. Refresh happens in a Dio interceptor, transparently.
- A reused refresh token invalidates the whole family (`TOKEN_REUSE_DETECTED`) and forces a re-login. Treat it as a security event, not a retryable error.
- **All timestamps on the wire are ISO 8601 UTC.** Convert to local time only for display. A GPS `capturedAt` sent in device-local time will silently corrupt the survey record.
- **All routes are under `/api/v1`.** Old app versions must keep working after a v2 ships — never assume the deployed server matches your build.

---

## 6. Working protocol

### 6.1 Before writing code in any sprint

- Read the PRD sections named in the sprint's **Reads** field. Do not skim.
- Restate the objective and acceptance criteria in your own words.
- List the files you intend to create or modify; if more than 15, wait for approval.
- If a requirement is ambiguous, **ask one consolidated question**. Not serially, and never by inventing an interpretation and proceeding silently.

### 6.2 While working

- One logical change per commit, Conventional Commits (`feat(sync): add resumable photo upload`).
- **No TODOs in merged code.** Deferred work goes in `BACKLOG.md` with a sprint number.
- Flavours for dev / staging / prod from Sprint M1. No hardcoded base URLs.
- No secret in the binary, ever. Cloudinary uploads use signatures the API issues.

### 6.3 Field-usability standards — functional requirements, not polish

- **Minimum 48 dp touch targets.** The engineer may be wearing gloves.
- **High-contrast theme readable in direct sunlight.** Test outdoors, not on a desk.
- **One-handed operation** for primary actions — the other hand is holding something.
- **Text scaling to 200% without layout breakage.**
- **Every destructive or irreversible action is confirmed.** Submission is a commitment.
- **Plain-language errors.** "Upload failed: 422" tells a field engineer nothing. Say what happened and what to do.
- **Never block the engineer on the network.** Submission writes locally and returns immediately.

### 6.4 Definition of Done — all must hold

| # | Gate |
|---|---|
| DoD-1 | Every acceptance criterion met and individually demonstrated **on a real Android device**, not only an emulator |
| DoD-2 | `flutter analyze` clean; `flutter test` passes with zero failures |
| DoD-3 | Unit tests on sync logic, form validation and the local store; `integration_test` for the sprint's primary offline flow |
| DoD-4 | No `dynamic` except where a package forces it, with an inline justification |
| DoD-5 | Generated API models current; contract pin check green |
| DoD-6 | `README.md` updated with new env vars, flavours, build steps |
| DoD-7 | `docs/demos/sprint-NN.md` — the literal device steps that prove the sprint works, **including the airplane-mode path** |
| DoD-8 | Handoff note: what was built, what was deferred, every assumption, and the test device named |

### 6.5 Escalate, don't improvise

Stop and ask when you hit: a required endpoint that does not exist; a platform restriction that makes a requirement infeasible as written; a package behaving differently from its docs; a change to the local schema that would strand data on engineers' devices; or **two consecutive failed attempts at the same problem** — report what you tried and why each failed rather than trying a third time.

---

## 7. Sprints

Four sprints, sequential. One sprint per session. Do not start the next.

**Dependency:** Sprint M1 requires API Sprint A2 complete (sites and assignment exist). Later sprints can begin against the OpenAPI spec while API sprints finish, but must be verified against the real API before their DoD is claimed.

---

### Sprint M1 — Foundation, auth, my sites, offline store

**Reads:** PRD §3.1, §4.5, §4.9, §7.1, §8

**Objective.** The app skeleton with local persistence and the assigned-sites list working with the radio off.

> **Get the offline architecture right in this sprint.** Retrofitting it later means rewriting every feature built on top of it. If you are unsure about the outbox design, ask before building — this is the one decision in this repo that is genuinely expensive to reverse.

**Tasks.**

1. Flutter project, Riverpod, `go_router`, flavours for dev/staging/prod.
2. **Generate Dart models** from the **published contract artifact** (§4 — the release asset or `@sitesurvey/contract`, not a file reached out of the API repo's working tree) into `lib/data/api/generated/`.
3. Layered structure per §3.1.
4. Drift schema for `sites`, `surveys`, `photos`, `outbox` — **with a migration strategy from day one.** Engineers will have unsynced data on their devices when you ship v2.
5. Auth: login, tokens in `flutter_secure_storage`, Dio interceptor for silent refresh, biometric unlock after first login with graceful password fallback.
6. Home screen: assigned sites grouped into *Pre-survey due*, *Post-survey due*, *Rejected — rework*, *Draft*, *Pending sync*. **No site search or browse** — the list is the entire surface, and that is deliberate.
7. Site caching on login and on each sync, so the list works with the radio off.
8. **Outbox pattern.** Every mutation writes to a local queue with `clientUuid`, status, attempt count and last error. **The UI reads from local state and never directly from the network.**
9. Per-record sync status in the UI: `Draft`, `Queued`, `Uploading (n/m)`, `Synced`, `Failed`, `Conflict`.
10. Design system: 48 dp targets, sunlight-readable high-contrast theme, 200% text scaling.

**Acceptance criteria.**

- Install fresh, log in, view assigned sites, enable airplane mode, **force-kill the app**, reopen — the site list is still there and usable.
- Tokens are absent from `SharedPreferences` (verify by inspecting the device, not by reading the code).
- Biometric unlock works after first login and falls back to password gracefully.
- The home screen shows only the caller's sites; the API is the enforcement point, verified by test.
- Text scaled to 200% breaks no layout.
- Cold start under 3 s — **name the test device**.

---

### Sprint M2 — Pre-survey form, camera, geolocation

**Reads:** PRD §3.1, §4.2, §4.3, §4.4

**Objective.** A field engineer can complete a pre-survey with photos and GPS, fully offline.

**Tasks.**

1. Permission onboarding explaining **why** location is required, with a graceful path when denied — the app blocks survey creation and says so plainly. It does not crash and it does not nag in a loop.
2. GPS capture at form open **and** at submission; store both. Require accuracy ≤ 50 m; below that show "Waiting for better GPS signal" with a manual override that flags the submission. Detect mocked locations (`Position.isMocked`).
3. Geofence check against the cached site coordinate. Outside the radius requires a reason from the enum, and flags the submission.
4. **Pre-survey as a 4-step stepper:** Header → Work items → Photos → Review & submit.
   - *Header:* site metadata read-only from cache; planned clean-up date picker enforcing R-4; comment field enforcing R-6.
   - *Work items:* all 13, each a large Yes/No control, **in the legacy spreadsheet order** (§5).
   - *Photos:* camera capture.
   - *Review:* full summary before submission — submission is a commitment and the engineer should see what they are committing.
5. **Draft autosave on every field change.** An engineer who loses the app mid-form loses nothing. This is not a nice-to-have; it is the difference between adoption and abandonment.
6. Camera: **in-app capture only, gallery import genuinely disabled** — not merely hidden. Min 6, max 20 photos, configurable.
7. Client-side compression before queueing: ≤1920 px long edge, JPEG quality 80, target ≤500 KB. Preserve EXIF in the stored original. This matters — engineers sync over metered rural connections.
8. Burn in a visible watermark: Site ID, timestamp, lat/long.
9. Per-photo coordinates captured independently of the form-level fix.
10. Optional work-item tagging per photo. It drives before/after pairing in the deck later, so make it easy — but not mandatory, because a tired engineer will not do it and a blocked submission is worse than an untagged photo.
11. Submission writes to the outbox; the engineer moves to the next site immediately without waiting for upload.

**Acceptance criteria.**

- A complete pre-survey with 10 photos can be captured start to finish **in airplane mode**.
- Force-killing the app mid-form loses no entered data.
- Gallery import is genuinely unavailable — verify by attempting it, not by checking the UI.
- The watermark is legible on a photo viewed at full size.
- Photos average under 500 KB; a 12 MP capture compresses correctly.
- Submitting 800 m from the site requires a reason and carries the flag.
- A mocked GPS fix is detected and flagged.
- **Form completion for a typical site takes under 4 minutes including photos — time it on a real device and record the figure.**

---

### Sprint M3 — Post-survey, sync engine, rework

**Reads:** PRD §3.2, §3.5, §4.5, §4.6.5

**Objective.** Close the loop: post-survey with scope pre-fill, a robust sync engine, and the rework path.

This sprint contains the hardest code in the repo. The sync engine is where offline-first is either real or theatre.

**Tasks.**

1. Post-survey form pre-populated from the pre-survey: **only items marked `required` are actionable**; the rest appear collapsed and read-only.
2. "Add unplanned work item" for scope discovered during works, flagged as a variation.
3. Actual clean-up date (R-5) and overall status, with R-2 enforced client-side.
4. **After-photo capture shows the matching Before photo as a reference** so the angles match. This is what makes the deck's before/after comparison meaningful — it is not optional polish, it is the feature.
5. **Sync engine:**
   - Triggers: connectivity regained, app foreground, periodic background task, manual pull-to-refresh.
   - Order: survey payload first, then photos — chunked and resumable.
   - Exponential backoff; after 5 failures surface for manual retry; **a failed item never blocks later items.**
   - **Connectivity ≠ internet.** Probe reachability before draining the queue; a captive portal reports connected.
   - **Idempotency:** the same `clientUuid` resubmitted returns `200` with `Idempotent-Replay`. **This is success, not a conflict** — clear the queue item.
   - **Genuine conflict:** `409 DUPLICATE_SURVEY` means the survey was captured twice (two devices, or a reinstall). Surface it for the engineer to discard or convert to a revision.
   - **`SITE_REASSIGNED`:** the site was reassigned while the draft sat in the queue. Discard it locally and explain in plain language, naming the new assignee. Do not retry.
6. Sync centre screen: queue contents, per-item status, manual retry, and a plain-language explanation of every failure.
7. **Rework flow:** rejected sites appear under *Rejected — rework* with the reason code and comment shown prominently. Re-submission creates a new revision server-side.
8. Push notifications with deep links into the relevant site.
9. Warning when unsynced items are older than 48 hours.
10. Cache eviction of synced photos after the retention window; storage capped at 2 GB, oldest-first.

**Acceptance criteria.**

- Capture 5 surveys with 10 photos each offline, restore connectivity — all 5 sync without intervention and **without duplicates**.
- Killing the app mid-sync and reopening resumes cleanly.
- A photo upload failing at 60% resumes rather than restarting.
- One permanently failing item does not block the other four.
- The same survey synced twice creates one server record and the queue item clears with no false conflict.
- A draft for a site reassigned while offline is discarded at sync with an explanation naming the new assignee — not a generic failure, not an endless retry.
- A rejection push shows reason and comment; tapping it opens the right site.
- After-photo capture displays the correct paired before photo.
- Storage stays under 2 GB after 100 surveys; eviction is oldest-first.

---

### Sprint M4 — Background sync, hardening, release

**Reads:** PRD §8 (NFRs), §9

**Tasks.**

1. `workmanager` periodic background sync. **Assume Android will throttle it.** Foreground sync on app open plus an always-available manual sync button are the real guarantees; the background task is an optimisation. Build accordingly — an app that is only correct when the background task fires is not correct.
2. Crashlytics + Sentry with meaningful breadcrumbs. Field debugging happens without physical access to the device.
3. Battery: balanced accuracy except during fix capture; **no persistent GPS listener.**
4. Accessibility pass: screen-reader labels on every input, 200% text scaling, contrast ratios.
5. Localisation scaffolding — English only, but every string externalised so French requires no code change.
6. Force-upgrade mechanism for breaking changes, and graceful degradation for old versions against a newer API. Engineers in remote areas cannot be force-upgraded on demand.
7. Remote wipe of local data on account deactivation, applied at next sync.
8. Single-active-device enforcement (configurable).
9. Release: signing, Play Store internal testing track, Firebase App Distribution for the pilot, `docs/release.md` runbook.
10. **Field pilot with 3–5 engineers**, with structured feedback capture and a triaged fix list before wider rollout. Engineer resistance is the top-rated adoption risk in the PRD; the pilot is the mitigation.

**Acceptance criteria.**

- Background sync fires within a reasonable window on a real device — **and the app is still correct when it does not.**
- A forced crash produces a Crashlytics report with useful breadcrumbs.
- Battery drain over an 8-hour day with 6 surveys is measured and recorded in `docs/battery-test.md`.
- TalkBack navigates every screen sensibly.
- Deactivating a user wipes local data on next sync.
- A release build installs from the internal track and completes a full survey cycle.
- Pilot feedback is captured, triaged, and either fixed or logged in `BACKLOG.md`.

---

## 8. Failure modes specific to this repo

| # | Anti-pattern | Why it breaks this project |
|---|---|---|
| 1 | Building offline sync after the features | Offline is architectural. Retrofitting means rewriting every feature above it. |
| 2 | UI awaiting a network call | The engineer is offline. The UI reads local state; the network feeds local state. |
| 3 | Trusting `connectivity_plus` as internet | A captive portal reports connected and the queue drains into nothing. Probe reachability. |
| 4 | Tokens in `SharedPreferences` | Readable on a rooted device. `flutter_secure_storage`. |
| 5 | Treating `Idempotent-Replay` as a conflict | It is a successful retry. Surfacing it as a conflict trains engineers to ignore real conflicts. |
| 6 | Retrying a `SITE_REASSIGNED` draft | It will never succeed. Discard and explain. |
| 7 | Enforcing business rules only client-side | An APK is decompilable. Your validation is UX; the API's is truth. |
| 8 | Re-sorting work items alphabetically | The legacy order is what engineers already know by heart. Familiarity is the cheapest adoption win available. |
| 9 | Uploading uncompressed photos | Metered rural connections. Compress before queueing, not on the server. |
| 10 | Relying on the background task for sync | Android throttles it aggressively. Foreground + manual sync are the guarantees. |
| 11 | A persistent GPS listener | Kills the battery on an 8-hour day, and the app becomes the thing engineers blame. |
| 12 | No draft autosave | One lost form and the engineer stops trusting the app. Unrecoverable, socially. |
| 13 | Allowing gallery import "temporarily for testing" | It ships. Photos are evidence; capture must be in-app. |
| 14 | Blocking submission on an optional field | A tired engineer at the fifth site of the day will abandon rather than comply. |
| 15 | Testing only on an emulator | Sunlight, GPS drift, throttled background tasks and real cameras do not exist there. |
| 16 | Marking a sprint done because the code exists | The acceptance criteria are the definition, and several require a real device. |

---

## 9. The offline test — run it every sprint

Before claiming any sprint done, run this on a real device:

1. Log in with connectivity. Load the site list.
2. Enable airplane mode.
3. Complete a full survey with 10 photos.
4. Force-kill the app. Reopen. **Verify nothing was lost.**
5. Start a second survey, leave it half-finished, force-kill again. Reopen. **Verify the draft is intact.**
6. Restore connectivity. **Verify both sync, with no duplicates and no intervention.**
7. Check the server: two surveys, correct photo counts, correct coordinates.

Any sprint that breaks this sequence is not done, regardless of what else works.

---

## 10. Open items — resolve before the sprint that needs them

| # | Question | Blocks |
|---|---|---|
| 1 | Is `OUT_OF_FENCE_REASONS` the final closed set? | Sprint M2 form |
| 2 | `Security Light` quantity — 0–10, or 1–2 per the legacy column label? | Sprint M3 validation |
| 3 | Company-issued devices (allows MDM and stricter policy) or BYOD? | Sprint M4 device policy |
| 4 | Does a back-office rejection always require a physical re-visit, or can some be corrected in-office? | Sprint M3 rework flow |
| 5 | Minimum photo count — is 6 right for every site type? | Sprint M2 validation |
| 6 | Does IHS reject whole sites, or individual work items? Item-level rejection would make rework a **partial** re-survey rather than a full one — a materially different form. | Sprint M3 rework flow |

---

## 11. Session kick-off

```
You are implementing Sprint M<N> of site-survey-mobile.

Read AGENTS.md in full — your role, the offline-first principles, the API
contract rules, field-usability standards, Definition of Done. All of it applies.

PRD sections to read first: <the sprint's Reads field>

Before writing any code:
1. Confirm you have read AGENTS.md and the named PRD sections.
2. Restate the objective and acceptance criteria in your own words.
3. List the files you will create or modify.
4. State how this sprint's work behaves with no connectivity.
5. Ask any clarifying questions now, as one consolidated message.

Then implement until every acceptance criterion is demonstrably met, including
the offline test in §9, on a real Android device.

Do not start Sprint M<N+1>. Finish with the DoD-8 handoff note naming the
test device.
```

### 11.1 Post-sprint review (run in a fresh session)

```
Review the Sprint M<N> implementation against its acceptance criteria in AGENTS.md.

For each criterion state MET / PARTIALLY MET / NOT MET, with the file and line
that satisfies it — or what is missing.

Then check independently:
- Does any UI path await a network call before showing data?
- Is anything written to SharedPreferences that belongs in secure storage?
- Is Idempotent-Replay handled as success, and 409 as a real conflict?
- Does draft autosave actually fire on every field change, or only on step change?
- Any persistent location listener?
- Is gallery import reachable by any path?
- Would the §9 offline test pass right now? If you cannot tell from the code, say so.
- Any `dynamic`, TODOs, hardcoded URLs or secrets?

Be adversarial. Finding a real problem is worth more than confirming the work.
```