# Argan DB Optimization & Speed Up

This project modularizes and optimizes the `argan` university database, focusing on schema scalability, query performance, and efficient data generation.

## Project Structure
* `sql/01_schema_setup.sql`: Base tables and ENUM types.
* `sql/02_indexing.sql`: B-Tree indexes and query planning tests.
* `sql/03_partitioning.sql`: Table partitioning for historical grade data.
* `sql/04_views.sql`: Materialized views for complex analytical queries.
* `sql/05_bulk_insert.sql`: Massive data generation scripts.
* `config/postgresql_tuned.conf`: Optimized server memory and I/O settings.

## Setup Instructions
1. Apply the tuned configurations to your `postgresql.conf` file and restart the server.
2. Execute the SQL scripts in order (01 through 05) using `psql` or your preferred IDE.
3. Record benchmark queries in `execution_plans.md`.

### 1. Table Partitioning: Historical Grades Data
By partitioning the `grades` table by year, the query planner utilizes partition pruning to skip scanning irrelevant data, significantly dropping execution times for historical queries.

| Before Partitioning (Full Table Scan) | After Partitioning (Partition Pruning) |
| :---: | :---: |
| ![Before Partitioning](<img width="963" height="368" alt="before_partitioning" src="https://github.com/user-attachments/assets/1f81f37e-ad38-47c2-bd3d-6c6b1c894941" />
) | ![After Partitioning](<img width="1166" height="420" alt="after_partitioning" src="https://github.com/user-attachments/assets/d3326743-a985-444c-a707-7f53607e33ad" />
) |

### 2. Materialized Views: Department Statistics
Complex, multi-table aggregations were converted into materialized views, shifting the processing load from on-the-fly calculation to instant, pre-computed reads.

| Before Materialized View (Heavy Joins) | After Materialized View (Instant Read) |
| :---: | :---: |
| ![Before MV](<img width="690" height="896" alt="before_mv1" src="https://github.com/user-attachments/assets/9596daf4-dd99-4118-8130-f519c545d1ce" />
)(<img width="642" height="263" alt="before_mv2" src="https://github.com/user-attachments/assets/625017f4-472e-49d5-8863-ac10991144f2" />
)  | ![After MV](<img width="983" height="250" alt="after_mv" src="https://github.com/user-attachments/assets/2f300d86-e597-4430-a510-95afeb23e8cb" />
) |
