
CREATE TABLE IF NOT EXISTS `difftable_chartmetas_new` (
	`id` INTEGER PRIMARY KEY,
	`user_id` INTEGER NOT NULL,
	`difftable_id` INTEGER NOT NULL,
	`hash` TEXT NOT NULL,
	`index` INTEGER NOT NULL,
	`level` REAL NOT NULL,
	`is_deleted` INTEGER NOT NULL,
	`change_index` INTEGER NOT NULL,
	`created_at` INTEGER NOT NULL,
	`updated_at` INTEGER NOT NULL,
	FOREIGN KEY (difftable_id) REFERENCES difftables(id) ON DELETE CASCADE,
	UNIQUE(`hash`, `index`, `difftable_id`)
);

INSERT INTO difftable_chartmetas_new (
	`id`,
	`user_id`,
	`difftable_id`,
	`hash`,
	`index`,
	`level`,
	`is_deleted`,
	`change_index`,
	`created_at`,
	`updated_at`
)
SELECT
	`id`,
	`user_id`,
	`difftable_id`,
	`hash`,
	`index`,
	`level`,
	0,
	`id`,
	`created_at`,
	`updated_at`
FROM difftable_chartmetas;

DROP TABLE difftable_chartmetas;

ALTER TABLE difftable_chartmetas_new RENAME TO difftable_chartmetas;

CREATE INDEX IF NOT EXISTS difftable_chartmetas_difftable_id_idx ON difftable_chartmetas (`difftable_id`);
CREATE INDEX IF NOT EXISTS difftable_chartmetas_hash_index_idx ON difftable_chartmetas (`hash`, `index`);
CREATE INDEX IF NOT EXISTS difftable_chartmetas_is_deleted_idx ON difftable_chartmetas (`is_deleted`);
CREATE UNIQUE INDEX IF NOT EXISTS difftable_chartmetas_change_index_dt_id_idx ON difftable_chartmetas (`difftable_id`, `change_index`);
CREATE INDEX IF NOT EXISTS difftable_chartmetas_change_index_idx ON difftable_chartmetas (`change_index`);