# Execution Plans & Benchmarks

Document the `EXPLAIN ANALYZE` outputs here to track the performance improvements on the `argan` database.

## Test 1: Student Schedule Lookup
**Query:** `SELECT count(*) FROM enrollments WHERE section_id = 10;`

### Before Indexing (`idx_enrollments_section_id`)
* **Execution Time:** [Insert Time] ms
* **Scan Type:** Sequential Scan
* **Buffers:** [Insert Shared Hit/Read blocks]

### After Indexing
* **Execution Time:** [Insert Time] ms
* **Scan Type:** Index Only Scan
* **Buffers:** [Insert Shared Hit/Read blocks]
* **Improvement Factor:** [Calculate X times faster]
