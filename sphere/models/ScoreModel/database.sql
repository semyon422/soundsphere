CREATE TABLE IF NOT EXISTS `info` (
    `key` NOT NULL PRIMARY KEY,
    `value` TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS `scores` (
    `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `noteChartHash` TEXT NOT NULL,
    `noteChartIndex` REAL NOT NULL,
    `playerName` TEXT,
    `time` INTEGER,
    `score` REAL,
    `accuracy` REAL,
    `maxCombo` INTEGER,
    `modifiers` TEXT,
    `replayHash` TEXT,
    `rating` REAL,
    `pauses` REAL,
    `ratio` REAL,
    `perfect` REAL,
    `notPerfect` REAL,
    `missCount` REAL,
    `mean` REAL,
    `earlylate` REAL,
    `inputMode` TEXT,
    `timeRate` REAL,
    `difficulty` REAL,
    `pausesCount` REAL,
    `isTop` INTEGER DEFAULT 0
);
