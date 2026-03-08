# Chart Selection System

The chart selection system manages hierarchical navigation through the library using a generalized, level-based architecture. It coordinates UI state with the underlying library query engine.

## Hierarchy and Levels

The hierarchy is determined by `primary_mode` and `secondary_mode` (configured in `settings.select`), which map to levels in the `SelectionState`:
1. `chartfile_sets`
2. `chartfiles`
3. `chartmetas`
4. `chartdiffs`
5. `chartplays`

- **Level 1 (Primary):** The root navigation level. It uses a **Global Scope**, querying the entire library asynchronously via the Library Worker.
- **Level 2 (Secondary):** A drill-down level. It uses a **Filtered Scope**, fetching items related to the selection of Level 1 via the Library Worker.

Refer to `rizu/library/spec.md` for details on grouping and aggregation rules.

## Components

### 1. ChartSelector (The Orchestrator)
The central controller that coordinates data fetching and selection state. It handles:
- Debounced library refreshes.
- Propagation of selection changes from parent levels to child levels.
- Restoration of selection based on IDs after list updates.
- Orchestration of asynchronous tasks via `TaskRunner`.

### 2. ListStore (The Data Proxy)
A generalized store (`rizu.select.stores.ListStore`) that acts as a reactive, cached proxy for list data. It utilizes the unified FFI indexing and on-demand enrichment specified in `rizu/library/spec.md`.

### 3. SelectionState (The Reactive State)
A level-based state container that tracks the current `index` and `id` for each hierarchy level.
- `levels[1]`: Primary selection.
- `levels[2]`: Secondary selection.

## Update Lifecycle

1. **Full Refresh:** Triggered by changes in filters, search, or sorting.
   - `ChartSelector:updatePrimaryItems()` calls `Library:queryAsync()`.
   - `ListStore[1]` is updated with the new result.
   - Selection is restored for Level 1 based on IDs.
2. **Level Propagation:**
   - When Level 1 selection changes, `ChartSelector:pullLevel(2)` is called.
   - `Library:getViewsAsync(parent_item)` is called to fetch child items in the worker thread.
   - `ListStore[2]` is updated with the new result.
   - Selection is restored for Level 2.

## Performance and Optimization

- **Threaded Retrieval:** All database intensive operations (queries, drill-downs, score fetching) are offloaded to the `Library.Worker` thread.
- **Virtualization Support:** The unified FFI approach for all levels allows the UI to handle thousands of secondary items without garbage collection pressure.

## Synchronization and UI

- **Selected Chart:** The item at the finest active level (typically Level 2) is the "Selected Chart."
- **ReplayBase:** Updated with settings (modifiers, rate) from the selected item if the mode is `chartdiffs` or `chartplays`.
- **Observables:** UI components bind to `ListStore.onChanged` for item updates and `SelectionState.onChanged` for selection/scroll updates.
