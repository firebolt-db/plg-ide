-- Parallelism Controls Demo: Limit query parallelism
-- max_threads limits how many threads per node are used for the query.
-- Use lower values to reduce memory pressure or resource contention.

SET max_threads = 4;

-- Optional: for ingestion, limit insert parallelism
-- INSERT INTO table SELECT ... WITH (max_insert_threads = 1);
