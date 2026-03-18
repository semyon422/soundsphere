# Chart Selection (`rizu.select`)

## Goal
The selection system provides a responsive and intuitive interface for browsing the music library. It manages the hierarchical navigation between song collections, individual files, and playable variations, ensuring the UI stays synchronized with the underlying database.

## User Experience
The player interacts with two main lists: the **Primary List** (the main navigation) and the **Secondary List** (the detail view).
- **Navigation**: Choosing an item in the Primary List (e.g., a Song) automatically updates the Secondary List to show its related content (e.g., all available playable variations).
- **Smooth Browsing**: Scrolling through thousands of items is instantaneous. The system only loads the heavy metadata for items currently visible on the screen.
- **Search & Filter**: Any changes to search queries, sorting, or filters trigger a background library query. The UI maintains the current selection by ID even as the list content changes.
- **Instant Preview**: Selecting a playable variation immediately prepares the game settings (modifiers, rates) and triggers the audio/visual preview system.

## Architecture Decisions (ADR)

### ADR: Two-Level Selection Model
- **Context**: The library has a 5-level deep hierarchy, but presenting all 5 levels simultaneously would overwhelm the player.
- **Decision**: We use a generalized two-level "Drill-down" model. The system maps any two levels of the hierarchy (configured via `primary_mode` and `secondary_mode` in `settings.select`) to a Primary and Secondary view.
- **Consequence**: This flexibility allows the UI to support different navigation styles (e.g., browsing by Set vs. browsing by Metadata) without rewriting the core logic.

### ADR: Off-Thread Retrieval
- **Context**: Performing SQL queries and calculating aggregated metrics for 50,000+ items on the main thread causes significant frame drops.
- **Decision**: All database-intensive operations (queries, drill-downs, score fetching) are offloaded to the `Library.Worker` thread.
- **Consequence**: The UI loop remains unblocked, maintaining 60fps during heavy library refreshes. State updates are coordinated via asynchronous callbacks.

## Implementation Details

### Selection Levels
The system tracks selection across all 5 granularity levels defined in `rizu/library/spec.md`:
1. `chartfile_sets`
2. `chartfiles`
3. `chartmetas`
4. `chartdiffs`
5. `chartplays`

The `SelectionState` container maintains the current `index` and `id` for each level to support selection restoration.

### Components
- **ChartSelector**: The central orchestrator. It manages debounced refreshes, restoration of selection based on IDs after list updates, and orchestration of asynchronous tasks.
- **ListStore**: A reactive proxy for list data (`rizu.select.stores.ListStore`). It utilizes the unified FFI indexing and on-demand enrichment specified in the library module.
- **SelectionState**: A level-based state container tracking the current focus for each hierarchy level.

### Update Lifecycle
1. **Full Refresh**: Triggered by changes in filters, search, or sorting. `ChartSelector:updatePrimaryItems()` calls the library query engine asynchronously.
2. **Level Propagation**: Triggered when the primary selection changes. `ChartSelector:pullLevel(2)` is called to fetch related child items in the worker thread.
3. **Restoration**: After any list update, the system uses ID-to-Index maps provided by the query result to re-focus the previously selected item.

## Synchronization
- **Selected Chart**: The item at the finest active level (typically Level 2) is considered the "Selected Chart."
- **Gameplay Sync**: Selection changes update the `ReplayBase` with variation-specific settings (modifiers, rate) if the mode is `chartdiffs` or `chartplays`.
- **Observables**: UI components bind to `ListStore.onChanged` for item updates and `SelectionState.onChanged` for selection and scroll updates.
