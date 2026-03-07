# Flexible Chart Selection and Grouping

## Goal
Generalize the chart selection logic to allow individual selection modes for the primary list (main list) and secondary list (sub-list). This replaces the current rigid `chartviews_table` and `collapse` settings with a more flexible hierarchical system.

## Selection Modes (Granularity Levels)
There are 5 hierarchy levels, from coarsest to finest:
1. `chartfile_sets` (Group by `chartfile_set_id`)
2. `chartfiles` (Group by `chartfile_id`)
3. `chartmetas` (Group by `chartmeta_id`)
4. `chartdiffs` (Group by `chartdiff_id`)
5. `chartplays` (Group by `chartplay_id`)

Relationship: `set` (1:N) `file` (1:N) `meta` (1:N) `diff` (1:N) `play`.

## Selection Logic

### Primary List (Main List)
The primary list is grouped by the `primary_mode`.
- If `primary_mode = chartfile_sets`, the list shows chart sets.
- If `primary_mode = chartmetas`, the list shows individual charts.

### Secondary List (Sub-list)
The secondary list's content is determined by both `primary_mode` and `secondary_mode` using the following rule:
- **Scope (Filtering):** Filtered by the ID(s) of the **coarser** of the two modes.
- **Granularity (Grouping):** Grouped by the **finer** of the two modes.

### Default Item Selection (Aggregation)
When grouping at a coarser level, the data for finer levels must be picked according to these defaults:
- **Default Chartmeta for a Set/File:** The one with the **lowest `id`**.
- **Default Chartdiff for a Meta:** The **base** difficulty (modifiers = '', rate = 1.0).
- **Default Chartplay for a Diff:** The **latest** play (highest `created_at` or `id`).

#### Examples:
| Primary Mode | Secondary Mode | Filter Level | Group Level | User Experience |
| :--- | :--- | :--- | :--- | :--- |
| `chartfile_sets` | `chartmetas` | `set` | `meta` | **Drill-down:** Select a set, see all its charts (base diffs). |
| `chartmetas` | `chartfile_sets` | `set` | `meta` | **Context:** Select a chart, see its "siblings" in the same set. |
| `chartmetas` | `chartmetas` | `meta` | `meta` | **Focus:** Select a chart, see only that chart (base diff). |
| `chartmetas` | `chartdiffs` | `meta` | `diff` | **Drill-down:** Select a chart, see all its difficulties/modifiers. |
| `chartdiffs` | `chartmetas` | `meta` | `diff` | **Context:** Select a difficulty, see all difficulties of that chart. |
| `chartfile_sets` | `chartdiffs` | `set` | `diff` | **Deep Drill-down:** Select a set, see all difficulties of all charts in it. |
