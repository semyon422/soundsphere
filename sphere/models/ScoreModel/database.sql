CREATE TABLE IF NOT EXISTS `info` (
    `key` NOT NULL PRIMARY KEY,
    `value` TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS `scores` (
    `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `noteChartHash` TEXT NOT NULL,
    `noteChartIndex` REAL NOT NULL,
    `isTop` INTEGER DEFAULT FALSE,
    `playerName` TEXT,
    `time` INTEGER,
    `accuracy` REAL,
    `maxCombo` INTEGER,
    `modifiers` TEXT,
    `replayHash` TEXT,
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
    `pausesCount` REAL
);
CREATE INDEX IF NOT EXISTS isTopIndex ON scores(isTop) WHERE isTop = TRUE;
CREATE INDEX IF NOT EXISTS hashIndexIndex ON scores(noteChartHash, noteChartIndex);
CREATE INDEX IF NOT EXISTS accuracyIndex ON scores(accuracy);
