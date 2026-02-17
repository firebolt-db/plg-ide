-- Automated Column Statistics Demo: Enable statistics
-- Add ndistinct statistics so the optimizer knows cardinality of key columns
-- and can choose a better join order (e.g. build from games, probe from playstats).

ALTER TABLE playstats ADD STATISTICS (gameid) TYPE ndistinct;
ALTER TABLE playstats ADD STATISTICS (playerid) TYPE ndistinct;

-- Optional: show the system-managed aggregating indexes created for statistics
-- SHOW INDEXES;
