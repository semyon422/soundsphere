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
- If `primary_mode = chartfile_sets`, the list shows chart sets (equivalent to current `collapse = true`).
- If `primary_mode = chartmetas`, the list shows individual charts (equivalent to current `collapse = false`).

### Secondary List (Sub-list)
The secondary list's content is determined by both `primary_mode` and `secondary_mode` using the following rule:
- **Scope (Filtering):** Filtered by the ID(s) of the **coarser** of the two modes.
- **Granularity (Grouping):** Grouped by the **finer** of the two modes.

#### Examples:
| Primary Mode | Secondary Mode | Filter Level | Group Level | User Experience |
| :--- | :--- | :--- | :--- | :--- |
| `chartfile_sets` | `chartmetas` | `set` | `meta` | **Drill-down:** Select a set, see all its charts. |
| `chartmetas` | `chartfile_sets` | `set` | `meta` | **Context:** Select a chart, see its "siblings" in the same set. |
| `chartmetas` | `chartmetas` | `meta` | `meta` | **Focus:** Select a chart, see only that chart. |
| `chartmetas` | `chartdiffs` | `meta` | `diff` | **Drill-down:** Select a chart, see all its difficulties/modifiers. |
| `chartdiffs` | `chartmetas` | `meta` | `diff` | **Context:** Select a difficulty, see all difficulties of that chart. |
| `chartfile_sets` | `chartdiffs` | `set` | `diff` | **Deep Drill-down:** Select a set, see all difficulties of all charts in it. |

## Implementation Plan

### 1. Update `ChartviewsRepo`
- Replace `params.chartviews_table` with `params.primary_mode`.
- Update `_buildViewSubquery` to support all 5 modes for `view_group`.
- Generalize joining logic:
  - `chartfile_sets`, `chartfiles`, `chartmetas` modes use `JOINS_CHARTFILES_METAS_SETS`.
  - `chartdiffs` mode adds `LEFT JOIN chartdiffs`.
  - `chartplays` mode adds `INNER JOIN chartplays`.
- Update `queryNoteChartSets` to use `primary_mode`.
- Update `getChartviewsAtSet` (rename to `getSecondaryViews` or similar) to accept both `primary_mode` and `secondary_mode` and apply the filter/group rule.

### 2. Update `SelectionQueryBuilder`
- Replace `collapse` and `chartviews_table` logic with `primary_mode` and `secondary_mode`.
- `params.group` should be set to the grouping columns of `primary_mode`.

### 3. Update `ChartSelector` and UI
- Update `SelectionState` to hold `primary_mode` and `secondary_mode`.
- Update `ChartStore` to fetch secondary views based on both modes.

## Inaccuracies and Contradictions in Original Proposal
- **Grouping vs Filtering:** The original proposal suggested the secondary list has "same grouping" as the mode, but also "filtering according to primary mode". This was contradictory for cases like `primary=meta, secondary=set`. The refined "Min/Max" rule resolves this by distinguishing between the scope of the filter and the granularity of the items.
- **`chartfiles` vs `chartmetas`:** Clarified that `chartfiles` is a distinct level between sets and metas to handle multi-chart file formats correctly.
