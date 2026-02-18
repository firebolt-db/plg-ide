# Iceberg Demo – SQL Syntax Verification

Verified against [Firebolt documentation](https://docs.firebolt.io) (READ_ICEBERG, CREATE LOCATION, DROP TABLE, information_schema). The demo uses **LOCATION + view** only; Firebolt does not support `CREATE EXTERNAL TABLE ... USING READ_ICEBERG(...)`.

---

## Demo sequence (LOCATION-based)

1. **CREATE LOCATION** per TPCH table (`01_create_locations_tpch.sql`) – FILE_BASED catalog, URL to S3 Iceberg path.
2. **CREATE VIEW** from LOCATION (`02_create_view.sql`) – e.g. `CREATE VIEW iceberg_lineitem AS SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_lineitem', MAX_STALENESS => INTERVAL '1' HOUR)`.
3. Queries use the view `iceberg_lineitem`.

---

## READ_ICEBERG

- **LOCATION:** `LOCATION => 'tpch_lineitem'` (name from CREATE LOCATION).
- **MAX_STALENESS:** Docs use `MAX_STALENESS` (one "L"); `max_staleness` often accepted (case-insensitive).
- With **URL** (no LOCATION): `URL => 's3://...'`, `MAX_STALENESS => INTERVAL '30 seconds'`. See [READ_ICEBERG](https://docs.firebolt.io/reference-sql/functions-reference/iceberg/read_iceberg).

---

## DROP VIEW / DROP TABLE

- Use **DROP VIEW IF EXISTS** for views; **DROP TABLE IF EXISTS** for tables.
- Firebolt [DROP TABLE](https://docs.firebolt.io/reference-sql/commands/data-definition/drop-table) drops any table; for views use DROP VIEW.

---

## Metadata (information_schema)

```sql
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_name = 'iceberg_lineitem';
```

Use this instead of `SHOW EXTERNAL TABLES` (not in Firebolt reference for this use case).

---

## Other statements

| Statement / pattern           | Status |
|------------------------------|--------|
| `CREATE DATABASE IF NOT EXISTS` | OK     |
| `USE database`                | OK     |
| `CREATE LOCATION ... ICEBERG FILE_BASED` | OK (see CREATE LOCATION Iceberg docs) |
| `DESCRIBE table`             | OK     |
| `SET enable_result_cache`    | Verify on engine if needed |
| `EXPLAIN ANALYZE SELECT ...` | OK     |
| `DATE '1998-01-01'`          | OK     |
| `GROUP BY 1, 2`               | OK     |
| `INTERVAL '1' HOUR`           | OK     |

---

## References

- [Firebolt READ_ICEBERG](https://docs.firebolt.io/reference-sql/functions-reference/iceberg/read_iceberg)
- [Firebolt CREATE LOCATION (Iceberg)](https://docs.firebolt.io/reference-sql/commands/data-definition/create-location-iceberg)
- [Firebolt DROP TABLE](https://docs.firebolt.io/reference-sql/commands/data-definition/drop-table)
- [Firebolt information_schema.tables](https://docs.firebolt.io/reference-sql/information-schema/tables)
