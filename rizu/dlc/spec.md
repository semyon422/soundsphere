# DLC System Specification (rizu.dlc)

## Background & Motivation
The current chart downloading system used to rely on the legacy `OsudirectModel` class, which was tightly coupled with legacy coroutine logic, UI state, and a single provider (osu!/Mino). To support future external sources and allow for different types of content (Charts, Skins, Hitsounds) to be seamlessly integrated into the modern `rizu` architecture, a new, modular DLC system has been implemented. This system leverages `ThreadRemote` for robust background execution and state synchronization.

## Scope & Impact
- Create a new `rizu.dlc` namespace.
- Introduce provider interfaces (`IDlcProvider`) for discovering, searching, and fetching metadata for various content types (Charts, Skins, Hitsounds).
- Implement a central `DlcManager` that coordinates with a background `DlcWorker` via `ThreadRemote`.
- Support both **Asynchronous** (production) and **Synchronous** (testing/debugging) modes.
- Seamlessly trigger imports for the corresponding systems (e.g., `rizu.library` for charts) upon successful download and extraction.
- **Impacts:** Legacy `OsudirectModel`, `fs_util`, and `OsudirectSubscreen.lua` UI are removed.

## Proposed Solution
The system will adopt a Provider-based architecture with a dedicated background worker:

1. **`rizu.dlc.IDlcProvider`**: An interface defining operations like `search(query, type, filters)`, `getMetadata(id)`, and `getDownloadUrl(id)`.
2. **`rizu.dlc.DlcType`**: A type alias for `"chart" | "skin" | "hitsound"`.
3. **`rizu.dlc.DlcManager`**: 
   - The primary interface for the UI.
   - Manages the lifecycle of the `DlcWorker` via `ThreadRemote`.
   - Dispatches download requests and receives progress updates.
   - Implements `setSync(boolean)` to toggle between direct execution and threaded execution.
4. **`rizu.dlc.DlcWorker`**:
   - Runs in a background thread (in async mode).
   - Performs HTTP requests using the modern `web` module.

   - Reports progress back to the `DlcManager` via remote calls.
5. **`rizu.dlc.DlcTask`**: 
   - A unit of work representing a download and its subsequent processing (extraction, validation).
6. **Content Integration**:
   - Once a task is complete, the `DlcManager` delegates the final "ingestion" to the appropriate system (e.g., `rizu.library.Library:computeLocation(path, location_id)` for charts).

## Implementation Details

### Modern Networking
- **Download Execution:** Instead of `fs_util.downloadAsync`, the `DlcWorker` will use `web.http.util` (or directly `HttpClient`) to perform downloads. This allows for better header handling, redirect following (if needed), and cleaner integration with the project's modern web stack.
- **Progress Tracking:** The `DlcWorker` will use a custom sink/receive loop to report download progress (bytes received, total size, speed) back to the `DlcManager` via `ThreadRemote` calls.

### Extraction Logic
- **Archive Extraction:** The extraction logic previously found in `fs_util.extractAsync` (using `physfs` and `rcopy`) will be moved directly into the `rizu.dlc` module (e.g., as a `DlcExtractor` utility). This logic remains sound but should not depend on the deprecated `fs_util` module.

### User Interface (Temporary ImGui Modal)
- **`ui.views.dlc.DlcModalView`**: A new temporary modal view built using `ui.imviews.ModalImView`.
- **Features**:
  - Search bar with debounced input.
  - Result list showing items from active `IDlcProvider`.
  - Content type filtering (Charts, Skins, Hitsounds).
  - Download buttons with progress bars for active tasks.

## Implementation Plan
### Phase 1: Core Interfaces and Threading Infrastructure
- Define `rizu.dlc.IDlcProvider`.
- Create `rizu.dlc.DlcManager` with `is_sync` support.
- Implement `rizu.dlc.DlcWorker` and set up the `ThreadRemote` bridge.
- Define the communication protocol (methods for progress reporting and task completion).

### Phase 2: Provider Implementation
- Implement initial providers (e.g., `MinoProvider` for charts).
- Ensure the provider interface supports filtering by `DlcType`.

### Phase 3: Extraction and System Integration
- Implement `DlcExtractor`.
- Implement hooks to notify relevant game systems (Library, Skin Manager, etc.) after a successful DLC installation.
  - For charts: `library:computeLocation(extractPath, defaultLocationId)`.

### Phase 4: UI Development and Integration
- Implement `ui.dlc.DlcModalView` (temporary ImGui modal).
- **Legacy UI Integration** (`ui/views/SelectView/NotechartsSubscreen.lua`):
  - Replace the "direct" button or add a new button in the footer to open the `DlcModalView`.
- **Modern UI Integration** (`yi/views/select/Select.lua`):
  - Add a `SelectButton` to the sidebar with a download icon (e.g., `` or ``) that opens the `DlcModalView`.

## Verification & Testing
- **Synchronous Testing**: Use `manager:setSync(true)` in unit tests to verify logic without the complexity of multi-threading.
- **Asynchronous Validation**: Verify that the UI remains responsive (no micro-stutters) during heavy downloads and extractions.
- Unit tests for `IDlcProvider` implementations using mock HTTP responses.
- Integration tests simulating a complete "Download-to-System" flow.

## Migration & Rollback
- Legacy code has been removed.
