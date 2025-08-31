
ALTER TABLE `leaderboard_users` ADD COLUMN `total_plays` INTEGER NOT NULL DEFAULT 0;
ALTER TABLE `leaderboard_users` ADD COLUMN `ranked_plays` INTEGER NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS leaderboard_users_total_rating_idx ON leaderboard_users (`total_rating`);
