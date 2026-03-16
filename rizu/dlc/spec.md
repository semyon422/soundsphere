# DLC System Specification (rizu.dlc)

## Background & Motivation
To support external sources and allow for different types of content (Charts, Skins) to be seamlessly integrated into the modern `rizu` architecture, a modular DLC system has been implemented. This system leverages `ThreadRemote` for robust background execution and state synchronization.

Skin downloading is not currently supported but is planned for the future. An official Rizu chart and skin repository is also planned.

## Scope & Impact
- Create a new `rizu.dlc` namespace.
- Introduce provider interfaces (`ISearchProvider`, `IDownloadProvider`) for discovering, searching, and fetching metadata for various content types (primarily Charts right now, and Skins in the future).
- Implement a central `DlcManager` that coordinates with a background `DlcWorker` via `ThreadRemote`.
- Support both **Asynchronous** (production) and **Synchronous** (testing/debugging) modes.
- Seamlessly trigger imports for the corresponding systems (e.g., `rizu.library` for charts) upon successful download and extraction.

## Proposed Solution
The system will adopt a Provider-based architecture with a dedicated background worker. Each provider is specialized for a specific content type (e.g., Charts) to avoid complexity in multi-content management. Different providers or content types may have entirely different UIs tailored to their specific metadata and search requirements.

1. **`rizu.dlc.ISearchProvider`**: An interface defining the `search(query, filters)` operation.
2. **`rizu.dlc.IDownloadProvider`**: An interface defining the `getDownloadUrl(id)` operation.
3. **`rizu.dlc.DlcType`**: A type alias for `"pack" | "set" | "file" | "skin"`.
   - `"pack"`: A collection of multiple chart sets (e.g., Etterna packs).
   - `"set"`: A single chart set containing multiple difficulties and assets (e.g., osu! beatmapsets).
   - `"file"`: A single chart file, downloaded to a specific set folder (e.g., for updating or adding difficulties).
   - `"skin"`: A visual skin (not yet supported).
4. **`rizu.dlc.DlcManager`**:
   - Manages active downloads and search states.
   - Holds references to registered `IDlcProvider` instances.
   - Dispatches download requests and receives progress updates.
   - Implements `setSync(boolean)` to toggle between direct execution and threaded execution.
5. **`rizu.dlc.DlcWorker`**:
   - Runs in a background thread (in async mode).
   - Performs HTTP requests using the modern `web` module.
   - Reports progress back to the `DlcManager` via remote calls.
6. **`rizu.dlc.DlcTask`**: 
   - A unit of work representing a download and its subsequent processing (extraction, validation).
7. **Content Integration**:
   - Once a task is complete, the `DlcManager` delegates the final "ingestion" to the appropriate system (e.g., `rizu.library.Library:computeLocation(path, location_id)` for chart types: `pack`, `set`, `file`).

## Supported Data Sources & Providers

### 1. osu! Beatmapsets
- **Type**: `set`
- **Downloads**: `.osz` archives. Since official osu! beatmap storage requires authentication (planned for the future), downloads are currently routed through 3rd-party services without authentication:
  - `https://beatconnect.io/b/BEATMAP_SET_ID`
  - `https://catboy.best/d/BEATMAP_SET_ID`
- **Searching**: Supported via multiple APIs:
  - `https://catboy.best/api/v2/search` (Mino API - returns JSON).
  - `https://osu.ppy.sb/web/osu-search.php?r=4&m=3&p=0&q=` (Akatsuki - osu!direct protocol).
  - `https://ripple.moe/web/osu-search.php?r=4&m=3&p=0&q=` (Ripple - osu!direct protocol).
    - **osu!direct Search Format**: This protocol returns a pipe-separated textual response. Difficulties are provided as a comma-separated list of tooltips in the format `Tooltip@Mode`. 
    - **Difficulty Display**: Difficulty tooltips are treated as opaque strings and displayed "as-is" because different osu!direct providers use different sub-formats for embedding star ratings, BPM, and other metadata within the tooltip.
  - `https://osu.ppy.sh/beatmapsets/search` (Official, unauthorized search endpoint).
- **Assets**:
  - Thumbnails: 
    - 400x140: `https://assets.ppy.sh/beatmaps/{id}/covers/card.jpg`
    - 150x150: `https://assets.ppy.sh/beatmaps/{id}/covers/list.jpg`
    - 900x250: `https://assets.ppy.sh/beatmaps/{id}/covers/cover.jpg`
  - Audio Preview (10s): `https://b.ppy.sh/preview/{id}.mp3`

### 2. osu! Individual Charts (Files)
- **Type**: `file`
- **Downloads**: Raw `.osu` files directly from `https://osu.ppy.sh/osu/BEATMAP_ID` (Official, no auth required).
- **Use Case**: Required specifically for updating existing individual osu! charts within the user's library without downloading the entire beatmapset.

### 3. Etterna Packs
- **Type**: `pack`
- **Downloads**: `.zip` archives. Download links follow the format: `https://downloads.etternaonline.com/ranked/PackName.zip`.
- **Structure**: Etterna packs have a nested structure that the extractor must handle: `PackName/song1/chart1.sm`.
- **Searching**: Pack searches use the API endpoint: `https://api.etternaonline.com/api/packs?page=1&limit=36&sort=name&filter[search]=SEARCH_QUERY`.
- **Filters**:
  - **Sort By**: `name`, `popularity`, `date`, `overall`, `stream`, `jumpstream`, `handstream`, `jacks`, `chordjacks`, `stamina`, `technical`.
  - **Key Count**: `4k`, `5k`, `6k`, `7k`, `8k`, `9k`, `10k`.
  - **Tags**: `x-mod`, `modfiles`, `index`, `hybrid`, `keyboard`, `meme`, `pad`, `anime`.

### 4. Rizu Official Repository (Planned)
- **Status**: 📅 Future Development
- **Goal**: A dedicated, authenticated repository for high-quality, curated Rizu content.
- **Content**: Will support all DLC types: `pack`, `set`, `file`, and `skin`.
- **Features**: Authentication, user ratings, detailed metadata, and integrated versioning for seamless updates.

## Implementation Details

### Modern Networking
- **Download Execution:** The `DlcWorker` will use `web.http.util` (or directly `HttpClient`) to perform downloads. This allows for better header handling, redirect following (if needed), and cleaner integration with the project's modern web stack.
- **Progress Tracking:** The `DlcWorker` will use a custom sink/receive loop to report download progress (bytes received, total size, speed) back to the `DlcManager` via `ThreadRemote` calls.

### Extraction Logic
- **Archive Extraction:** The extraction logic is implemented directly in the `rizu.dlc` module (e.g., as a `DlcExtractor` utility). It must be able to handle both standard ZIP (`.zip`, used by Etterna packs) and osu! specific formats (`.osz`, which are also zip archives) seamlessly. 
- **Destinations:**
  - `pack` types are extracted to `userdata/charts/packs`.
  - `set` types are stored in `userdata/charts/downloads`.
  - `file` types are stored in the directory specified in the metadata (e.g., an existing set folder). Defaults to `userdata/charts/downloads` if unspecified.

### User Interface (Modern Screen)
- **`yi.views.dlc.DlcScreen`**: A new modern screen integrated into the `yi/` UI system.
- **Features**:
  - Search bar with debounced input and provider-specific filters.
  - Rich result list with thumbnails, audio previews, and metadata.
  - Dedicated views for different `DlcType` (Packs, Sets, Files, Skins).
  - Background download management with progress bars.
  - Sidebar integration for quick access.

## Implementation Plan
### Phase 1: Core Infrastructure (Completed)
- **Status**: ✅
- Defined `rizu.dlc.IDlcProvider` (Search, Download).
- Created `rizu.dlc.DlcManager` with synchronous and asynchronous (`ThreadRemote`) modes.
- Implemented `rizu.dlc.DlcWorker` for background HTTP downloads and extraction coordination.
- Implemented `rizu.dlc.DlcTask` for progress reporting and state synchronization.

### Phase 2: Provider Development (In Progress)
- [x] **osu! Beatmapsets (`MinoProvider`)**: Basic search and download implementation using 3rd-party APIs.
- [x] **osu! Individual Files (`OsuFileProvider`)**: Direct `.osu` download to specified set folders (using `metadata.dest_dir`).
- [x] **Etterna Packs (`EtternaPackProvider`)**: Implementation of the `pack` type, including search API integration and Zip download.

### Phase 3: Extraction and Ingestion Refinement
- [x] **Core Extraction**: Basic `.osz` and `.zip` extraction using `DlcExtractor`.
- [x] **Ingestion Logic**: Refine `DlcManager:onDlcCompleted` to better coordinate with the `rizu.library` for different content types (e.g., specific refresh triggers for `packs` vs. `downloads`).

### Phase 4: UI Implementation (Modernization)
- [x] **Modern Screen (`yi.views.dlc.DlcScreen`)**: Implement the new screen using the `yi/` UI system.
- [x] **Sidebar Integration**: Update `yi/views/select/Select.lua` to include a navigation button for the `DlcScreen`.
- [x] **Legacy Removal**: Remove the old `ui/views/DlcModalView.lua` and its hooks from `SelectView` and `yi/views/select/Select.lua`.

## Verification & Testing
- **Synchronous Testing**: Use `manager:setSync(true)` in unit tests to verify logic without the complexity of multi-threading.
- **Asynchronous Validation**: Verify that the UI remains responsive (no micro-stutters) during heavy downloads and extractions.
- Unit tests for `IDlcProvider` implementations using mock HTTP responses.
- Integration tests simulating a complete "Download-to-System" flow.