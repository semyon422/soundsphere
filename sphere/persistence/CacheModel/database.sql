CREATE TABLE IF NOT EXISTS `noteChartDatas` (
    `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `hash` TEXT NOT NULL,
    `index` REAL NOT NULL,
    `format` TEXT,
    `title` TEXT,
    `artist` TEXT,
    `source` TEXT,
    `tags` TEXT,
    `name` TEXT,
    `creator` TEXT,
    `level` REAL,
    `audioPath` TEXT,
    `stagePath` TEXT,
    `previewTime` REAL,
    `inputMode` TEXT,
    `noteCount` REAL,
    `length` REAL,
    `bpm` REAL,
    `difficulty` REAL,
    `longNoteRatio` REAL,
    `localOffset` REAL DEFAULT 0.0,
    UNIQUE(`hash`, `index`)
);

CREATE TABLE IF NOT EXISTS `noteCharts` (
    `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `path` TEXT NOT NULL UNIQUE,
    `hash` TEXT,
    `setId` INTEGER,
    `lastModified` INTEGER
);

CREATE TABLE IF NOT EXISTS `noteChartSets` (
    `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `path` TEXT NOT NULL UNIQUE,
    `lastModified` INTEGER
);

CREATE INDEX IF NOT EXISTS noteCharts_hash_idx ON noteCharts (`hash`);
CREATE INDEX IF NOT EXISTS noteCharts_setId_idx ON noteCharts (`setId`);
CREATE INDEX IF NOT EXISTS noteChartDatas_inputMode_idx ON noteChartDatas (`inputMode`);
CREATE INDEX IF NOT EXISTS noteChartDatas_difficulty_idx ON noteChartDatas (`difficulty`);
CREATE INDEX IF NOT EXISTS noteChartDatas_name_idx ON noteChartDatas (`name`);

CREATE TEMP VIEW IF NOT EXISTS chartset_list AS 

SELECT
noteChartDatas.id AS noteChartDataId,
noteCharts.id AS noteChartId,
scores.id AS scoreId,
noteCharts.setId,
noteCharts.path,
scores.accuracy,
scores.miss,
noteChartDatas.*

FROM noteChartDatas
INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
LEFT JOIN scores ON
noteChartDatas.hash = scores.chart_hash AND
noteChartDatas.`index` = scores.chart_index AND
scores.is_top = TRUE;
