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
