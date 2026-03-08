# Chart Selection System

The chart selection system manages hierarchical navigation through the library using a generalized, level-based architecture. It supports dynamic grouping and drill-down across 5 granularity levels.

## Hierarchy and Levels

The hierarchy is defined by `primary_mode` and `secondary_mode` (configured in `settings.select`), mapping to levels in the `SelectionState`:
1. `chartfile_sets`
2. `chartfiles`
3. `chartmetas`
4. `chartdiffs`
5. `chartplays`

- **Level 1 (Primary):** The root navigation level. It uses a **Global Scope**, querying the entire library asynchronously.
- **Level 2 (Secondary):** A drill-down level. It uses a **Filtered Scope**, fetching items related to the selection of Level 1.

The system is designed to support N-levels of hierarchy if needed.

## Components

### 1. ChartSelector (The Orchestrator)
The central controller that coordinates data fetching and selection state across levels. It handles:
- Debounced library refreshes.
- Propagation of selection changes from parent levels to child levels.
- Restoration of selection based on IDs after list updates.

### 2. ListStore (The Data Container)
A generalized store (`rizu.select.stores.ListStore`) that can operate in two modes:
- **Global Mode:** Connects to the `ChartviewsRepo` FFI index for high-performance access to the full library.
- **Filtered Mode:** Holds a local Lua table of items fetched specifically for the current drill-down context.

### 3. SelectionState (The Reactive State)
A level-based state container that tracks the current `index` and `id` for each hierarchy level.
- `levels[1]`: Primary selection.
- `levels[2]`: Secondary selection.

## Update Lifecycle

1. **Full Refresh:** Triggered by changes in filters, search, or sorting.
   - `ChartSelector:refresh()` calls `Repo:queryAsync()`.
   - `ListStore[1]` updates from the repo's global index.
   - Selection is restored for Level 1.
2. **Level Propagation:**
   - When Level 1 selection changes, `ChartSelector:pullLevel(2)` is called.
   - `Repo:getViews(parent_item)` is called synchronously (but within a Task) to fetch child items.
   - `ListStore[2]` is updated with the new items.
   - Selection is restored for Level 2.

## Synchronization and UI

- **Selected Chart:** The item at the finest active level (typically Level 2) is considered the "Selected Chart."
- **ReplayBase:** Updated with settings (modifiers, rate) from the selected item if the mode is `chartdiffs` or `chartplays`.
- **Observables:** UI components bind to `ListStore.onChanged` for item updates and `SelectionState.onChanged` for selection/scroll updates.

## Performance
- **Primary Queries:** Performed in a background thread to prevent UI freezing.
- **Secondary Queries:** Synchronous but wrapped in a `TaskRunner` to ensure consistent frame timing.
- **FFI Indexing:** Level 1 uses an FFI-based struct array in `ChartviewsRepo` for memory efficiency when handling tens of thousands of charts.
