CREATE TABLE IF NOT EXISTS `info` (
	`key` NOT NULL PRIMARY KEY,
	`value` TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS `scores` (
	`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`chart_hash` TEXT NOT NULL,
	`chart_index` REAL NOT NULL,
	`is_top` REAL DEFAULT 0,
	`time` REAL,
	`accuracy` REAL,
	`max_combo` REAL,
	`modifiers` TEXT,
	`rate` REAL,
	`const` REAL,
	`replay_hash` TEXT,
	`ratio` REAL,
	`perfect` REAL,
	`not_perfect` REAL,
	`miss` REAL,
	`mean` REAL,
	`earlylate` REAL,
	`inputmode` TEXT,
	`difficulty` REAL,
	`pauses` REAL
);
