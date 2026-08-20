# M0 Assessment

## 1. WHAT EXISTS
- **Flutter/Dart versions, dependencies:** The project is a barebones Flutter shell. The `pubspec.yaml` contains only `cupertino_icons` and no architecture dependencies (e.g., `riverpod`, `drift`, `dio`, `go_router`). Notably, the project name is misspelled as `site_suvery`.
- **Directory structure:** The directory is flat, containing only `lib/main.dart` and `lib/registration.dart`. It does not follow the layered architecture defined in AGENTS.md §3.1.
- **What is implemented:** A default Flutter counter app (`main.dart`) and a standalone `Registration` stateless/stateful widget. The registration screen has basic UI fields but contains logic errors (e.g., `hidePassword = hidePassword;` inside `setState`) and a broken navigation route (`/otp`). There is zero business logic.
- **Test coverage:** None. The `test/` directory is missing.
- **What works end to end:** Only the basic Flutter counter app and rendering of the broken registration UI.

## 2. FITNESS FOR AN OFFLINE-FIRST APP
The current codebase is 0% fit for an offline-first application.
- **Local database:** None exists. Drift and SQLite are absent. **Cost:** Setting up the database schema and migrations from scratch (Sprint M1).
- **Network calls in UI paths:** There are no network calls yet. However, the UI does not read from a local state manager either. **Cost:** Implementing Riverpod and wiring UI strictly to local streams.
- **Outbox/queue:** None. **Cost:** Building the entire outbox state machine, queue processor, and Drift tables from scratch (Sprints M1/M3).
- **Auth tokens:** None. `flutter_secure_storage` is not installed.
- **State management:** Mixed and local only (`setState`). **Cost:** Complete rewrite using Riverpod for global state.

## 3. KEEP / REFACTOR / REPLACE
| Area | Decision | Justification | Cost |
| --- | --- | --- | --- |
| `pubspec.yaml` | Replace | Missing all necessary packages. Typo in project name. | Low (1 hour) |
| `lib/main.dart` | Replace | It's the default Flutter counter boilerplate. | Low (1 hour) |
| `lib/registration.dart` | Replace | Pure UI with state bugs. Needs wiring to Riverpod and actual auth. | Medium (3 hours) |
| Directory Structure | Replace | Does not match AGENTS.md §3.1 (core, data, domain, presentation). | Low (1 hour) |

**Summary:** The codebase is essentially a blank slate. "Replace everything" is the correct answer here because there is nothing of substance to refactor. The cost of starting fresh within this repo is negligible compared to fighting bad boilerplate.

## 4. PROPOSED DESIGN
### Target Structure
Will implement the exact layered structure from AGENTS.md §3.1. Deviations are unnecessary as it's a blank slate.

### Drift Schema
- **`sites`**: `id` (PK), `assignee_id`, `name`, `latitude`, `longitude`, `status`, `cycle_state`.
- **`surveys`**: `id` (PK), `client_uuid` (Unique), `site_id` (FK), `type` (pre/post), `planned_date`, `actual_date`, `gps_lat`, `gps_lng`, `sync_status`.
- **`work_items`**: `id` (PK), `survey_id` (FK), `item_type` (Enum), `required` (Bool), `progress` (WIP/Closed), `qty_replaced`.
- **`photos`**: `id` (PK), `survey_id` (FK), `category` (before/after), `local_path`, `cloud_url`, `sync_status`.
- **`outbox`**: `client_uuid` (PK), `entity_type`, `payload` (JSON), `method`, `endpoint`, `status` (Draft, Queued, Uploading, Synced, Failed, Conflict), `attempt_count`, `last_error`.

### Outbox Design
- **States:** Draft -> Queued -> Uploading -> Synced | Failed | Conflict.
- **Transitions:** Writes are synchronously committed to local DB as `Draft` or `Queued`. A background Riverpod worker or Workmanager drains `Queued` items.
- **Retry Policy:** Exponential backoff. Max 5 failures before transitioning to `Failed` (requires manual UI retry).
- **Ordering Guarantees:** Survey payload must return `200` before child photos begin uploading.
- **Photo Upload Resumption:** Chunked streaming via Dio. If a photo fails at 60%, the uploaded bytes offset is stored, and the next retry resumes using the `Range` HTTP header (or Cloudinary's chunked API).
- **Queue Blocking:** If a survey permanently fails (e.g., 400 Bad Request), it is marked `Failed`. The queue ignores it on the next sweep and moves to the next independent `clientUuid`.

### UI State Reads
The UI will **never** await a network call. All screens will use Riverpod `StreamProvider` or `FutureProvider` attached to Drift DAOs. When the user taps "Submit", the Riverpod notifier writes to the Drift `outbox` and returns instantly. The UI reacts to the stream update.

### Draft OpenAPI Contract (M1/M2)
- `POST /api/v1/auth/login` (Returns `accessToken`, `refreshToken`)
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`
- `GET /api/v1/me`
- `GET /api/v1/sites/assigned`
- `POST /api/v1/surveys` (Accepts `clientUuid` for idempotency)
- `POST /api/v1/uploads/signature` (Returns Cloudinary upload signature)
- `POST /api/v1/surveys/{id}/photos`

## 5. RISKS AND OPEN QUESTIONS
- **Resolved PRD Ambiguities:** The PRD is now available and has resolved the previous ambiguities.
- **Resolved Blockers from §10:**
  - #1 (`OUT_OF_FENCE_REASONS`): Confirmed by the PRD.
  - #2 (`Security Light` quantity rules): Confirmed by the PRD as an integer 0-10.
  - #5 (Minimum photo count): The PRD states 6-20, but the USER has explicitly overridden this to a **minimum of 5 photos** for both pre and post surveys.
  - #4, #6 (Rework flow nature): Confirmed by the PRD that all rejections send the survey back to the original engineer for full Rework.
- **API Team Needs:** The draft OpenAPI spec must be ratified immediately so I can generate the Dart models and spin up the mock server. We need confirmation on the `DUPLICATE_SURVEY` and `SITE_REASSIGNED` error response shapes.

## 6. REVISED SPRINT PLAN
The sequencing in `AGENTS.md` (M1 -> M4) still holds perfectly. 
Existing code accelerates nothing. Sprint M1 is exactly as large as written. I recommend deleting `lib/main.dart` and `lib/registration.dart` entirely at the start of M1 and building the project skeleton from the ground up according to §3.1.
